require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    question_marks = params.keys.map { |key| "#{key} = ?"}.join(" AND ") 
    # debugger
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
       #{ question_marks }    
    SQL
    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
