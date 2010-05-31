class Conditional < ActiveRecord::Base
  belongs_to :question
  belongs_to :item_value

  validates_presence_of :relation
  validates_uniqueness_of :item_value_id, :scope => :question_id

  OPERATORS = { 0 => "#{I18n.t(:different)}",
                     1 => "#{I18n.t(:equals)}"}

  def self.operators
    OPERATORS.invert.map
  end
 
  def self.stringify_relation(question, alt)
    rel = Conditional.find(:first, :conditions => {:question_id => question.id, :item_value_id => alt.id}).relation
    str = "#{Question.find(alt.item_id).info} #{I18n.t(:is)} " + OPERATORS[rel]
    str += " #{alt.info}."
    str 
  end

  def self.has_key?(relation)
    OPERATORS.has_key?(relation.to_i)
  end
 
  def self.hash_ops
    OPERATORS
  end
end
