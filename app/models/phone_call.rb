class PhoneCall < ActiveRecord::Base
  validates :direction, :duration, :presence => true
  validates :direction, :duration, :response_time, :numericality => { :only_integer => true }, :allow_nil => true
end
