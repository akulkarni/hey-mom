class GradeController < ApplicationController

  def index
    name = params['user']
    @user = User.where(:name => name.downcase).last unless name.nil?
    
    unless @user.nil?
      @total_outbound = score_total_outbound_calls(@user)
      @total_seconds = score_total_seconds(@user)
      @average_response_time = score_average_response_time(@user)

      # to be a good son,
      #   call at least 3x a week
      #   speak for at least 60 minutes a week
      #   respond no later than a day after you miss a call
      @score = @total_outbound/3.to_f + @total_seconds/3600.to_f + 86400/@average_response_time.to_f

      case @score
      when 0...2
        @grade = 'F'
#        @mom_picture = 'mom-stern.jpg'
        @mom_picture = get_sad_picture(@user)
      when 2...3
        @grade = 'B'
#        @mom_picture = 'mom-unhappy.jpg'
        @mom_picture = get_ok_picture(@user)
      else
        @grade = 'A'
#        @mom_picture = 'mom-happy.jpg'
        @mom_picture = get_happy_picture(@user)
      end
    end
  end
    
  def score_total_outbound_calls(user)
#    return PhoneCall.where('created_at > ? and inbound = false', Time.now()-604800).count
    return PhoneCall.where("created_at > '%s' and system_number = '%s' and inbound = false",
                           Time.now()-604800, user.system_number).count
  end

  def score_total_seconds(user)
#    return PhoneCall.where('created_at > ? and missed_call is not true', Time.now()-604800).sum('duration')
    return PhoneCall.where("created_at > '%s' and system_number = '%s' and missed_call is not true",
                           Time.now()-604800, user.system_number).sum('duration')
  end
  
  def score_average_response_time(user)
#    phone_calls = PhoneCall.where('created_at > ? and inbound = true and missed_call = true', Time.now()-604800)
    phone_calls = PhoneCall.where("created_at > '%s' and system_number = '%s' and inbound = true and missed_call = true",
                                  Time.now()-604800, user.system_number)
    sum = 0
    for pc in phone_calls
      pc.response_time.nil? ? (sum += (Time.now() - pc.created_at)) : (sum += pc.response_time)
    end
    sum == 0 ? (return 86400) : (return sum / phone_calls.count)
  end
  
  def get_happy_picture(user)
    user.name == 'ajay' ? (return 'mom-happy.jpg') : 
      (return 'http://media.giphy.com/media/12INbAYtjdeTbW/original.gif')
  end

  def get_ok_picture(user)
    user.name == 'ajay' ? (return 'mom-unhappy.jpg') : 
      (return 'http://media.giphy.com/media/8boMf1VXVHoJy/original.gif')
  end

  def get_sad_picture(user)
    user.name == 'ajay' ? (return 'mom-stern.jpg') : 
      (return 'http://media.giphy.com/media/1hiVNxD34TpC0/original.gif')
  end
end

