require 'open-uri'
require 'json'
require 'pp'
require 'yaml'
require 'set'
require 'ruby_bare_esi'
require 'active_support'
require 'active_record'
require 'sqlite3'

require_relative '../models/old_killmails_request'
require_relative '../models/old_esi_request'

# ActiveRecord::Base.logger = Logger.new(STDOUT)

Dir.chdir( __dir__ + '/..' )

targets = YAML.load_file('targets.yml')

INDIVIDUALS = targets[:individuals]
SYSTEMS = targets[:systems]

db_config = YAML.load_file('db/config.yml')
p db_config
ActiveRecord::Base.establish_connection db_config['development']

def find
  p 'Individuals'
  INDIVIDUALS.each do |i|
    request "https://zkillboard.com/api/kills/characterID/#{i}/"
    request "https://zkillboard.com/api/losses/characterID/#{i}/"
  end
  analyze_killmails @requests

  @requests = []

  p 'Systems'
  SYSTEMS.each do |i|
    request "https://zkillboard.com/api/solarSystemID/#{i}/"
  end
  analyze_killmails @requests

end

def request( url )
  @requests ||= []
  @requests += JSON.parse(OldKillmailsRequest.get(url))
end

def analyze_killmails( requests )

  puts "#{requests.count} individuals to check"

  requests.each do |r|
    r = OpenStruct.new( r )
    # r.zkb = OpenStruct.new( r.zkb )

    kill_mail_url = "killmails/#{r.killmail_id}/#{r.zkb['hash']}/"
    next if OldEsiRequest.where( url: kill_mail_url ).exists?

    page = OldEsiRequest.get( kill_mail_url )
    page.killmail_time = DateTime.parse( page.killmail_time )

    if page.killmail_time > Time.now.gmtime.to_datetime - 1.hours
      # p page

      page.attackers.each do |attacker|
        next unless attacker['character_id']

        character = OldEsiRequest.get( "characters/#{attacker['character_id']}/", permanent: true )
        name = character.name
        id = attacker['character_id']

        system_data = OldEsiRequest.get( "universe/systems/#{page.solar_system_id}/", permanent: true )
        system_name = system_data.name

        time = page.killmail_time.localtime
        puts "#{name}(#{id}) spotted in #{system_name} at #{time}"
      end
    end
  end

end

find

OldEsiRequest.purge