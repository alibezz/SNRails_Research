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
      content << " " + content_tag(:a, link_to(t(:destroy), {:action => "destroy", :id => survey_id}, :confirm => t(:message_confirmation), :method => :delete))
    end
    content 
  end

  
  #FIXME make this test
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

  #FIXME make this test
  def select_type
    @types = Question.html_types.invert.map
    select("item", "html_type", @types)
  end
  
  #FIXME make this test
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

end
