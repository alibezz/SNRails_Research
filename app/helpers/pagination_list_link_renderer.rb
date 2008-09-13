class PaginationListLinkRenderer < WillPaginate::LinkRenderer

  def to_html
    links = @options[:page_links] ? windowed_links : []

    html = links.join(@options[:separator])
    @options[:container] ? @template.content_tag(:ul, html, html_attributes) : html
  end

  protected

  def windowed_links
    visible_page_numbers.map { |n| page_link_or_span(n, (n == current_page ? 'current' : nil)) }
  end

  def page_link_or_span(page, span_class, text = nil)
    text ||= page.to_s
    if page && page != current_page
      page_link(page, text, :class => span_class)
    else
      page_span(page, text, :class => span_class)
    end
  end

  def page_link(page, text, attributes = {})
    @template.content_tag(:li, @template.link_to(text, url_options(page)), attributes.merge(:id => "page_#{page}"))
  end

  def page_span(page, text, attributes = {})
#      bli = render :inline => 'pagination_list_link_renderer/page'
    @template.content_tag(:li, 
       text,
#      render :template => 'pagination_list_link_renderer/page' ,
#      text,
#sortable_element('page_3', 
#        :complete => visual_effect(:highlight, "page_#{page}"), 
#        :url => { :action => "set_item_to_page"},
#        :failure => "$('error').innerHTML= request.responseText",
#        :constraint => false,
#        :dropOnEmpty => true,
#        :containment =>  ['list_items']), 
      attributes.merge(:id => "page_#{page}")
    )
  end

  def url_options(page)
    options = { param_name => page, :action => 'index' }
    # page links should preserve GET parameters
    options = params.merge(options) if @template.request.get?
    options.rec_merge!(@options[:params]) if @options[:params]
    return options
  end

end
