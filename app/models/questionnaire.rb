class Questionnaire < ActiveRecord::Base
  has_many :object_item_values
  belongs_to :research

  def prepare_to_save(answers, research_id)
    self.validate_obligatory_questions(answers, research_id)
    if self.errors.empty?
      self.save #Now, it has an ID to proper associations
      self.research_id = research_id
      self.associate(answers)
      self.incomplete = false
      true
    else
      false
    end
  end

  def associate(new_answers)
    new_answers.keys.each do |item_id|
      unless self.object_item_values.empty?
        self.destroy_old_answers(item_id)
      end
      new_answers[item_id].each do |item_value_id|
        self.associate_new_answer(item_id.to_i, item_value_id.to_i)
      end
    end
  end      

  def validate_obligatory_questions(answers, research_id)
    #Get obligatory items from research
    obligatory = Research.find(research_id).items.find_all { |item| item.is_optional == false }
    obligatory.each do |oblig_question|
      #Check if an answer to every obligatory question was passed
      #TODO Check if a valid answer is passed.
      unless answers.has_key?(oblig_question.id.to_s) 
        errors.add_to_base("Question #{oblig_question.info} must be answered.")
      end
    end
  end

protected

  #TODO Guarantee that an answer is submitted only once, then all these costful checkings will become unnecessary.
  def destroy_old_answers(item_id)
    ObjectItemValue.all(:conditions => {:questionnaire_id => self.id, :item_id => item_id.to_i}).each(&:destroy)
  end

  def associate_new_answer(item_id, item_value_id)
    ObjectItemValue.create(:questionnaire_id => self.id, :item_value_id => item_value_id, :item_id => item_id)
    self.save
  end
end
