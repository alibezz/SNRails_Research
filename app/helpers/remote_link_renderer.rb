class RemoteLinkRenderer < WillPaginate::LinkRenderer
   def prepare(collection, options, template)
      @collection = collection
      @options    = options
      @template   = template
      # Added this one extra  line
      @remote = @options[:params].delete(:remote) || {}

      # reset values in case we're re-using this instance
      @total_pages = @param_name = @url_string = nil
    end

  def page_link_or_span(page, span_class = 'current', text = nil)
    text ||= page.to_s
    if page and page != current_page
      @template.link_to_remote(text, {:url => url_for(page), :method => :get}.merge(@remote))
    else
      @template.content_tag :span, text, :class => span_class
    end
  end
end

