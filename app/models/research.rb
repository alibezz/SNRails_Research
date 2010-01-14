class Research < ActiveRecord::Base

  #FIXME this is a hack to works design_data
#   class << self # Class methods
#     alias :all_columns :columns

#     def columns
#       all_columns.reject {|c| c.name == 'design_data'}
#     end
#   end

  validates_presence_of :title
  validates_presence_of :introduction
  validates_uniqueness_of :title

  has_many :items, :before_add => [ Proc.new { |p,d| raise "#{t(:active_survey_cant_receive_questions)}" if p.is_active } ], :order => "position"
  has_many :questions
  has_many :permissions
  has_many :users, :through => :permissions

  has_many :moderator_permissions, :conditions => {:is_moderator => true}, :class_name => 'Permission'
  has_many :moderators, :through => :moderator_permissions, :source => :user
  has_many :questionnaires

  acts_as_design :root => File.join('designs', 'researches')

  validate do |b|
    b.must_have_questions_to_be_active
    b.some_items_must_have_alternatives_to_be_active
    b.number_of_max_answers
  end

  def must_have_questions_to_be_active
    if self.questions.empty? and self.is_active
      errors.add_to_base("#{t(:survey_doesnt_have_questions_it_cant_be_active)}")
    end
  end

  def some_items_must_have_alternatives_to_be_active
    questions = self.questions.find_all { |question| question.is_text? == false }
    if self.is_active
      questions.each do |question|
        if question.item_values.empty?
          errors.add_to_base("#{question.info} #{t(:must_have_alternatives_survey_cant_be_active)}")        
        end 
      end
    end
  end

  def number_of_max_answers
    if self.is_active
      self.questions.each do |question|
        if question.invalid_max_answers?
          errors.add_to_base("#{question.info} #{t(:accepts)} #{question.max_answers.to_s} #{t(:answers_maximum_but_only_has)} #{question.item_values.count} #{t(:alternatives_survey_cant_be_active)}")
        end
      end
    end 
  end


  # Get and array of integer that indicates the pages order and
  # set the item (questions and sections) to the correct order.
  def reorder_pages(pages_order = [])
    pages_order = pages_order.map{|o|o.to_i}
    for i in 1..self.number_of_pages do 
      if (pages_order[i-1] != i) 
        new_page = (pages_order[i-1] == i + 1) ? pages_order.index(i) + 1 : pages_order[i-1]
        old_page = i
        break
      end
    end

    new_items_page = self.items.find_all_by_page_id(new_page)
    
    self.items.update_all("page_id = #{new_page}", :page_id => old_page)
    self.items.update_all("page_id = #{old_page}", :id => new_items_page.map{|i|i.id})
  end

  # Methods related to position question's switching.
  def reorder_items(position)
    #FIXME Inefficient algorithm; Keep @research.items sorted
    self.items.each { |item| if item.position >= position; item.position+= 1; item.save!; end }
  end

  def update_positions(new_position, old_position)
    #FIXME Inefficient algorithm; Keep @research.items sorted
    if new_position >  old_position
      self.items.each { |i| if i.position > old_position and i.position <= new_position; i.position -= 1; i.save!; end }
    elsif new_position <  old_position
      self.items.each { |i| if i.position < old_position and i.position >= new_position; i.position += 1; i.save!; end }
    end
  end
end
