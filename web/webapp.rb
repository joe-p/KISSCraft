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
        @servers = KISSCraft::Minecraft::Server.instances.to_a

        r.post do

          r.params.each do |key, value|
            key_split = key.split

            next unless key_split.delete_at(0) == "cb"

            server_name = key_split.delete_at(0)

            mod_name = key_split.join(" ")

            server = @servers.find {|s| s.name == server_name}

            mod = server.mod(mod_name)

            if ( mod.enabled? and value == "0" ) || (!mod.enabled? and value == "on")
              mod.toggle
            end

          end 

          r.redirect "mods"
        end

        render "mods"
      end
    end
  end

end
