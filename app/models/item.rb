class Item < ActiveRecord::Base

  belongs_to :research
  validates_presence_of :research_id, :position, :info
  after_save :update_research_num_pages

  def update_research_num_pages
   r = Research.find(self.research_id)
   r.number_of_pages = r.items.maximum(:page_id)
   r.save! 
  end
end
