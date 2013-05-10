class Requirements
  attr_accessor :size, :power_a, :power_b, :power_c
  def initialize(size,power_a,power_b,power_c)
    @size=size
    @power_a=power_a
    @power_b=power_b
    @power_c=power_c
  end
end