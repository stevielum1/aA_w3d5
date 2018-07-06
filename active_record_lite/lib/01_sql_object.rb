require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns
      @columns
    else
      columns = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
        SQL
      @columns = columns.first.map(&:to_sym)
    end
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column.to_sym) do
        attributes[column]
      end
      
      setter = column.to_s + "="
      define_method(setter.to_sym) do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name.tableize
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      SQL
      
    self.parse_all(data)
  end

  def self.parse_all(results)
    results.map{|datum| self.new(datum)}
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name_sym = attr_name.to_sym
      columns = self.class.columns
      raise "unknown attribute '#{attr_name}'" unless columns.include?(attr_name_sym)
      setter = attr_name.to_s + "="
      self.send(setter.to_sym, value)
    end  
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
