class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items, :force => true do |t|
      t.string :info, :type, :html_type
      t.references :research
      t.integer :page_id, :position
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
