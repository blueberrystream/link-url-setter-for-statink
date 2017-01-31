require 'statink'
require 'thor'

module Statink
  class CLI < Thor
    option :id, type: :numeric
    option :screen_name
    option :newer_than, type: :numeric
    option :older_than, type: :numeric
    option :count, type: :numeric
    desc 'get_battles', 'GET /api/v1/battle'
    def get_battles
      api.get_battles(options)
    end

    option :link_url
    option :note
    option :private_note
    desc 'patch_battle [BATTLE ID]', 'PATCH /api/v1/battle'
    def patch_battle(id)
      options[:id] = id
      api.patch_battle(options)
    end

    desc 'set_link_url [SCREEN NAME] [FROM ID] [TO ID] [LINK_URL]', 'Set link url to the battles.'
    def set_link_url(screen_name, from_id, to_id, link_url)
      from_id = get_id_from from_id
      to_id = get_id_from to_id

      ids = []
      params = {
        screen_name: screen_name,
        older_than: to_id.to_i + 1,
        count: 100,
      }
      loop do
        params[:older_than] = ids.last unless ids.empty?
        battles = api.get_battles(params)
        fragment = extract_ids_from battles
        included_from_id = fragment.include?(from_id)

        if included_from_id
          from_id_index = fragment.index from_id
          fragment.slice! Range.new(from_id_index + 1, fragment.length, true)
        end

        ids.concat fragment

        break if included_from_id
      end

      params = {
        link_url: link_url
      }
      ids.each do |id|
        params[:id] = id
        api.patch_battle(params)
      end
    end

    private

    def api
      if defined?(@api)
        @api
      else
        @api = Statink::API.new
      end
    end

    def extract_ids_from(battles)
      ids = []
      battles.each do |battle|
        ids.push battle['id']
      end

      ids.sort!.reverse!
    end

    def get_id_from(string)
      match = /\d+\z/.match(string)
      match.to_a[0].to_i
    end
  end
end
