require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
     through_options = self.class.assoc_options[through_name]
     source_options = through_options.model_class.assoc_options[source_name]
     foreign_val = send(through_options.foreign_key)
     through_primary_str = "#{through_options.table_name}.#{through_options.primary_key}"
     source_primary_str = "#{source_options.table_name}.#{source_options.primary_key}"
     through_foreign_str = "#{through_options.table_name}.#{source_options.foreign_key}"
     # debugger
     
     results = DBConnection.execute(<<-SQL, foreign_val)
      SELECT
        #{source_options.table_name}.*
      FROM
        #{through_options.table_name}
      INNER JOIN
        #{source_options.table_name} ON #{through_foreign_str} = #{source_primary_str}
      WHERE
       #{through_primary_str} = ?
     SQL

     source_options.model_class.new(results.first) 
    end
  end
end
