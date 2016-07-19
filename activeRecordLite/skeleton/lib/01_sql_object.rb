require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

require 'byebug'

class SQLObject
  def self.columns
    # ...
  end

  def self.finalize!
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    return @table_name unless @table_name.nil?

    self.deduce_table_name
  end

  def self.deduce_table_name
    model_name = self.to_s
    capitals = ("A".."Z").to_a
    capital_indices = []

    model_name.length.times do |letterIdx|
      capital_indices << letterIdx if capitals.include?(model_name[letterIdx])
    end

    capital_indices << model_name.length

    words = []
    capital_indices.each_with_index do |capitalIdx, i|
      next if i === capital_indices.length - 1
      nextCapitalIdx = capital_indices[i + 1]
      words << model_name[capitalIdx...nextCapitalIdx].downcase
    end

    words.join('_')
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    # ...
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




#tests
class BigDog < SQLObject

end

puts BigDog.table_name
#table names work
