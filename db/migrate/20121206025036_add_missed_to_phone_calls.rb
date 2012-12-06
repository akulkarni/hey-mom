class AddMissedToPhoneCalls < ActiveRecord::Migration
  def change
    add_column :phone_calls, :missed_call, :boolean

  end
end
