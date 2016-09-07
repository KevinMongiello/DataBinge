module Searchable
  def where(params)
    where_line = params.keys.map { |k| "#{k} = ?" }.join(" AND ")
    vals = params.values
    here = <<-SQL
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    results = DBConnection.execute(here, *vals)
    results.map { |result| self.new(result) }
  end
end
