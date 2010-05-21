class Conditional < ActiveRecord::Base
  belongs_to :question
  belongs_to :item_value

  OPERATORS = { 0 => "#{t(:different)}",
                     1 => "#{t(:equals)}"}

  def self.operators
    OPERATORS.invert.map
  end
 
  #TODO Make tests
  def self.stringify_relation(question, alt)
    require 'pp'
    rel = Conditional.find(:first, :conditions => {:question_id => question.id, :item_value_id => alt.id}).relation
    str = "#{Question.find(alt.item_id).info} #{t(:is)} " + OPERATORS[rel]
    str += rel == 0 ? "of " : "to "
    str += "#{alt.info}."
    pp str
    str 
  end
end
