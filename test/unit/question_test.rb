require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < Test::Unit::TestCase

  def setup
    @types = Question.html_types
    @research = create_research
  end


  def test_is_text
   question = create_item(:type => 'Question', :research_id => @research.id, :html_type => @types.invert["pure_text"])
   assert question.is_text?

   question = create_item(:type => 'Question', :research_id => @research.id, :html_type => @types.invert["single_selection"])
   assert_equal false, question.is_text?
  end


  def test_reorder_item_values

    item = create_item(:type => 'Question', :research_id => @research.id)

    create_item_value(:position => 1, :item_id => item.id)
    create_item_value(:position => 2, :item_id => item.id)
    item.reorder_item_values(2); item.reload
    assert_equal item.item_values.first.position, 1
    assert_equal item.item_values.last.position, 3

  end

  def test_new_position_is_bigger_than_old_position

    item = create_item(:type => 'Question', :research_id => @research.id)

    create_item_value(:position => 1, :item_id => item.id)
    create_item_value(:position => 2, :item_id => item.id)
    create_item_value(:position => 3, :item_id => item.id)
    item.update_positions(3,1); item.reload

    assert_equal 1, item.item_values[0].position
    assert_equal 1, item.item_values[1].position
    assert_equal 2, item.item_values[2].position
    #Now, item_value with :position => 1 previously can be updated by the controller
  end

  def test_new_position_is_smaller_than_old_position

    item = create_item(:type => 'Question', :research_id => @research.id)

    create_item_value(:position => 1, :item_id => item.id)
    create_item_value(:position => 2, :item_id => item.id)
    create_item_value(:position => 3, :item_id => item.id)
    item.update_positions(1,3); item.reload

    assert_equal 2, item.item_values[0].position
    assert_equal 3, item.item_values[1].position
    assert_equal 3, item.item_values[2].position
    #Now, item_value with :position => 3 previously can be updated by the controller
  end

  def test_should_add_ivalues_only_if_research_is_inactive

    item = create_item(:type => 'Question', :research_id => @research.id)
    @research.reload
    @research.is_active = true; @research.save
    count = item.item_values.count
    ivalue = create_item_value
    assert_raise RuntimeError do
      raise item.item_values.push(ivalue)
    end
    assert_equal count, item.item_values.count
    @research.is_active = false; @research.save
    create_item_value(:item_id => item.id)
    @research.reload; item.reload
    assert_equal count + 1, item.item_values.count

  end

  def test_min_before_max_answers
    # :html_type => 0 is equivalent to multiple_selection
    item = create_item(:type => 'Question', :research_id => @research.id, :html_type => 0)
    create_item_value(:item_id => item.id)
    create_item_value(:item_id => item.id)
    item.reload

    item.max_answers = 1; item.min_answers = 2
    assert_equal false, item.save
    item.max_answers = 2; item.min_answers = 1
    assert item.save
  end

  def test_define_answers_quantity
    # :html_type => 1 is equivalent to single selection
    item = create_item(:type => 'Question', :research_id => @research.id, :html_type => 1)

    create_item_value(:item_id => item.id)
    item.reload; item.save
    assert_equal 1, item.max_answers
    assert_equal 1, item.min_answers

    item.max_answers = 2; item.min_answers = 1; item.save; item.reload
    assert_equal 1, item.max_answers
    assert_equal 1, item.min_answers #No matter what you set, it will be (min=1,max=1) because it's a single selection.
  end

  def test_invalid_max_answers
    # :html_type => 0 is equivalent to multiple_selection
    item = create_item(:type => 'Question', :research_id => @research.id, :html_type => 0, :min_answers => 1, :max_answers => 2)
    assert_equal true, item.invalid_max_answers?

    create_item_value(:item_id => item.id)
    create_item_value(:item_id => item.id)
    item.reload
    assert_equal false, item.invalid_max_answers?
  end

end
