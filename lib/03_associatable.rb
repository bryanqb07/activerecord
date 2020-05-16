require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.downcase + 's'
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = "#{name}_id".to_sym
    @primary_key = :id
    @class_name = name.camelcase

    # overrides
    options.each do |k,v|
      instance_variable_set("@#{k}", v) 
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = "#{self_class_name.underscore}_id".to_sym
    @primary_key = :id
    @class_name = name.camelcase.singularize

    # overrides
    options.each do |k,v|
      instance_variable_set("@#{k}", v) 
    end
 
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
