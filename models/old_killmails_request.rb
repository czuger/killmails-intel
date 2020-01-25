require 'pp'

class OldKillmailsRequest < ActiveRecord::Base

  def self.get(url)
    old_k = self.find_by_url( url )

    if old_k
      if old_k.updated_at <= Time.now - 1.hour
        result = self.get_from_web(url)
        old_k.result = result
        old_k.touch # Because result can be the same even if time is out
      else
        result = old_k.result
      end
    else
      result = self.get_from_web(url)
      old_k = self.new( url: url, result: result )
    end

    old_k.save!
    result
  end

  private

  def self.get_from_web( url )
    sleep 1
    request = open( url )
    request.read
  end

end