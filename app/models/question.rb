class Question < Item

#  has_many :object_item_values, :foreign_key => :item_id

  validates_numericality_of :min_answers, :integer_only => true, :gte => 0
  validates_numericality_of :max_answers, :integer_only => true, :gte => 0

  before_save :define_answers_quantity
  validate do |b|
    b.min_before_max_answers
  end

  has_many :item_values, :foreign_key => :item_id, :before_add => [ Proc.new { |p,d| raise "#{I18n.t(:active_survey_cant_receive_alternatives)}" if Survey.find(p.survey_id).is_active } ], :order => "position"

  has_many :conditionals
  has_many :dependencies, :class_name => "ItemValue", :through => :conditionals, :source => :item_value 

  named_scope :previous_pages, lambda { |p,s| {:conditions => ["page_id < ? AND survey_id = ?", p, s] }}
  named_scope :previous_positions, lambda {|p,po,s| {:conditions =>                                                                        ["page_id = ? AND position < ? AND survey_id = ?", p, po,s] }} 

  def self.html_types
    Item.html_types.invert.delete_if {|key, value| key == "section"}.invert
  end

  def is_text?
    self.html == "pure_text"
  end

  def min_before_max_answers
    if self.min_answers > self.max_answers
      errors.add_to_base("#{I18n.t(:minimum_quantity_answers_must_be_smaller_than_maximum_expected)}")
    end
  end

  def invalid_max_answers?
    self.max_answers > self.item_values.count
  end


  def validate_answers(answers)
    if self.is_text?
      self.validate_text_content(answers["info"])
    else
      self.validate_alternatives(answers)
    end
  end

  def validate_answers_presence(answers)
    return false if answers.blank?
    (self.is_text? and not answers["info"].blank?) or (not self.is_text?)   
  end

  def previous
     Question.previous_pages(self.page_id, self.survey_id) +                                                                      Question.previous_positions(self.page_id, self.position, self.survey_id)
  end

  def free_alts(item)
    self.item_values - item.dependencies
  end

  def create_dependency(alt, relation)
    unless alt.blank? or relation.blank? or not Conditional.has_key?(relation)
      Conditional.create(:relation => relation.to_i, :question_id => self.id, :item_value_id => alt.id) 
    end
  end

  def remove_deps(deps)
    deps.each do |dep|
      self.dependencies.delete(ItemValue.find(dep.to_i)) 
    end
  end

  #TODO Make tests
  def relations
    self.conditionals.map{|c| [c.item_value_id, c.relation]}                           
  end

  #TODO Make tests
  def needed_alts
    #relation == 1 => equals to relation #FIXME Change it!
    self.conditionals.find_all{|c| c.relation == 1}.map(&:item_value_id)
  end

#  #TODO Make tests
#  def other_alts(alt)
#    self.item_values.map(&:id) - [alt]
#  end
#
#  #TODO Make tests
#  def other_dep_quests(alt)
#    dep_quests = []
#    self.other_alts(alt).each do |a|
#      dep_quests.push(ItemValue.find(a).conds.map(&:id))
#    end
#    dep_quests
#  end

protected

  def validate_text_content(text_answer)
    return true if self.is_optional #if the question is optional, its content doesnt matter
    not text_answer.blank?
  end

  def validate_alternatives(alternatives)
    if alternatives.blank?
      self.is_optional
    else
      alternatives = [alternatives] if alternatives.kind_of?(String)
      alternatives.count <= self.max_answers and alternatives.count >= self.min_answers
    end
  end 

  def define_answers_quantity
    #Types that accept only one answer, or no answers if there are no alternatives
    if self.html != "checkbox" and self.html != "multiple_selection"
      self.min_answers = self.is_text? ? 0 : 1
      self.max_answers = self.min_answers
    end
  end
end
