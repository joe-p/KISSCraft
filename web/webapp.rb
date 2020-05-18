#!/usr/bin/env ruby
require "roda"

require_relative '../lib/cli'
require_relative '../lib/log'
require_relative '../lib/minecraft/server'
require_relative '../lib/minecraft/player'


module KISSCraft
  class WebApp < Roda

    Thread.new do
      sleep 0.1
      KISSCraft::CLI.new
    end

    plugin :json, classes: [Array, Hash, KISSCraft::Minecraft::Player] 

    route do |r|

      r.is "players" do
        KISSCraft::Minecraft::Server.instances.to_a.first.current_players
      end

    end
  end

end
