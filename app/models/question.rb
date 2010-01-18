class Question < Item

#  has_many :object_item_values, :foreign_key => :item_id

  validates_numericality_of :min_answers, :integer_only => true, :gte => 0
  validates_numericality_of :max_answers, :integer_only => true, :gte => 0


  before_save :define_answers_quantity
  validate do |b|
    b.min_before_max_answers
  end

  has_many :item_values, :foreign_key => :item_id, :before_add => [ Proc.new { |p,d| raise ":active_survey_cant_receive_alternatives" if Research.find(p.research_id).is_active } ], :order => "position"

  HTML_TYPES = { 0 => "multiple_selection",
    1 => "single_selection",
    2 => "pure_text",
    3 => "radiobutton",
    4 => "checkbox"
  }

  def is_text?
    self.html == "pure_text"
  end

  def html
    HTML_TYPES[html_type.to_i]
  end


  def reorder_item_values(position)
    self.item_values.each { |ivalue| if ivalue.position >= position; ivalue.position+= 1; ivalue.save; end }
  end

  def update_positions(new_position, old_position)
    if new_position >  old_position
      self.item_values.each { |i| if i.position > old_position and i.position <= new_position; i.position -= 1; i.save; end }
    elsif new_position <  old_position
      self.item_values.each { |i| if i.position < old_position and i.position >= new_position; i.position += 1; i.save; end }
    end
  end

  def self.html_types
    HTML_TYPES
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
    if answers.has_key?(self.id.to_s)
      if self.is_text?
        valid = self.validate_text_content(answers[self.id.to_s]["info"])
      else
        valid = self.validate_alternatives(answers[self.id.to_s])
      end
      valid
    else
      false
    end
  end

protected

  def validate_text_content(text_answer)
    not text_answer.nil? and not text_answer.gsub(/[" "]/, "").empty?
  end

  def validate_alternatives(alternatives)
    alternatives = [alternatives] if alternatives.kind_of?(String)
    alternatives.count <= self.max_answers and alternatives.count >= self.min_answers
  end 

  def define_answers_quantity
    #Types that accept only one answer, or no answers if there are no alternatives
    if self.html != "checkbox" and self.html != "multiple_selection"
      self.min_answers = self.is_text? ? 0 : 1
      self.max_answers = self.min_answers
    end
  end

end
