require_relative 'db_connection'
require 'active_support/inflector'
require 'set'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

require 'byebug'

class SQLObject
  def self.columns  #implemented with set despite spec expecting array.  pay attentiont to errs
    # ...
    return @columns unless @columns.nil?

    table = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @columns = table[0].map do |column_name|
      column_name.to_sym
    end

    @columns = @columns.to_set
  end

  def self.finalize!
    self.columns.each do |column|
      self.define_getter(column)
      self.define_setter(column)
    end
  end

  def self.define_getter(column)  #make private
    define_method(column) do
      self.attributes[column]
    end
  end

  def self.define_setter(column) #make private
    setter_name = "#{column.to_s}=".to_sym
    define_method(setter_name) do |value|
       self.attributes[column] = value
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    return @table_name unless @table_name.nil?

    @table_name = self.deduce_table_name
  end

  def self.deduce_table_name #make private
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

    "#{words.join('_')}s"
  end

  def self.all
    table_rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    self.parse_all(table_rows)
  end

  def self.parse_all(table_rows)
    table_rows.map do |row|
      self.new(row)
    end
  end

  def self.find(id)
    entry = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL

    return nil if entry.length == 0
    self.new(entry.first)
  end

  def initialize(params = {})
    @columns = self.class.columns

    params.each_key do |key|
      key = key.to_sym if key.class == String
      raise "unknown attribute '#{key}'" unless @columns.include?(key)
    end



    params.each do |key, val|
      key_writer_method = "#{key.to_s}=".to_sym
      send(key_writer_method, val)
    end
  end

  def verify_valid_column(params) #make private
    params.each_key do |key|
      raise "unknown attribute #{key}" unless @columns.include?(key)
    end
  end

  def attributes
    @attributes = {} if @attributes.nil?

    @attributes
  end

  def attribute_values
    self.class.columns.map do |column|
      attribute = self.send(column)
    end
  end

  def insert #will not work for tables with only primary keys
    columns_arr = self.class.columns.to_a
    columns_without_primary = columns_arr.drop(1)

    question_marks = (["?"] * columns_without_primary.count)
    question_marks = question_marks.join(", ")

    columns_without_primary = columns_without_primary.join(', ')

    attr_values = self.attribute_values
    attr_values_without_primary = attr_values.drop(1)

    DBConnection.execute(<<-SQL, *attr_values_without_primary)
      INSERT INTO
        #{self.class.table_name} (#{columns_without_primary})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    attr_values = self.attribute_values
    attr_values_without_primary = attr_values.drop(1)

    columns_arr = self.class.columns.to_a
    columns_without_primary = columns_arr.drop(1)

    columns_interpolated = columns_without_primary.map do |column|
       "#{column} = ?"
    end
    columns_interpolated = columns_interpolated.join(', ')

    DBConnection.execute(<<-SQL, *attr_values_without_primary, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{columns_interpolated}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? self.insert : self.update
  end
end




#tests
# class BigDog < SQLObject
#
# end
#
# puts BigDog.table_name
#table names work

#
