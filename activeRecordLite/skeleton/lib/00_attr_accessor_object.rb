require('byebug')

class AttrAccessorObject
  def self.my_attr_accessor(*names) #protect against non symbols in names
    names.each do |name|
      raise 'invalid argument type' unless name.is_a?(Symbol)
      self.define_getter(name)
      self.define_setter(name)
    end
  end

  private

  def self.define_getter(name)
    define_method(name) do
      instance_variable = "@#{name.to_s}"
      self.instance_variable_get(instance_variable)
    end
  end

  def self.define_setter(name)
     name_with_equals = ("#{name.to_s}=")
     name_with_equals = name_with_equals.to_sym
     instance_variable = "@#{name.to_s}"

     define_method(name_with_equals) do |value|
       self.instance_variable_set(instance_variable, value)
     end
  end
end


# # test case
# class Inheriting < AttrAccessorObject
#   my_attr_accessor :x, :y
#
#   def initialize(x, y)
#     self.x = x
#     self.y = y
#   end
# end
#
# test = Inheriting.new('success', 'supersuccess')
# puts test.x
# puts test.y
