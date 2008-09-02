class CreateResearches < ActiveRecord::Migration
  def self.up
    create_table :researches, :force => true do |t|
      t.string :name
      t.integer :number_of_pages
      t.text :introduction

      t.timestamps
    end
  end

  def self.down
    drop_table :researches
  end
end
