# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #FIXME make this test
  def title(name)
    name
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

   def observe_item_select(survey_id, item_id)
    observe_field(
                  :questions,
                  :url => filter_survey_survey_item_path(survey_id, item_id),
                  :with =>  "'value=' + value",
                  :on => :onchange
    )
  end

end
