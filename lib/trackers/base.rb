# frozen_string_literal: true

require 'fileutils'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

module Trackers
  class Base
    attr_reader :workbook, :worksheet, :template, :destination

    def setup_worksheet(template_name, destination_name)
      @template = Rails.root.join("lib", template_name)
      @destination = Rails.root.join("tmp", destination_name)

      FileUtils.cp(template, destination)

      @workbook = RubyXL::Parser.parse(template)
      @worksheet = workbook[0]
    end

    def insert(row, column, contents)
      worksheet.insert_cell(row, column, contents)
    end

    def write_spreadsheet
      workbook.write(destination)
    end
  end
end
