class AddCallSidToPhoneCalls < ActiveRecord::Migration
  def change
    add_column :phone_calls, :call_sid, :string

  end
end
