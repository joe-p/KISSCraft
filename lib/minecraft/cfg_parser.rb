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
      @html_lines << "<table class='table' id='#{@section_name}'>" 
      @html_lines << "<tr>"
      @html_lines << "<th>Variable</th>"
      @html_lines << "<th>Value </th>"
      @html_lines << "</tr>"

      @in_table = true
    end

    def parse

      @html_lines = []
      @html_lines << """<head>
<link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css\" integrity=\"sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm\" crossorigin=\"anonymous\">
</head>
<body>
      """.split("\n")
      
      @root_node = TreeNode.new("ROOT")
      
      current_node = @root_node
      populating_array = false
      @in_table = false

      cfg = File.readlines(@file_path).each_with_index do |line, num|
        line = line.strip

        next if /^#/ =~ line

        if populating_array

          if line.include? ">"
            populating_array = false
            var_array = current_node.children.last.content
            var_name = current_node.children.last.name

            @html_lines << "<td>#{var_name}</td>"
            @html_lines << "<td><textarea rows='5' cols='30' id=#{var_name}>#{var_array.map{|v| v += "&#13;&#10"}.join("")}</textarea></td>"
            @html_lines << "</tr>"
          else
            current_node.children.last.content << line.strip
          end

        elsif line.include? "{"
          @section_name = line.gsub("{","").strip

          new_node =  TreeNode.new(@section_name)

          current_node << new_node

          current_node = new_node

          @html_lines << "<h1> #{@section_name} </h1>" 

        elsif line.include? "}"
          @html_lines << "</table>" if @in_table
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
              @html_lines << "<td><input type='number' id='#{var_name}' value='#{value}'></td>"
              @html_lines << "</tr>"

            elsif var_type == "B"
              value = (line.include?("=true") ? true : false)

              @html_lines << "<td> #{var_name}</td>"
              @html_lines << "<td><input type='checkbox' id='#{var_name}' name='#{name=var_name}'#{" checked" if value}></td>"
              @html_lines << "</tr>"

            elsif var_type == "S" and line.include? "<"
              value = Array.new

              populating_array = true
            
            elsif var_type == "S"
              value = line[/(?<==)[^#]*/]
              
              @html_lines << "<td>#{var_name}</td>"
              @html_lines << "<td><input type='text' id='#{var_name}' value='#{value}'></td>"
              @html_lines << "</tr>"


            end

            new_node = TreeNode.new(var_name, value)




            current_node << new_node
          end


        end

      end

      @html_lines << "</body>"
    end

  end
end

