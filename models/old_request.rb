class OldRequest < ActiveRecord::Base

  private

  def self.get_from_web( url )
    sleep 1
    request = open( url )
    request.read
  end

end