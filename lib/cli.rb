#!/usr/bin/env ruby

require 'tty-prompt'
require 'tty-spinner'

module KISSCraft

  class CLI

    def initialize
      @prompt = TTY::Prompt.new

      @user_input_queue = Queue.new

      render_prompt

      loop do
        user_input = @user_input_queue.pop

        if user_input == "exit"
          servers = KISSCraft::Minecraft::Server.get_servers(:running)

          multi_spinner = TTY::Spinner::Multi.new("[:spinner] Shutting down servers")

          servers.each do |s|
            multi_spinner.register("[:spinner] #{s.name}") do |sp| 
              s.stop
              until s.status == :stopped
                sleep(1)
              end
              sp.success('gracefully stopped') 
            end
          end

          multi_spinner.auto_spin 



          return 0
        end

        render_prompt

        servers = KISSCraft::Minecraft::Server.get_servers

        server = nil

        if servers.count == 1
          server = servers.first 
        end

        if /^kc/ =~ user_input
          commands = user_input.split

          if commands[1] == "start"
            Log.puts "Attempting to start #{commands[2]}", "INFO", commands[2], "Startup"
            server = KISSCraft::Minecraft::Server.new(commands[2])

            next
          end

          if commands[1] == "players"
            if commands[2] == "list"
              Log.puts server.current_players.keys
            end

          end


        else
          server.server_input_queue << user_input
        end

      end
    end

    def render_prompt
      @render_prompt_thread = Thread.new do
        @user_input_queue << @prompt.ask("=>")
      end
    end

  end

end

