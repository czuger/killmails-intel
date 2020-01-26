require 'ruby-bare-esi'

class DownloadReactionsComponentsPrices < RubyBareEsi

  def download

    types = [ 16642, 4246, 16635, 16636, 16656, 16660, 16672, 16673, 16639, 16638, 16641,
              16654, 16658, 16671, 4312, 16644, 4051, 16634, 16657, 16661, 16637, 16649,
              16662, 16633, 4247, 16659, 16679, 25273, 3645, 25242, 25268, 25237, 16640,
              16643, 16655, 16670, 16647, 16663, 16648, 17959, 16680 ]

    results = []

    f = File.open('html/reactions.html', 'w')
    f.puts('<table border="1">')

    types.each do |t|
      @rest_url = "universe/types/#{t}/"

      begin
        type_remote_data = get_page

      rescue RubyBareEsi::Errors::NotFound
        puts "Data not found for type id : #{t}"
        next
      end

      type_data = { type_id: t, name: type_remote_data['name'] }

      @rest_url = 'markets/10000002/orders/'
      @params= { order_type: :sell, type_id: t }

      begin
        type_remote_datas = get_all_pages

      rescue Esi::Errors::NotFound
        puts "Data not found for type id : #{t}"
        next
      end

      type_remote_datas.reject!{ |e| e['system_id'] != 30000142 }
      min_price = type_remote_datas.map{ |e| e['price'] }.min

      type_data[:min_price] = min_price

      results << type_data
    end

    results.sort_by!{ |e| e[:name] }

    results.each do |e|
      next unless e[:min_price]
      # puts "#{e[:name]};#{e[:min_price].round}"
      f.puts "<tr><td style=\"padding:10px\">#{e[:name]}</td>
          <td style=\"padding:10px\">#{e[:min_price].to_s.gsub('.', ',')}</td>
          <td style=\"padding:10px\">#{Time.now}</td></tr>"
    end
  end
end

DownloadReactionsComponentsPrices.new.download