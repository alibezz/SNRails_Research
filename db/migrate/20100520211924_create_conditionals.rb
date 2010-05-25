class CreateConditionals < ActiveRecord::Migration
  def self.up
    create_table :conditionals do |t|
      t.references :question
      t.references :item_value
      t.integer :relation
      t.timestamps
    end
  end

  def self.down
    drop_table :conditionals
  end
end
