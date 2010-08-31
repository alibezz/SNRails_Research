require File.dirname(__FILE__) + '/../test_helper'

class LSSurveyParserTest < Test::Unit::TestCase
  def setup
    @csv_data = LSSurveyParser.new(File.dirname(__FILE__) + '/../data/limesurvey_survey_94328.csv')
    @user = create_user
  end 

  def test_whether_initialize_loads_csv
    csv = LSSurveyParser.new(File.dirname(__FILE__) + '/../data/limesurvey_survey_94328.csv')
    assert !csv.lines.blank?
    assert_equal csv.lines, CSV.readlines(File.dirname(__FILE__) + '/../data/limesurvey_survey_94328.csv')
  end 

  def test_import_survey
    survey = @csv_data.import_survey(@user)
    assert survey
    assert survey.save
    assert_equal survey.user_id, @user.id
    assert_equal survey.title, "Teste pesquisa"
    assert_equal survey.subtitle, "Pesquisa para teste"
    assert_equal survey.introduction, "Texto de boas-vindas"
  end

  def test_load_pages
    assert_equal @csv_data.pages, [["gid","sid","group_name","group_order","description","language"], 
                                   ["60","94328","Teste grupo","0","","pt-BR"]]
  end

  def test_import_sections
    survey = @csv_data.import_survey(@user)
    @csv_data.import_sections(survey)
    survey.reload

    assert !survey.sections.empty?
    assert survey.sections.count, 1
    
    section = survey.sections.first
    assert_equal section.position, 0
    assert_equal section.page_id, 1
    assert_equal section.info, "Teste grupo"
    assert_equal section.survey_id, survey.id
  end

  def test_import_questions
    survey = @csv_data.import_survey(@user)
    @csv_data.import_questions(survey)
    survey.reload

    assert !survey.questions.empty?
    assert_equal survey.questions.count, 7

    assert_equal survey.questions[0].html_type, Item.html_types.invert["radiobutton"]
    assert_equal survey.questions[1].html_type, Item.html_types.invert["single_selection"]
    assert_equal survey.questions[2].html_type, Item.html_types.invert["single_selection"]
    assert_equal survey.questions[3].html_type, Item.html_types.invert["pure_text"]
    assert_equal survey.questions[4].html_type, Item.html_types.invert["multiple_selection"]
    assert_equal survey.questions[5].html_type, Item.html_types.invert["multiple_selection"]
    assert_equal survey.questions[6].html_type, Item.html_types.invert["single_selection"]

    assert_equal survey.questions.first.info, "Teste de pergunta<br />"
    assert_equal survey.questions.first.page_id, 1
    assert_equal survey.questions.first.survey_id, survey.id
    assert survey.questions.first.position < survey.questions.last.position

    assert_equal survey.questions.last.item_values.count, 2
    assert_equal survey.questions.last.item_values.first.info, "#{t(:yes)}"
    assert_equal survey.questions.last.item_values.last.info, "#{t(:no)}"

  end

  def test_import_alternatives
    survey = @csv_data.import_survey(@user)
    question_original_ids = @csv_data.import_questions(survey)
    @csv_data.import_alternatives(question_original_ids)
    survey.reload

    survey.questions.each { |question|
      if question.html_type == Item.html_types.invert["pure_text"] 
        assert question.item_values.empty?
      else
        assert !question.item_values.empty?
      end
    }

    assert_equal survey.questions[0].item_values.count, 2
    assert_equal survey.questions[1].item_values.count, 1
    assert_equal survey.questions[2].item_values.count, 11
    assert_equal survey.questions[4].item_values.count, 3
    assert_equal survey.questions[5].item_values.count, 2
    assert_equal survey.questions[6].item_values.count, 2

    assert_equal survey.questions[0].item_values.first.info, "test_answer"
    assert_equal survey.questions[0].item_values.last.info, "test_answer2"
    assert survey.questions[0].item_values.first.position < survey.questions[0].item_values.last.position
  end

  def test_import_conditionals
    survey = @csv_data.import_survey(@user)
    question_original_ids = @csv_data.import_questions(survey)
    alts_original_ids = @csv_data.import_alternatives(question_original_ids)
    @csv_data.import_conditionals(question_original_ids, alts_original_ids)
    survey.reload

    assert survey.questions[0].conditionals.empty?
    assert !survey.questions[1].conditionals.empty?
    assert !survey.questions[2].conditionals.empty?
    assert !survey.questions[3].conditionals.empty?
    assert survey.questions[4].conditionals.empty?
    assert survey.questions[5].conditionals.empty?
    assert survey.questions[6].conditionals.empty?

    assert_equal survey.questions[1].conditionals.count, 1
    assert_equal survey.questions[1].conditionals.first.question_id, survey.questions[1].id
    assert_equal survey.questions[1].conditionals.first.item_value_id, survey.questions[0].item_values.first.id
    assert_equal survey.questions[1].conditionals.first.relation, Conditional.hash_ops.invert["#{I18n.t(:equals)}"] 
 
    assert_equal survey.questions[2].conditionals.count, 1
    assert_equal survey.questions[2].conditionals.first.question_id, survey.questions[2].id
    assert_equal survey.questions[2].conditionals.first.item_value_id, survey.questions[1].item_values.first.id
    assert_equal survey.questions[2].conditionals.first.relation, Conditional.hash_ops.invert["#{I18n.t(:equals)}"] 
 
    assert_equal survey.questions[3].conditionals.count, 1
    assert_equal survey.questions[3].conditionals.first.question_id, survey.questions[3].id
    assert_equal survey.questions[3].conditionals.first.item_value_id, survey.questions[2].item_values[2].id
    assert_equal survey.questions[3].conditionals.first.relation, Conditional.hash_ops.invert["#{I18n.t(:different)}"] 
  end

  def test_find_content_in_csv
    assert @csv_data.find_content(["bli"], ["bli"]).blank?
    lines = @csv_data.find_content(["# CONDITIONS TABLE"], ["# LABELSETS TABLE"])
    assert !lines.blank?
    assert_equal lines, [["# CONDITIONS TABLE"], ["#"],
                        ["cid", "qid", "scenario", "cqid", "cfieldname", "method", "value"],
                        ["2247", "831", "1", "813", "94328X60X813", "==", "1"],
                        ["2248", "832", "1", "831", "94328X60X831", "==", "1"],
                        ["573", "1600", "1", "832", "94328X60X832", "!=", "3"],
                        [nil], ["#"]]
  end

  def test_extract_content_in_csv
    assert @csv_data.extract_content(0, 0).blank? 
    assert @csv_data.extract_content(0, -1).blank? 
    lines = @csv_data.extract_content(0, 2)
    assert !lines.blank?
    assert_equal lines, [["# LimeSurvey Survey Dump"], ["# DBVersion 138"]]
  end

  def test_get_question_html_type
    assert_equal @csv_data.html_type("L"), Item.html_types.invert["radiobutton"]
    assert_equal @csv_data.html_type("!"), Item.html_types.invert["single_selection"]
    assert_equal @csv_data.html_type("S"), Item.html_types.invert["pure_text"]
    assert_equal @csv_data.html_type("T"), Item.html_types.invert["pure_text"]
    assert_equal @csv_data.html_type("M"), Item.html_types.invert["multiple_selection"]
  end
 
  def test_get_conditionals_relations
    assert_equal @csv_data.cond_relation("!="), Conditional.hash_ops.invert["#{I18n.t(:different)}"]
    assert_equal @csv_data.cond_relation("=="), Conditional.hash_ops.invert["#{I18n.t(:equals)}"]
  end

  def test_get_survey_pages
    pages = @csv_data.pages
    assert !pages.blank?
    assert_equal pages, [["gid","sid","group_name","group_order","description","language"],
                         ["60","94328","Teste grupo","0","","pt-BR"]]
  end

  def test_yes_no_alts
    survey = @csv_data.import_survey(@user)
    q = Question.create(:survey_id => survey.id, :info => "q1", :position => 1)
    count = q.item_values.count
    @csv_data.yes_no_alts(q)
    q.reload
    assert_equal count + 2, q.item_values.count
    assert q.item_values.first.info, "#{t(:yes)}"
    assert q.item_values.last.info, "#{t(:no)}"
  end

  def test_import_csv
    survey = @csv_data.import_csv(@user)
    survey.reload

    assert survey
    assert_equal survey.questions.count, 7 
    assert_equal survey.sections.count, 1
    
    assert_equal survey.questions[0].item_values.count, 2
    assert_equal survey.questions[1].item_values.count, 1
    assert_equal survey.questions[2].item_values.count, 11
    assert_equal survey.questions[4].item_values.count, 3
    assert_equal survey.questions[5].item_values.count, 2
    assert_equal survey.questions[6].item_values.count, 2

    assert survey.questions[0].conditionals.empty?
    assert !survey.questions[1].conditionals.empty?
    assert !survey.questions[2].conditionals.empty?
    assert !survey.questions[3].conditionals.empty?
    assert survey.questions[4].conditionals.empty?
    assert survey.questions[5].conditionals.empty?
    assert survey.questions[6].conditionals.empty?

  end
end
