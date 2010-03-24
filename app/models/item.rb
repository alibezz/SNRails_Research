class Item < ActiveRecord::Base

  belongs_to :survey
  validates_presence_of :survey_id, :position, :info

  after_save :update_survey_num_pages
  after_destroy :update_survey_num_pages

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
