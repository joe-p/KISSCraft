#!/usr/bin/env ruby
require 'pry'
require 'tree'

module KISSCraft
  class CFGParse
    include Tree
    
    def initialize(file_path)
      @file_path = file_path
    end

    def html
      parse
      @html_lines.join("\n")
    end

    def root_node
      parse
      @root_node
    end

    def parse

      @html_lines = []
      @root_node = TreeNode.new("ROOT")
      
      current_node = @root_node
      populating_array = false

      cfg = File.readlines(@file_path).each_with_index do |line, num|
        line = line.strip

        next if /^#/ =~ line

        if populating_array

          if line.include? ">"
            populating_array = false
            var_array = current_node.children.last.content
            var_name = current_node.children.last.name

            @html_lines << "<label style='display: block;' for='#{var_name}'> #{var_name} </label><br>"
            @html_lines << "<textarea rows='5' cols='30' id=#{var_name}>#{var_array.map{|v| v += "&#13;&#10"}.join("")}</textarea>"
            @html_lines << "</li>"
          else
            current_node.children.last.content << line.strip
          end

        elsif line.include? "{"
          section_name = line.gsub("{","").strip

          new_node =  TreeNode.new(section_name)

          current_node << new_node

          current_node = new_node

          @html_lines << "<ul id='#{section_name}'>" 
          @html_lines << "<h1> #{section_name} </h1>"

        elsif line.include? "}"
          @html_lines << "</ul>"
          current_node = current_node.parent

        else
          var_name = line[/(?<=^[BIS]:)\w+/]
          value = ""

          if var_name
            @html_lines << "<li>"

            var_type = line.split(":").first
            if var_type == "I"
              value = line[/(?<==)\d*/]

              @html_lines << "<input type='number' id='#{var_name}' value='#{value}'>"
              @html_lines << "<label style='display: inline; float: left;' for='#{var_name}'> #{var_name} </label><br>"
              @html_lines << "</li>"

            elsif var_type == "B"
              value = (line.include?("=true") ? true : false)

              @html_lines << "<input type='checkbox' id='#{var_name}' name='#{name=var_name}'#{" checked" if value}>"
              @html_lines << "<label style='display: inline; float: left;' for='#{var_name}'> #{var_name} </label><br>"
              @html_lines << "</li>"

            elsif var_type == "S" and line.include? "<"
              value = Array.new

              populating_array = true
            
            elsif var_type == "S"
              value = line[/(?<==)[^#]*/]

            end

            new_node = TreeNode.new(var_name, value)




            current_node << new_node
          end


        end

      end

    end

  end
end

