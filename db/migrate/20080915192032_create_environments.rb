class CreateEnvironments < ActiveRecord::Migration
  def self.up
    create_table :environments do |t|
      t.boolean :is_default,  :default => false
      t.text :design_data
      t.timestamps
    end
    Environment.create(:is_default => true)
  end

  def self.down
    drop_table :environments
  end
end
