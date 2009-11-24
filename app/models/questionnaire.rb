class Questionnaire < ActiveRecord::Base
  has_many :object_item_values
  belongs_to :research

  def associate(new_answers)
    new_answers.keys.each do |item_id|

      #destroy old answers
      self.destroy_old_answers(item_id)

      #create new answers
      new_answers[item_id].each do |item_value_id|
        self.associate_new_answer(item_id, item_value_id)
      end

    end
    self.save
  end      

protected

  #TODO Guarantee that an answer is submitted only once, then all these checkings will become unnecessary.
  def destroy_old_answers(item_id)
    answers = self.object_item_values.each do |answer| 
      if answer.item_id == item_id.to_i
        self.object_item_values.delete(answer)
        self.save!
      end 
    end
  end

  def associate_new_answer(item_id, item_value_id)
    ObjectItemValue.create(:questionnaire_id => self.id, :item_value_id => item_value_id.to_i, :item_id => item_id.to_i)
    self.save! 
  end

end
