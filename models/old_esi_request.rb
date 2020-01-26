require 'pp'
require 'ostruct'
require_relative 'old_request'

class OldEsiRequest < OldRequest

  def self.get(url)
    old_k = self.find_by_url( url )

    if old_k
      result = JSON.parse(old_k.result)
    else
      e = RubyBareEsi.new( url, {} )
      page = e.get_page

      old_k = self.new( url: url, result: page.to_json )

      result = OpenStruct.new( page )
    end

    old_k.save!
    result
  end

end