require 'pp'
require 'ostruct'
require_relative 'old_request'

class OldEsiRequest < OldRequest

  def self.get(url, permanent: false)
    old_k = self.find_by_url( url )

    if old_k
      result = JSON.parse(old_k.result)
      old_k.touch if permanent
    else
      e = RubyBareEsi.new( url, {} )
      result = e.get_page

      old_k = self.new( url: url, result: result.to_json )
    end

    old_k.save!
    OpenStruct.new( result )
  end

  def self.purge
    self.where( 'updated_at <= ?', Time.now.gmtime - 1.month ).delete_all
  end

end