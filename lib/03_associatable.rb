require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    class_name.downcase + 's'
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = "#{name}_id".to_sym
    @primary_key = :id
    @class_name = name.to_s.camelcase

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
    @class_name = name.to_s.camelcase.singularize
    # overrides
    options.each do |k,v|
      instance_variable_set("@#{k}", v) 
    end
 
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do 
      foreign_key = send(options.foreign_key)
      primary_key = options.primary_key
      model_class = options.model_class
      results = model_class.where(primary_key => foreign_key)
      results.first      
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name, options)
    define_method(name) do 
      primary_key = send(options.primary_key)
      foreign_key = options.foreign_key
      model_class = options.model_class
      results = model_class.where(foreign_key => primary_key)
      results
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
