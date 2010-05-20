class Conditional < ActiveRecord::Base
  belongs_to :question
  belongs_to :item_value

  OPERATORS = { 0 => "#{t(:different)}",
                     1 => "#{t(:equal)}"}

  #TODO Make tests
  def self.operators
    OPERATORS.invert.map
  end
end
