#encoding: utf-8
class Widget
  attr_accessor :name, :size, :power_a, :power_b, :power_c

  def initialize(name, size, power_a, power_b, power_c)
    @name = name
    @size = size
    @power_a = power_a
    @power_b = power_b
    @power_c = power_c
  end

  def to_s
     @name
  end
end

