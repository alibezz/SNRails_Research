class ItemValuesQuestions < ActiveRecord::Migration
  def self.up
    create_table :item_values_questions, :id => false do |t|
      t.references :question
      t.references :item_value
    end 
  end

  def self.down
  end
end
