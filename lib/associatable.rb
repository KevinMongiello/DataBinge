require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.capitalize.constantize
  end

  def table_name
    model_class::table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.foreign_key = options[:foreign_key] || (name.to_s.singularize + "_id").to_sym
    self.primary_key = options[:primary_key] || :id
    self.class_name = options[:class_name] || name.to_s.capitalize.to_s
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.class_name = options[:class_name] || name.to_s.singularize.capitalize.to_s
    self.foreign_key = options[:foreign_key] || (self_class_name.downcase + "_id").to_sym
    self.primary_key = options[:primary_key] || :id
  end
end

module Associatable

  def assoc_options
    @assoc_options ||= {}
  end

  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)
    define_method(name) do
      foreign_key = self.class.assoc_options[name].foreign_key
      model_class = self.class.assoc_options[name].class_name
      model_class.where(id: self.send(foreign_key))
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      model_class = name.to_s.singularize.capitalize.constantize
      model_class.where(self.class.assoc_options[name].foreign_key => self.id)
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      through_fk = through_options.foreign_key.to_s
      through_pk = self.id

      source_options = through_options.class_name.constantize.assoc_options[source_name]
      if source_options.is_a?(HasManyOptions)
        source_k = source_options.foreign_key.to_s
        through_k = "id"
      else
        source_k = "id"
        through_k = source_options.foreign_key.to_s
      end

      source_name_str = source_name.to_s.downcase
      through_name_str = through_name.to_s.downcase

      results = DBConnection.instance.execute(<<-SQL, through_pk)
        SELECT
          #{source_name_str}.*
        FROM
          #{through_name_str}
        JOIN
          #{source_name_str} ON #{source_name_str}.#{source_k} = #{through_name_str}.#{through_k}
        WHERE
          #{through_name_str}.#{through_fk} = ?
      SQL

      source_options.class_name.constantize.parse_all(results)
    end
  end

end
