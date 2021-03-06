class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items, :force => true do |t|
      t.string :info, :type
      t.integer :html_type
      t.references :survey
      t.integer :page_id, :default => 1
      t.integer :position
      t.boolean :is_optional, :default => false
      t.integer :min_answers, :default => 0
      t.integer :max_answers, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
