module Survey::SurveysHelper
  #FIXME Make tests
  def role_id(user, survey)
    assignment = user.role_assignments.detect{|r| r.resource_id == survey.id}
    return assignment.role_id if assignment
    nil
  end

  #FIXME Make tests
  def paginate_survey(survey, page)
    pages = []
    survey.page_ids.each do |p|
      pages << content_tag(:li, "#{t(:move)} #{link_to(p, {:page => p})}",  {:id => "item_#{p}"})
    end
    content_tag(:ul, pages, {:id => 'page_links'})
  end

end
