
module Excel
  class Writer

    def initialize(template_file_name, destination_file_name)
      @template_file_name = template_file_name
      @destination_file_name = destination_file_name
      @worksheet_index = 0
    end

    def []=(x, y, content)
      worksheet.add_cell(x, y, content)
    end

    def write_row(row, contents)
      contents.each_with_index do |content, column|
        self[row, column] = content
      end
    end

    def set_worksheet(index)
      @worksheet = workbook[index] 
    end

    def destination
      @destination ||= Rails.root.join("tmp", @destination_file_name)
    end

    def save
      FileUtils.cp(template, destination)
      workbook.write(destination)
    end

    private

      def worksheet
        @worksheet ||= workbook[@worksheet_index]
      end

      def workbook
        @workbook ||= init_workbook
      end

      def init_workbook
        RubyXL::Parser.parse(template)
      end

      def template
        Rails.root.join("lib", "templates", @template_file_name)
      end

  end
end
