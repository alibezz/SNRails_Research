module Admin::ResearchesHelper

  def role_id(user, research)
    assignment = user.role_assignments.detect{|r| r.resource_id == research.id}
    return assignment.role_id if assignment
    nil
  end

end
