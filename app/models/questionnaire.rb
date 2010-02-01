class Questionnaire < ActiveRecord::Base
  has_many :object_item_values
  belongs_to :research

  #FIXME This should be a transaction
  def prepare_to_save(answers, research_id)
    self.validate_questions(answers, research_id)
    return false unless self.errors.empty?
    
    self.save 
    self.research_id = research_id
    self.associate(answers); self.incomplete = false
    true
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

  def validate_questions(answers, research_id)
    unless answers.blank?
      questions = Research.find(research_id).questions
      self.validate_answers(questions, answers)
      obligatory = questions.find_all { |question| question.is_optional == false }
      self.validate_obligatory_questions(obligatory, answers)
    else
      errors.add_to_base("#{t(:no_answers)}")
    end
  end    

  def validate_answers(questions, answers)
    questions.each do |question|
      unless question.validate_answers(answers[question.id.to_s])
        if question.is_text?
          errors.add_to_base("#{question.info} #{t(:must_be_answered)}")
        else 
          errors.add_to_base("#{t(:number_of_answers_to)} #{question.info} #{t(:must_be_between)}                                                               #{question.min_answers.to_s} #{t(:and)} #{question.max_answers.to_s}")
        end
      end
    end
  end

  def validate_obligatory_questions(obligatory, answers)
    obligatory.each do |question|
      unless question.validate_answers_presence(answers[question.id.to_s]) 
        errors.add_to_base("#{t(:question)} #{question.info} #{t(:is_obligatory)}")
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
