# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def title(name)
    content_tag(:h1, name, :class => 'title')
  end
 
  def subtitle(name)
    content_tag(:h2, name, :class => 'subtitle')
  end

  def survey_buttons(survey_id)
    content = ""    
    unless current_user.is_collaborator?(survey_id)
      content << content_tag(:a, link_to(t(:edit), edit_survey_survey_url(survey_id)))
    end
    if current_user.is_moderator?(survey_id) or current_user.is_administrator?
      content << " " + content_tag(:a, link_to(t(:destroy), {:action => "destroy", :controller => "survey/surveys", :id => survey_id}, :confirm => t(:message_confirmation), :method => :delete))
    end
    content 
  end

  
  def login_bar
    content_tag(:ul,
      [
        (content_tag(:li, link_to(t(:login), login_path)) unless logged_in?),
        (content_tag(:li, link_to(t(:logout), logout_path)) if logged_in?),
        (content_tag(:li, link_to(t(:register), signup_path )) unless logged_in?),
      ].join("\n"),
      :class => 'login_bar', :id => 'login_bar'
    )
  end

  def select_type
    @types = Question.html_types.invert.map
    select("item", "html_type", @types)
  end
  
  def admin_bar
    content_tag(:ul,
      [
        (content_tag(:li, link_to(t(:system_roles), admin_roles_path)))
      ].join("\n"),
      :class => 'admin_bar', :id => 'admin_bar'
    )
  end

  #FIXME make this test
   def observe_item_select(survey_id, item_id)
    observe_field(
                  :questions,
                  :url => filter_survey_survey_item_path(survey_id, item_id),
                  :with =>  "'value=' + value",
                  :on => :onchange
    )
  end

  #sncharts
  def include_sncharts
    scripts = "<!-- SNCharts Javascript -->\n"
    %w(MochiKit excanvas PlotKit_Packed prototype custom sncharts).each do |js|
      # The 'custom' is a JS view for the action
      src = js == 'custom' ? url_for(:action => action_name, :format => 'js') : "/javascripts/sncharts/js/#{js}.js"
      scripts += content_tag(:script, nil, :src => src, :type => "text/javascript") + "\n"
    end
    scripts += stylesheet_link_tag '/javascripts/sncharts/sncharts.css'
  end

  def include_sncharts_if_needed
    include_sncharts unless @uses_sncharts.blank?
  end

  def sncharts_periods
    content = []
    content << t(:label_from)
    content << t(:label_to)
    content_tag(:p, content.join(' '), :id => 'charts-period')
  end

 #sncharts2
  def include_sncharts2
    content_tag :script, nil, :src => "/javascripts/sncharts2/sncharts2/install.js", :id => "sncharts2-script"
	end

  def include_sncharts2_if_needed
	  include_sncharts2 unless @uses_sncharts2.blank?
	end

  def sncharts2_periods
    content = []
    content << t(:label_from)
    content << t(:label_to)
    content_tag(:span, content.join(' '), :id => 'sncharts2-period')
  end

  def random_string
    (0...10).map{  ('a'..'z').to_a.concat(('A'..'Z').to_a)[rand(52)] }.join + Time.now.to_i.to_s
  end
end
