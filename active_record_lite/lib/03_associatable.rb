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
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    if options[:primary_key]
      @primary_key = options[:primary_key]
    else
      @primary_key = :id
    end
    
    if options[:foreign_key]
      @foreign_key = options[:foreign_key]
    else
      name_sym = (name.to_s + "_id").to_sym
      @foreign_key = name_sym
    end
    
    if options[:class_name]
      @class_name = options[:class_name]
    else
      @class_name = name.to_s.camelcase
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options[:primary_key]
      @primary_key = options[:primary_key]
    else
      @primary_key = :id
    end
    
    if options[:foreign_key]
      @foreign_key = options[:foreign_key]
    else
      self_class_name_sym = (self_class_name.to_s.downcase + "_id").to_sym
      @foreign_key = self_class_name_sym
    end
    
    if options[:class_name]
      @class_name = options[:class_name]
    else
      @class_name = name.to_s.camelcase.singularize
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    define_method(name.to_sym) do
      my_foreign_key = options.send(:foreign_key)
      my_foreign_key_value = self.send(my_foreign_key)
      target_model_class = options.model_class
      
      target_model_class.where(id: my_foreign_key_value).first
    end
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
