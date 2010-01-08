class Questionnaire < ActiveRecord::Base
  has_many :object_item_values
  belongs_to :research

  def prepare_to_save(answers, research_id)
    unless answers.nil? 
      self.validate_obligatory_questions(answers, research_id)
      if self.errors.empty?
        self.save #Now, it has an ID to proper associations
        self.research_id = research_id
        self.associate(answers); self.incomplete = false
        true
      else
        false
      end
    else
      false
    end
  end

  def associate(new_answers)
    new_answers.keys.each do |item_id|
      unless Item.find(item_id.to_i).is_text?
        new_answers[item_id].each do |item_value_id|
          self.associate_new_ivalue(item_id.to_i, item_value_id.to_i)
        end
      else
        self.associate_new_text(item_id.to_i, new_answers[item_id]["info"])      
      end
    end
  end      

  def validate_obligatory_questions(answers, research_id)
    #Get obligatory questions from research
    obligatory = Research.find(research_id).questions.find_all { |question| question.is_optional == false }

    obligatory.each do |oblig_question|
      #Check if an answer to every obligatory question was passed
      #TODO Check if a valid answer is passed.
      unless answers.has_key?(oblig_question.id.to_s) 
        errors.add_to_base("Question #{oblig_question.info} must be answered.")
      end
    end
  end

protected
  def associate_new_ivalue(item_id, item_value_id)
    ObjectItemValue.create(:questionnaire_id => self.id, :item_value_id => item_value_id, :item_id => item_id)
    self.save
  end

  def associate_new_text(item_id, info)
    ObjectItemValue.create(:questionnaire_id => self.id, :item_id => item_id, :info => info)
    self.save
  end 
end
