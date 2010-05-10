class Question < Item

#  has_many :object_item_values, :foreign_key => :item_id

  validates_numericality_of :min_answers, :integer_only => true, :gte => 0
  validates_numericality_of :max_answers, :integer_only => true, :gte => 0

  before_save :define_answers_quantity
  validate do |b|
    b.min_before_max_answers
  end

  has_many :item_values, :foreign_key => :item_id, :before_add => [ Proc.new { |p,d| raise "#{t(:active_survey_cant_receive_alternatives)}" if Survey.find(p.survey_id).is_active } ], :order => "position"

  has_and_belongs_to_many :dependencies, :class_name => "ItemValue"

  def self.html_types
    Item.html_types.invert.delete_if {|key, value| key == "section"}.invert
  end

  def is_text?
    self.html == "pure_text"
  end

  def min_before_max_answers
    if self.min_answers > self.max_answers
      errors.add_to_base("#{t(:minimum_quantity_answers_must_be_smaller_than_maximum_expected)}")
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
