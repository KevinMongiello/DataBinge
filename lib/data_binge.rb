require 'active_support/inflector'
require_relative 'searchable'
require_relative 'associatable'
require_relative '../db/db_connection'
require 'byebug'

class DataBinge
  extend Searchable
  extend Associatable

  def self.columns
    @table_data ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    table_cols = @table_data[0].map(&:to_sym)
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    rows = DBConnection.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{@table_name}
    SQL

    parse_all(rows)
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{@table_name}
      WHERE
        #{@table_name}.id = ?
      LIMIT 1
    SQL

    return nil if result.empty?
    self.new(result.first)
  end

  def self.first
    self.all.first
  end

  def initialize(params = {})
    columns = self.class.columns
    params.each do |attr_name, val|
      attr_name = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless columns.include?(attr_name)
      send("#{attr_name}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.map { |_,v| v}
  end

  def insert
    # skip id
    cols = self.class.columns.drop(1)
    question_marks = (["?"] * cols.length).join(", ")
    col_names = cols.join(", ")
    here = <<-SQL
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    DBConnection.execute(here, *attribute_values)
    self.id = DBConnection.last_insert_row_id
    self
  end

  def update
    cols = self.class.columns.drop(1)
    # debugger
    str = cols.map { |col| "#{col} = ?" }.join(", ")
    vals = attribute_values
    #(attribute_values.drop(1)) << self.id    # rotate id
    here = <<-SQL
      UPDATE
        #{self.class.table_name}
      SET
        #{str}
      WHERE
        id = ?
    SQL
    DBConnection.execute(here, *vals)
    self
  end

  def save
    if self.id
      update
    else
      insert
    end
  end

  private
  def self.parse_all(results)
    results.map { |row| self.new(row) }
  end

  def self.finalize!
    columns = self.columns
    columns.each do |col|

      define_method(col) do
        @attributes[col]
      end

      define_method("#{col.to_s}=") do |target|
        attributes
        @attributes[col]=target
      end

    end
  end

end
