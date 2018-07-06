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
    data = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        id = ?
      SQL
    data.length < 1 ? nil : self.new(data.first)
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
    self.class.columns.map { |column| self.send(column) }
  end

  def insert
    col_names = self.class.columns.map(&:to_s).join(",")
    question_marks = (["?"] * self.class.columns.length).join(",")
    
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
      SQL
    self.send(:id=, DBConnection.last_insert_row_id)
  end

  def update
    set_line = self.class.columns[1..-1].map {|attr_name| "#{attr_name} = ?"}.join(",")
    attr_values = attribute_values.rotate
    DBConnection.execute(<<-SQL, *attr_values)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = ?
    SQL
      
  end

  def save
    self.send(:id).nil? ? insert : update
  end
end
