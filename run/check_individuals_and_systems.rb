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
  load_db

  puts "#{requests.count} individuals to check"

  requests.each do |r|
    r = OpenStruct.new( r )
    # r.zkb = OpenStruct.new( r.zkb )

    next if @old_db.include?( r.killmail_id )

    e = RubyBareEsi.new( "killmails/#{r.killmail_id}/#{r.zkb['hash']}/", {} )
    page = OpenStruct.new( e.get_page )
    page.killmail_time = DateTime.parse( page.killmail_time )

    if page.killmail_time > Time.now.gmtime.to_datetime - 1.hours
      # p page

      page.attackers.each do |attacker|
        e = Esi::Download.new( "characters/#{attacker['character_id']}/", {} )

        next unless attacker['character_id']

        character = OpenStruct.new( e.get_page )
        name = character.name
        id = attacker['character_id']

        e = RubyBareEsi.new( "universe/systems/#{page.solar_system_id}/", {} )
        system_data = OpenStruct.new( e.get_page )
        system_name = system_data.name

        time = page.killmail_time.localtime
        puts "#{name}(#{id}) spotted in #{system_name} at #{time}"
      end
    else
      # puts "#{page.killmail_id} too old : #{page.killmail_time}"
      # p page.killmail_id
      # p @old_db
      @old_db << page.killmail_id
      # p @old_db
    end
  end

  save_db
end

def load_db
  # Misc::Banner.p 'DB loaded'
  @old_db = ( File.file?( DB_FILE ) ? YAML.load_file( DB_FILE ) : { requests: {} } )
end

def save_db
  File.open( DB_FILE, 'w' ) do |f|
    f.write( @old_db.to_yaml )
  end

  # Misc::Banner.p 'DB saved'
end

find