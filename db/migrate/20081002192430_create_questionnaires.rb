class CreateQuestionnaires < ActiveRecord::Migration
  def self.up
    create_table :questionnaires, :force => true do |t|
      t.references :research
      t.string :info
      t.timestamps
    end
  end

  def self.down
    drop_table :questionnaires
  end
end
