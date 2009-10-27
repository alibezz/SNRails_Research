class CreateItemValues < ActiveRecord::Migration
  def self.up
    create_table :item_values, :force => true do |t|
      t.string :info
      t.integer :item_id 
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :item_values
  end
end
