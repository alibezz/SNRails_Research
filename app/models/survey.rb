class Survey < ActiveRecord::Base

  validates_presence_of :title
  validates_presence_of :introduction
  validates_presence_of :user_id
  validates_uniqueness_of :title
  has_many :items, :before_add => [ Proc.new { |p,d| raise "#{I18n.t(:active_survey_cant_receive_questions)}" if p.is_active } ], :order => "position"
  has_many :questions
  has_many :sections
  has_many :questionnaires
  belongs_to :user #creator
  acts_as_design :root => File.join('designs', 'surveys')

  acts_as_accessible
  after_create :creator_moderates

  PERMISSIONS['survey'] = {
    'survey_editing' => I18n.t(:survey_editing),
    'survey_viewing' => I18n.t(:survey_viewing),
    'survey_erasing' => I18n.t(:survey_erasing) 
  } 
 
  validate do |b|
    b.must_have_questions_to_be_active
    b.some_items_must_have_alternatives_to_be_active
    b.number_of_max_answers
  end

  def must_have_questions_to_be_active
    if self.questions.empty? and self.is_active
      errors.add_to_base("#{I18n.t(:survey_doesnt_have_questions_it_cant_be_active)}")
    end
  end

  def some_items_must_have_alternatives_to_be_active
    questions = self.questions.find_all { |question| question.is_text? == false }
    if self.is_active
      questions.each do |question|
        if question.item_values.empty?
          errors.add_to_base("#{question.info} #{I18n.t(:must_have_alternatives_survey_cant_be_active)}")        
        end 
      end
    end
  end

  def number_of_max_answers
    if self.is_active
      self.questions.each do |question|
        if question.invalid_max_answers?
          errors.add_to_base("#{question.info} #{I18n.t(:accepts)} #{question.max_answers.to_s} #{I18n.t(:answers_maximum_but_only_has)} #{question.item_values.count} #{I18n.t(:alternatives_survey_cant_be_active)}")
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

  def members(current_user=nil)
    raw_members = select_members("IN") { current_user.nil? ? self.role_assignments.map(&:accessor_id) :                                                               self.role_assignments.map(&:accessor_id) - [current_user.id]}
    raw_members - [User.find(self.user_id)]
  end

  def non_members(current_user=nil)
    select_members("NOT IN") {current_user.nil? ? self.role_assignments.map(&:accessor_id) :                                                               self.role_assignments.map(&:accessor_id) | [current_user.id]}
  end

  #FIXME Change id params to object params
  def add_member(user_id, role_id)
    return false if user_id.blank? or role_id.blank?     
    role = Role.find(role_id); user = User.find(user_id)
    return user.add_role(role, self)
  end

  #FIXME Change id params to object params
  def change_member_role(user_id, new_role_id)
    return false if user_id.blank? or new_role_id.blank? or user_id == self.user_id 
    user = User.find(user_id)
    unless user.id == self.user_id #can't change creator membership
      old_assignment = user.role_assignments.detect {|role| role.resource_id == self.id }
      old_role = Role.find(old_assignment.role_id) if old_assignment

      #an user has only a single role over a survey
      user.remove_role(old_role, self) if old_role; user.reload
      new_role = Role.find(new_role_id)
      return user.add_role(new_role, self)
    end
  end
   
  #FIXME Change id params to object params
  def remove_member(user_id)
    user = User.find(user_id) unless user_id.blank?
    unless user.blank? or user.id == self.user_id
      old_assignment = user.role_assignments.detect {|role| role.resource_id == self.id }
      old_role = Role.find(old_assignment.role_id) if old_assignment
      return user.remove_role(old_role, self) unless old_role.blank?
    end
    false
  end

  def set_moderator(user)
    user.add_role(moderator_role, self)
  end 

  def ordered_items(page)
    self.items.find_all {|i| i.page_id == page}.sort {|a,b| a.position <=> b.position}
  end

  def self.public_surveys
    Survey.find(:all, :conditions => {:is_active => true, :is_private => false})
  end

  def change_activation
    self.is_active = self.is_active ? false : true
    self.save
  end

  def page_items(page)
    if page.blank?
      page = self.items.blank? ? 1 : self.items.minimum(:page_id)
    end
    self.items.find(:all, :conditions => {:page_id => page}, :order => :position)
  end

  def remove_section_items(section_id)
   section1 = self.section(section_id); return unless section1

   last_item = self.next_section(section1)
    if last_item.kind_of?(Question) or last_item == section1
      self.destroy_items(section1.position, last_item.position + 1, section1.page_id)
    else
      self.destroy_items(section1.position, last_item.position, section1.page_id)
    end
  end

  def section_items(section_id)
    section1 = self.section(section_id); return [] unless section1
    item = self.next_section(section1)
    pos = (item.kind_of?(Section) and item != section1) ? item.position - 1 : item.position
    return Item.within_section(section1.position, pos) 
  end

  #TODO Make tests
  def self.statistics(params)
    data = { 'request' => params}
    possibilities = {}
    survey_condition = { :conditions => { :survey_id => params[:id] }}

    from = params[:from].nil? ? Time.now.beginning_of_month.last_month.strftime('%Y-%m-%d') : Time.parse(params[:from])
    to = params[:to].nil? ? Time.now.beginning_of_month.strftime('%Y-%m-%d') : Time.parse(params[:to])

    Question.find(:all, survey_condition).each { |q|
      next if q.item_values.empty?
      # cache this latter, but have to update on adding questions
      possibilities[q.info] = q.id
    }

    if params[:criteria].nil?
      q = Question.find(:all, survey_condition).first
    else
      q = Question.find(params[:criteria])
    end

    answers = {}
    unless q.nil?
      q.item_values.each { |item|
        answers[item.info] = { "quantidade" => 0 }
      }
      tmp = ObjectItemValue.count(:conditions => ["item_id = ?", q.id],
                                  :group => "item_value_id")
      tmp.each { |oit|
        if oit[0] != 0
          answers[ItemValue.find(oit[0]).info] = { "quantidade" => oit[1] }
        end
      }
      data[q.info] = answers
    end

    data['possibilities'] = possibilities
    return data
  end

  def new_page(page, pages_order)
    return page if pages_order.blank? or self.page_ids.blank? or page.blank?
    index = pages_order.index(page)
    self.page_ids[index]
  end

   
protected unless Rails.env == 'test' 

  def creator_moderates
    self.set_moderator(User.find(self.user_id))
  end

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

  def select_members(operator, &block)
    ids = yield 
    cond = User.merge_conditions({ :administrator => false }, ["id #{operator} (#{ids.join(',')})"])
    User.find(:all, :conditions => cond)
  end

  def moderator_role
    Role.find_by_name("Moderator") || Role.find_by_name("moderator") || Role.create!(:name => "Moderator", :permissions => PERMISSIONS['survey'].keys)
  end

  def section(item_id)
    section = self.sections.detect{|i| i.id == item_id}
    return section
  end
  
  def next_section(section1)
    section2 = self.sections.detect {|i| i.position > section1.position  and i.page_id == section1.page_id}
    return section2.blank? ? self.last_page_question(section1) : section2
  end

  def last_page_question(item)
    questions = self.questions.find_all {|i| i.page_id == item.page_id and i.position > item.position}
    return questions.blank? ? item : questions.last
  end
  
  def destroy_items(p1, p2, page)
    Item.destroy_all("survey_id = #{self.id} AND position >= #{p1} AND position < #{p2} AND page_id = #{page}")
  end
end 
