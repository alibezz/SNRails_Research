module ResearchesHelper
  def paginate_research(research, page)
    pages = []
    research.page_ids.each do |p|
      pages << content_tag(:li, "#{p} #{link_to(p, {:page => p})}",  {:id => "item_#{p}"})
    end
    content_tag(:ul, pages, {:id => 'page_links'})
  end
end
