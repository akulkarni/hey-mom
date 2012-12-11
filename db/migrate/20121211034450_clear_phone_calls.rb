class ClearPhoneCalls < ActiveRecord::Migration
  def up
    PhoneCall.delete_all
  end

  def down
  end
end
