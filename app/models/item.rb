class Item < ActiveRecord::Base

  belongs_to :survey
  validates_presence_of :survey_id, :position, :info

  after_save :update_survey_num_pages
  after_destroy :update_survey_num_pages

  HTML_TYPES = { 0 => "multiple_selection",
    1 => "single_selection",
    2 => "pure_text",
    3 => "radiobutton",
    4 => "checkbox",
    5 => "section"
  }

  def html
    HTML_TYPES[html_type.to_i]
  end


  def self.html_types
    HTML_TYPES
  end

  def update_survey_num_pages
   r = Survey.find(self.survey_id)
   r.number_of_pages = r.number_of_pages || 0
   r.save! 
  end

  def define_position
    r = Survey.find(self.survey_id)
    self.position = r.items.blank? ? 1 : r.items.maximum(:position) + 1 
  end
end
