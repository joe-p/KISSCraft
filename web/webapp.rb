#!/usr/bin/env ruby
require "roda"

require_relative '../lib/cli'
require_relative '../lib/log'
require_relative '../lib/minecraft/server'
require_relative '../lib/minecraft/player'
require_relative 'html_generator'

module KISSCraft
  class WebApp < Roda
    plugin :render, views: "web/views"
    plugin :forme_route_csrf
    plugin :sessions, secret: "ewzxcweofijjpoijoijpoqwijfpoiwjqpoefiqjwfefjekjwlfijeofijwoipqoiwjpofeijqopiwjefpoqijpoeijf"
    plugin :json, classes: [Array, Hash, KISSCraft::Minecraft::Player] 
    plugin :websockets
    plugin :assets, path: "web/assets", css: ["side.sass"]
    KISSCraft::CLI.new
    MC_SERVER = KISSCraft::Minecraft::Server.instances.to_a.first
    MC_SERVER.start

    def on_message(connection, server, message)
      if message == "JOINED"
        server.console_connections << connection 
      else
        puts message
        server.server_input_queue << message
      end
    end

    def messages(connection)
      Enumerator.new do |yielder|
        loop do
          message = connection.read
          break unless message

          yielder << message
        end
      end
    end

    route do |r|

      r.assets 

      r.is "console" do
        r.websocket do |connection|
          messages(connection).each do |message|
            on_message(connection, MC_SERVER, message)
          end 
        end

        render "console"
      end

      r.is "players" do
        KISSCraft::Minecraft::Server.instances.to_a.first.current_players
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
