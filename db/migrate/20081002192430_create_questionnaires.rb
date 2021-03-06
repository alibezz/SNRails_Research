class CreateQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :questionnaires, :force => true do |t|
      t.references :survey
      t.boolean :incomplete, :default => true 
      t.timestamps
    end
  end

  def self.down
    drop_table :questionnaires
  end
end
