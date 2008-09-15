class Research < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :introduction

  has_many :items

  # Get and array of integer that indicates the pages order and
  # set the item (questions and sections) to the correct order.
  def reorder_pages(pages_order = [])
    pages_order = pages_order.map{|o|o.to_i}
    for i in 1..self.number_of_pages do 
      if (pages_order[i-1] != i) 
        new_page = (pages_order[i-1] == i + 1) ? pages_order.index(i) + 1 : pages_order[i-1]
        old_page = i
        break
      end
    end

    new_items_page = self.items.find_all_by_page_id(new_page)
    
    self.items.update_all("page_id = #{new_page}", :page_id => old_page)
    self.items.update_all("page_id = #{old_page}", :id => new_items_page.map{|i|i.id})
  end

end
