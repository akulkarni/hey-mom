class RemoveDirectionFromPhoneCalls < ActiveRecord::Migration
  def up
    remove_column :phone_calls, :direction
    add_column :phone_calls, :inbound, :boolean
  end

  def down
    add_column :phone_calls, :direction, :integer
    remove_column :phone_calls, :inbound
  end
end
