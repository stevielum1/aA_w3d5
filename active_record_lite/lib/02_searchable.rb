require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map(&:to_s).map{|key| "#{key} = ?"}.join(" AND ")
    attr_values = params.values
    data = DBConnection.execute(<<-SQL, *attr_values)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_line}
    SQL
    data.map { |datum| self.new(datum) }
  end
end

class SQLObject
  extend Searchable
end
