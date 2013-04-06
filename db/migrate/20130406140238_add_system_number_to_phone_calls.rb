class AddSystemNumberToPhoneCalls < ActiveRecord::Migration
  def change
    add_column :phone_calls, :system_number, :string
  end
end
