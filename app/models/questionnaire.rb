class Questionnaire < ActiveRecord::Base
  has_many :object_item_values
  belongs_to :research

  def associate(new_answers)
      new_answers.keys.each do |item_id|
        unless self.object_item_values.empty?
          self.destroy_old_answers(item_id)
        end
        new_answers[item_id].each do |item_value_id|
          self.associate_new_answer(item_id, item_value_id)
        end
      end
  end      

protected

  #TODO Guarantee that an answer is submitted only once, then all these costful checkings will become unnecessary.
  def destroy_old_answers(item_id)
    ObjectItemValue.all(:conditions => {:questionnaire_id => self.id, :item_id => item_id.to_i}).each(&:destroy)
  end

  def associate_new_answer(item_id, item_value_id)
    ObjectItemValue.create(:questionnaire_id => self.id, :item_value_id => item_value_id.to_i, :item_id => item_id.to_i)
    self.save! 
  end

end
