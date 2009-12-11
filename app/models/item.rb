class Item < ActiveRecord::Base

  belongs_to :research
  validates_presence_of:research_id, :position, :info
  before_save :define_answers_quantity
  validate do |b|
    b.min_before_max_answers
    b.max_answers_value
  end
  has_many :item_values, :before_add => [ Proc.new { |p,d| raise ":active_survey_cant_receive_alternatives" if Research.find(p.research_id).is_active } ], :order => "position"

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
    #FIXME Inefficient algorithm; Keep @item.item_values sorted
    self.item_values.each { |ivalue| if ivalue.position >= position; ivalue.position+= 1; ivalue.save; end }
  end

  def update_positions(new_position, old_position)
    #FIXME Inefficient algorithm; Keep @item.item_values sorted
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
    if min_answers > max_answers
      errors.add_to_base("The minimum quantity of expected answers must be smaller than the maximum quantity of expected answers.")
    end 
  end

  def max_answers_value
    if self.max_answers > self.item_values.count
      errors.add_to_base("The maximum quantity of expected answers can't be bigger than the maximum quantity of alternatives.") 
    end 
  end
 
private
 
  def define_answers_quantity
    #Types that accept only one answer, or no answers if there are no alternatives
    if self.html != "checkbox" and self.html != "multiple_selection"
      self.min_answers = self.item_values.empty? ? 0 : 1
      self.max_answers = self.min_answers 
    end 
  end

end
