require 'dotenv/load'
require 'net/http'
require 'openssl'
require 'json'

module Statink
  class API
    HOSTNAME = 'stat.ink'
    BASE_PATH = '/api/v1'.freeze
    KEY = ENV['STATINK_API_KEY'].freeze

    class << self
      def make_parameter_string(param_hash)
        param_hash.map { |k, v| "#{k}=#{v}" }.join('&')
      end
    end

    def initialize
      @http = Net::HTTP.new HOSTNAME, Net::HTTP.https_default_port
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def get_battles(params)
      path = "#{BASE_PATH}/battle?" + self.class.make_parameter_string(params)
      puts "GET: #{path}"
      response = @http.get path
      puts response.message
      response.value

      JSON.parse response.body
    end

    def patch_battle(params)
      params[:apikey] = KEY

      path = '/api/v1/battle'
      params = self.class.make_parameter_string(params)
      puts "PATCH #{path} #{params}"
      response = @http.patch path, params
      puts response.message
      response.value

      JSON.parse response.body
    end

    private

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
  end
end
