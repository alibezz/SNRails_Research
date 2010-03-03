class Research < ActiveRecord::Base

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


  def reorder_pages(pages_order =[])
    new_order = pages_order.map{|o|o.to_i}
    old_order = self.page_ids
    first = select_position(0, self.number_of_pages-1) {|i| new_order[i] != old_order[i]}
    last = select_position(first+1,self.number_of_pages-1) {|i| new_order[i] == old_order[i]} - 1
    if new_order[last] < new_order[last-1]
      update_pages(first, last, -1, old_order, "upto")
    else
      update_pages(last, first, 1, old_order, "downto")
    end
    self.reload
  end

  def how_many_items(page)
    num_items = self.items.find(:all, :conditions => {:page_id => page.to_i}).count
    return num_items if num_items > 0
    return self.items.find(:all, :conditions => {:page_id => 1}).count if page.blank?
    nil
  end

  def page_ids
    self.items.all(:select => 'DISTINCT page_id').map(&:page_id).sort
  end

  def number_of_pages
    self.page_ids.count
  end

protected 


  def select_position(ind1, ind2, &block)
    position = self.number_of_pages
    for i in ind1..ind2 do
      if yield i
        position = i
        break
      end
    end
    position
  end

  def update_pages(pos1, pos2, offset, old_order, for_type)
    pos1_items = self.items.find_all {|item| item.page_id == old_order[pos1]}
    (pos1 - offset).send for_type, pos2 do |i|
      new_id = old_order[i + offset]
      self.items.each {|item| item.page_id = new_id if item.page_id == old_order[i]; item.save!} 
      self.reload
    end
    pos1_items.each {|item| item.page_id = old_order[pos2]; item.save!}
  end
end 

