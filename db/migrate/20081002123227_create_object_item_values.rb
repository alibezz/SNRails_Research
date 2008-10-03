class CreateObjectItemValues < ActiveRecord::Migration
  def self.up
    create_table :object_item_values, :force => true do |t|
      t.references :item_value
      t.references :item
      t.references :questionnaire
      t.string :info
      t.timestamps
    end
  end

  def self.down
    drop_table :object_item_values
  end
end
