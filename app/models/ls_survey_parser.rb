class LSSurveyParser
  require 'csv'
  attr_accessor :lines
  QUESTION_TYPES = {"L" => "radiobutton", "!" => "single_selection", "M" => "multiple_selection",
                    "T" => "pure_text", "S" => "pure_text", "Y" => "single_selection"}
  
  CONDITIONAL_TYPES = {"!=" => "#{I18n.t(:different)}", "==" => "#{I18n.t(:equals)}"}

  def initialize(filename)
    #FIXME Deal with HTML accent marks
    @lines = CSV.readlines(filename)
  end

  def import_csv(user)
    survey = self.import_survey(user)
    self.import_sections(survey)
    questions = self.import_questions(survey)
    alts = self.import_alternatives(questions)
    self.import_conditionals(questions, alts)
    survey
  end
  
protected unless Rails.env == 'test' 

  def import_survey(user)
    #The user is necessary to identify who's gonna be the owner of the imported survey
    survey_info = self.find_content(["# SURVEYS_LANGUAGESETTINGS TABLE"],["# QUOTA TABLE"])
    header = survey_info.find {|line| line[0] =~ /survey_id/}
    body = survey_info[survey_info.index(header) + 1]
    
    @survey = Survey.create(:title => body[header.index("surveyls_title")],
                            :introduction => body[header.index("surveyls_welcometext")],
                            :subtitle => body[header.index("surveyls_description")],
                            :user_id => user.id)
  end
 
    def import_sections(survey)
    section_info = self.pages
    header = section_info.find{|line| line[0] == "gid"}
    i = 1
    while i < section_info.count
      Section.create(:survey_id => survey.id,
                     :position => 0,
                     :page_id => i,
                     :info => section_info[i][header.index("group_name")])
      i += 1
    end
  end
 
  def import_questions(survey)
    question_info = self.find_content(["# QUESTIONS TABLE"], ["# ANSWERS TABLE"]) 
    header = question_info.find {|line| line[0] == "qid"}
    ref_page = self.pages[1][0] #0 is the position of group id (gid), which is the page id
    question_ids = {}

    i = question_info.index(header) + 1
    while question_info[i] != [nil]
      q = Question.create(:survey_id => survey.id,
                      :html_type => self.html_type(question_info[i][header.index("type")]),
                      :info => question_info[i][header.index("question")],
                      :position => question_info[i][header.index("question_order")],
                      :page_id => question_info[i][header.index("gid")].to_i % ref_page.to_i + 1)

      if question_info[i][header.index("type")] == "Y" and q
        self.yes_no_alts(q)
      end

      question_ids.merge!({question_info[i][header.index("qid")] => q.id})
      i += 1
    end
    question_ids
  end

  def import_alternatives(question_ids)
    alt_info = self.find_content(["# ANSWERS TABLE"], ["# CONDITIONS TABLE"])
    header = alt_info.find {|line| line[0] == "qid"}
    alt_ids = {}
    
    i = alt_info.index(header) + 1
    while alt_info[i] != [nil]
      a = ItemValue.create(:position => alt_info[i][header.index("sortorder")].to_i,
                           :item_id => question_ids[alt_info[i][header.index("qid")]],
                           :info => alt_info[i][header.index("answer")])
      #The line below relates the key [question_id, alt_position] to the alt id
      alt_ids.merge!({"#{alt_info[i][header.index("qid")]}#{alt_info[i][header.index("code")]}" => a.id})
      i += 1
    end
    alt_ids
  end 

  def import_conditionals(question_ids, alt_ids)
    cond_info = self.find_content(["# CONDITIONS TABLE"], ["# LABELSETS TABLE"])
    header = cond_info.find {|line| line[0] == "cid"}
    i = cond_info.index(header) + 1

    while cond_info[i] != [nil]
      Conditional.create(:question_id => question_ids[cond_info[i][header.index("qid")]],
                 :item_value_id => alt_ids["#{cond_info[i][header.index("cqid")]}#{cond_info[i][header.index("value")]}"],
                 :relation => self.cond_relation(cond_info[i][header.index("method")]))
      i += 1
    end
  end

  #TODO Make tests
  def import_question_attributes(question_ids)
    #This method only imports "min_answers" and "max_answers" attributes
   attributes_info = self.find_content(["# QUESTION_ATTRIBUTES TABLE"], ["# ASSESSMENTS TABLE"])
  end

  def find_content(first_label, last_label)
    self.extract_content(@lines.index(first_label), @lines.index(last_label))
  end

  def extract_content(first_index, last_index)
    @lines.slice(first_index, last_index - first_index) unless last_index.blank? or first_index.blank?
  end
  
  def html_type(question_type)
    #gets the int that correspond to question_type
    #these numbers are defined in the Item model
    Item.html_types.invert[QUESTION_TYPES[question_type]] 
  end

  def cond_relation(relation)
    Conditional.hash_ops.invert[CONDITIONAL_TYPES[relation]]
  end

  def pages
    pages_info = self.find_content(["# GROUPS TABLE"], ["# QUESTIONS TABLE"])
    header = pages_info.find {|line| line[0] == "gid"}

    pages = []; pages << header
    i = pages_info.index(header) + 1
    while pages_info[i] != [nil]
      pages << pages_info[i]
      i += 1
    end
    pages
  end

  def yes_no_alts(question)
    ItemValue.create(:item_id => question.id, :position => 1, :info => "#{t:yes}")
    ItemValue.create(:item_id => question.id, :position => 2, :info => "#{t:no}")
  end
end
