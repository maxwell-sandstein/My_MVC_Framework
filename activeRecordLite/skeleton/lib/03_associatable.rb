require_relative '02_searchable'
require 'active_support/inflector'
require ('byebug')

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
  end

  def table_name
    # ...
  end
end

class BelongsToOptions < AssocOptions
  attr_reader :primary_key, :class_name, :foreign_key

  def initialize(name, options = {})
    default = {
      primary_key: :id,
      class_name: "#{name.to_s.camelcase}",
      foreign_key: "#{name.to_s}_id".to_sym
    }

    options = default.merge(options)

    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
    @foreign_key = options[:foreign_key]
  end

  def model_class
    self.class_name.singularize.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class HasManyOptions < AssocOptions
  attr_reader :primary_key, :class_name, :foreign_key

  def initialize(name, self_class_name, options = {})

    default = {
      primary_key: :id,
      class_name: "#{name.to_s.singularize.camelcase}",
      foreign_key: "#{self_class_name.underscore.downcase}_id".to_sym
    }

    options = default.merge(options)

    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
    @foreign_key = options[:foreign_key]
  end

  def model_class
    self.class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

module Associatable
  # Phase IIIb

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options
    define_method(name) do

      primary_key = options.primary_key
      foreign_key = options.foreign_key
      key_value_to_join_on = self.send(foreign_key)
      class_to_query = options.model_class

      class_to_query.where(primary_key => key_value_to_join_on)[0]
    end

  end

  def has_many(name, options = {})
      options = HasManyOptions.new(name, self.to_s, options)
      define_method(name) do
        primary_key = options.primary_key
        foreign_key = options.foreign_key
        key_value_to_join_on = self.send(primary_key)
        class_to_query = options.model_class

        class_to_query.where(foreign_key => key_value_to_join_on)
      end
  end

  def assoc_options
    @belongs_to_options = @belongs_to_options || {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
