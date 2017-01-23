require 'net/http'
require 'openssl'
require 'json'
require 'pp'

class Main
  API_KEY = ENV['STATINK_API_KEY'].freeze

  def initialize
    @http = Net::HTTP.new 'stat.ink', Net::HTTP.https_default_port
    @http.use_ssl = true
    @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  def get_input(prompt)
    print prompt
    $stdin.gets.chomp
  end

  def get_id_from(input)
    match = /\d+\z/.match(input)
    match.to_a[0].to_i
  end

  def params_to_s(params)
    params.map { |k, v| "#{k}=#{v}" }.join('&')
  end

  def get_battle_ids_newer_than(id)
    params = {
      screen_name: 'blueberrystream',
      newer_than: id,
      count: 100,
    }

    path = '/api/v1/battle?' + self.params_to_s(params)
    puts "GET: #{path}"
    response = @http.get path
    puts response.message
    response.value

    ids = []
    response = JSON.parse response.body
    response.each do |battle|
      ids.push battle['id']
    end

    ids.sort!
  end

  def get_lobby_sym_from(input)
    case input
    when /n|normal|nora/
      :standard
    when '2'
      :squad_2
    when '3'
      :squad_3
    when '4'
      :squad_4
    when /p|private/
      :private
    when /f|fes|fest/
      :fest
    else
      nil
    end
  end

  def set_lobby(battle_id, lobby_sym)
    params = {
      apikey: API_KEY,
      id: battle_id,
      lobby: lobby_sym,
    }

    path = '/api/v1/battle'
    params = self.params_to_s(params)
    puts "PATCH #{path} #{params}"
    response = @http.patch path, params
    puts response.message
  end

  def set_link_url(battle_id, link_url)
    params = {
      apikey: API_KEY,
      id: battle_id,
      link_url: link_url,
    }

    path = '/api/v1/battle'
    params = self.params_to_s(params)
    puts "PATCH #{path} #{params}"
    response = @http.patch path, params
    puts response.message
  end
end

main = Main.new
puts 'input battle id range...'
input = main.get_input 'from> '
from_id = main.get_id_from(input) - 1
input = main.get_input '  to> '
to_id = main.get_id_from input

ids = []
loop do
  from_id = ids.last unless ids.empty?
  fragment = main.get_battle_ids_newer_than from_id
  included_to_id = fragment.include? to_id

  if included_to_id
    to_id_index = fragment.index to_id
    fragment.slice! Range.new(to_id_index + 1, fragment.length, true)
  end

  ids.concat fragment

  break if included_to_id
end

#input = main.get_input 'lobby(n,2-4,p,f)> '
#lobby_sym = main.get_lobby_sym_from input
#return if lobby_sym.nil?
#ids.each do |id|
#  main.set_lobby id, lobby_sym
#end

link_url = main.get_input 'link_url> '
ids.each do |id|
  main.set_link_url id, link_url
end

