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

    def gen_table
      @html_lines << "<table class='table' style='width: 75%;' id='#{@section_name}'>" 
      @html_lines << "<colgroup>"
      @html_lines << "<col spawn='1' style='width: 10%'>"
      @html_lines << "<col spawn='1' style='width: 55%'>"
      @html_lines << "<col spawn='1' style='width: 35%'>"
      @html_lines << "</colgroup>"
      @html_lines << "<tbody>"
      @html_lines << "<tr>"
      @html_lines << "<th>Variable</th>"
      @html_lines << "<th>Comment</th>"
      @html_lines << "<th>Value </th>"
      @html_lines << "</tr>"

      @in_table = true
    end

    def parse

      @html_lines = []
      
      @root_node = TreeNode.new("ROOT")
      
      current_node = @root_node
      populating_array = false
      @in_table = false

      last_comment = ""

      cfg = File.readlines(@file_path).each_with_index do |line, num|
        line = line.strip

        if /^#/ =~ line
          last_comment = line.gsub("#","").strip
          next
        end

        if populating_array

          if line.include? ">"
            populating_array = false
            var_array = current_node.children.last.content
            var_name = current_node.children.last.name

            @html_lines << "<td>#{var_name}</td>"
            @html_lines << "<td> #{last_comment} </td>"
            @html_lines << "<td><textarea rows='5' style='width:100%' id=#{var_name}>#{var_array.map{|v| v += "&#13;&#10"}.join("")}</textarea></td>"
            @html_lines << "</tr>"
            last_comment = ""
          else
            current_node.children.last.content << line.strip
          end

        elsif line.include? "{"
          @section_name = line.gsub("{","").strip

          new_node =  TreeNode.new(@section_name)

          current_node << new_node

          current_node = new_node

          @html_lines << "<h3 data-toggle='collapse' data-target='##{@section_name}'> #{@section_name} </h1>" 
          @html_lines << "<div style='position:relative; left: 1%;'id='#{@section_name}' class='collapse'>" 
        
        elsif line.include? "}"
          @html_lines << "</tbody>" if @in_table
          @html_lines << "</table>" if @in_table
          @html_lines << "</div>"
          @in_table = false
          @section_name = nil
          current_node = current_node.parent

        else
          var_name = line[/(?<=^[BIS]:)\w+/]
          value = ""

          if var_name
            gen_table unless @in_table
            @html_lines << "<tr>"

            var_type = line.split(":").first
            if var_type == "I"
              value = line[/(?<==)\d*/]

              @html_lines << "<td>#{var_name}</td>"
              @html_lines << "<td>#{last_comment} </td>"
              @html_lines << "<td><input type='number' id='#{var_name}' name='#{@section_name}_#{var_name}'value='#{value}'></td>"
              @html_lines << "</tr>"
              last_comment = ""

            elsif var_type == "B"
              value = (line.include?("=true") ? true : false)

              @html_lines << "<td>#{var_name}</td>"
              @html_lines << "<td>#{last_comment} </td>"
              @html_lines << "<td><input type='checkbox' form='config' id='#{var_name}' name='#{@section_name}_#{var_name}'#{" checked" if value}></td>"
              @html_lines << "</tr>"
              last_comment = ""

            elsif var_type == "S" and line.include? "<"
              value = Array.new

              populating_array = true
            
            elsif var_type == "S"
              value = line[/(?<==)[^#]*/]
              
              @html_lines << "<td>#{var_name}</td>"
              @html_lines << "<td>#{last_comment} </td>"
              @html_lines << "<td><input type='text' id='#{var_name}' value='#{value}' name='#{@section_name}_#{var_name}'></td>"
              @html_lines << "</tr>"
              last_comment = ""


            end

            new_node = TreeNode.new(var_name, value)


            current_node << new_node
          end


        end

      end

      @html_lines << "<form id='config' method='post'>"
      @html_lines << "<input type='submit' value='Write Changes'>"
      @html_lines << "</form>"
    end

  end
end

