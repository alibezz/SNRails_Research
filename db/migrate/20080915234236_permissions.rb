class Permissions < ActiveRecord::Migration
  def self.up
    create_table :permissions, :force => true do |t|
      t.references :survey
      t.references :user
      t.boolean :is_moderator
    end
  end

  def self.down
    drop_table :permissions
  end
end
