class AddSystemNumberToAjayCalls < ActiveRecord::Migration
  def change
    PhoneCall.all.each do |pc|
      pc.update_attributes!(:system_number => '+1 9177192233')
    end
  end
end
