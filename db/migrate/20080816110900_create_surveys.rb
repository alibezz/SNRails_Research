class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys, :force => true do |t|
      t.text :title, :subtitle
      t.integer :number_of_pages, :default => 0
      t.text :introduction, :design_data
      t.boolean :is_private, :default => false
      t.boolean :is_active, :default => false
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :surveys
  end
end
