#!/usr/bin/env ruby
require "roda"

require_relative '../lib/cli'
require_relative '../lib/log'
require_relative '../lib/minecraft/server'
require_relative '../lib/minecraft/player'


module KISSCraft
  class WebApp < Roda
    plugin :render, views: "web/views"
    plugin :forme_route_csrf
    plugin :sessions, secret: "ewzxcweofijjpoijoijpoqwijfpoiwjqpoefiqjwfefjekjwlfijeofijwoipqoiwjpofeijqopiwjefpoqijpoeijf"
    
    Thread.new do
      sleep 0.1
      KISSCraft::CLI.new
    end

    plugin :json, classes: [Array, Hash, KISSCraft::Minecraft::Player] 

    route do |r|

      r.is "players" do
        KISSCraft::Minecraft::Server.instances.to_a.first.current_players
      end

      r.is "test" do
        render "test"
      end

      r.is "mods" do
        r.post do
          p r.params
          r.redirect "mods"
        end

        @servers = KISSCraft::Minecraft::Server.instances.to_a
        render "mods"
      end
    end
  end

end
