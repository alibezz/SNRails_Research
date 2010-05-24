class Conditional < ActiveRecord::Base
  belongs_to :question
  belongs_to :item_value

  OPERATORS = { 0 => "#{I18n.t(:different)}",
                     1 => "#{I18n.t(:equals)}"}

  #TODO Make tests
  def self.operators
    OPERATORS.invert.map
  end
 
  def self.stringify_relation(question, alt)
    rel = Conditional.find(:first, :conditions => {:question_id => question.id, :item_value_id => alt.id}).relation
    str = "#{Question.find(alt.item_id).info} #{I18n.t(:is)} " + OPERATORS[rel]
    str += " #{alt.info}."
    str 
  end

  #TODO Make tests
  def self.has_key?(relation)
    OPERATORS.has_key?(relation.to_i)
  end
 
  #TODO Make tests
  def self.hash_ops
    OPERATORS
  end
end
