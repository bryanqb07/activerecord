require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    @columns = cols.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) { attributes[column] }      
      define_method("#{column}=") { |val| attributes[column] = val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || name.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
   result = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
   return nil if result.empty?
   self.new(result.first)
  end

  def initialize(params = {})
    columns = self.class::columns
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      raise Exception.new "unknown attribute '#{attr_name}'" unless columns.include?(attr_name)
      send("#{attr_name}=", value)
    end  
  end

  def attributes
    @attributes ||= {}
    @attributes
  end

  def attribute_values
    self.class::columns.map { |column| send(column) }
  end

  def insert
    # debugger
    col_names = self.class::columns
    question_marks = ( ["?"] * col_names.length ).join(",")
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class::table_name} (#{col_names.join(",")})
      VALUES
       (#{ question_marks })    
    SQL
    attributes[:id] = DBConnection.last_insert_row_id  
  end

  def update
    col_names = self.class::columns
    question_marks = col_names.map { |col| "#{col} = ?" }.join(",") 
    id = attributes[:id]
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class::table_name} 
      SET 
        #{question_marks}
      WHERE
        id = ?
    SQL
  end

  def save
    # ...
  end
end
