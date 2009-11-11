class Item < ActiveRecord::Base

  belongs_to :research
  validates_presence_of:research_id, :position
  has_many :item_values

  HTML_TYPES = { 0 => "multiple_selection",
    1 => "single_selection",
    2 => "pure_text"
  }
 
  def is_text?
    self.html == "pure_text"
  end

  def html
    HTML_TYPES[html_type.to_i]
  end

protected
  def self.html_types
    HTML_TYPES
  end

end
