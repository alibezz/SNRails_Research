# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def title(name)
    name
  end
 
  #FIXME make this test
  def login_bar
    content_tag(:ul,
      [
        (content_tag(:li, link_to(_('Login'), login_path)) unless logged_in?),
        (content_tag(:li, link_to(_('Logout'), logout_path)) if logged_in?),
        (content_tag(:li, link_to(_('Register'), signup_path )) unless logged_in?),
      ].join("\n"),
      :class => 'login_bar', :id => 'login_bar'
    )
  end

end
