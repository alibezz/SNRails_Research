class Item < ActiveRecord::Base

  belongs_to :research
  validates_presence_of :research_id, :position, :info

  after_save :update_research_num_pages
  after_destroy :update_research_num_pages

  def update_research_num_pages
   r = Research.find(self.research_id)
   r.number_of_pages = r.number_of_pages || 0
   r.save! 
  end

  def define_position
    r = Research.find(self.research_id)
    self.position = r.items.blank? ? 1 : r.items.maximum(:position) + 1 
  end
end
