class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers, :force => true do |t|
      t.string :info
      t.references :item 
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
