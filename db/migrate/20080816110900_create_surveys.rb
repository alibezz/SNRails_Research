class CreateResearches < ActiveRecord::Migration
  def self.up
    create_table :researches, :force => true do |t|
      t.string :title, :subtitle
      t.integer :number_of_pages, :default => 0
      t.text :introduction, :design_data
      t.boolean :is_private, :default => false
      t.boolean :is_active, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :researches
  end
end
