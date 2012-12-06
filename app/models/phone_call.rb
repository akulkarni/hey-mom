class PhoneCall < ActiveRecord::Base
  validates :direction, :duration, :presence => true
  validates :direction, :duration, :response_time, :numericality => { :only_integer => true }, :allow_nil => true

  def direction=(direction_string)
    direction = -1
    case direction_string
      when 'outbound'
        direction = 0
      when 'inbound'
        direction = 1
      when 'missed'
        direction = 2
    end
    write_attribute(:direction, direction)
  end

  def direction
    direction_string = 'none'
    case read_attribute(:direction)
      when 0
        direction_string = 'outbound'
      when 1
        direction_string = 'inbound'
      when 2
        direction_string = 'missed'
    end
    direction_string
  end

end
