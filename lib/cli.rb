#!/usr/bin/env ruby

require_relative 'tree_parse'
require "pry"

module KISSCraft

  SERVERS_DIR = File.expand_path("#{__dir__}/../servers").freeze

  class CLI

    def initialize

      server_names = Dir.glob("#{SERVERS_DIR}/*").map {|path| File.basename path}

      server_names.each do |name|
        KISSCraft::Minecraft::Server.new name 
      end
    end

    def parse_commands(input)
      input_array = input.split

      selected_servers = [] 
      
      kc = false
      
      if input_array.first == "kc"
        kc = true
        input_array.delete_at(0)
      end

      tree = TreeParse.new input_array


      tree.parse do |t|
        t.on "start" do
          get_selected_servers(t).each do |s|
            Log.puts "Attempting to start #{s.name}", "INFO", s.name, "Startup"
            s.start
          end
        end

        t.on "players" do
          t.on "list" do
            get_selected_servers(t, true).each do |s|
              next unless s.status == :running
              log_str = "Players in #{s.name}: #{s.current_players.keys.join(",")}"
              Log.puts log_str, "INFO", s.name, "PlayerQuery"
            end
          end
        end

      end
    end

    def get_selected_servers(t, return_all_when_empty = false)
      parsed_names = t.down
      
      servers = KISSCraft::Minecraft::Server.instances
     
      if parsed_names.empty?
        
        if servers.size == 1 or return_all_when_empty
          return servers
        end

        if @attached_server
          return [@attached_server]
        end

      end

      if parsed_names.include? "all" 
        return servers
      else
        servers.select {|s| parsed_names.include? s.name}
      end
    end

    def render_prompt
      @render_prompt_thread = Thread.new do
        @user_input_queue << @prompt.ask("=>")
      end
    end


  end

end

