class DropMissedFromPhoneCalls < ActiveRecord::Migration
  def up
    remove_column :phone_calls, :missed_call
    add_column :phone_calls, :status, :string
  end

  def down
    remove_column :phone_calls, :status
    add_column :phone_calls, :missed_call, :boolean
  end
end
