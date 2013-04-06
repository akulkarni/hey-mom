class User < ActiveRecord::Base
  attr_accessible :contact_name, :contact_phone_number, :name, :phone_number, :system_number
end
