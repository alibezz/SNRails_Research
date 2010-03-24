module Survey::SurveysHelper

  def role_id(user, survey)
    assignment = user.role_assignments.detect{|r| r.resource_id == survey.id}
    return assignment.role_id if assignment
    nil
  end

end
