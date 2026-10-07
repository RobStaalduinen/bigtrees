# frozen_string_literal: true

module Trackers
  class RepairRequests < Base
    def generate(equipment_requests)
      setup_worksheet("repair_request_template.xlsx", "RepairRequests.xlsx")
      requests = equipment_requests.submitted.includes(:vehicle, :arborist, :images).order('equipment_requests.created_at DESC')

      requests.each_with_index do |request, i|
        row = i + 1

        insert(row, 0, request.created_at.strftime("%-d-%b-%Y"))
        insert(row, 1, request.category.capitalize)
        insert(row, 2, request.description)

        image_urls = request.image_urls

        if image_urls.any?
          # One hyperlink per cell: the first image links from column 3, any
          # further images spill into the columns to its right.
          image_urls.each_with_index do |image_url, offset|
            label = image_urls.size > 1 ? "Image #{offset + 1}" : 'Image'
            link = %Q{HYPERLINK("#{image_url}","#{label}")}
            worksheet.add_cell(row, 3 + offset, '', link)
            worksheet[row][3 + offset].change_font_color('0000ff')
          end
        else
          insert(row, 3, 'None')
        end
      end

      write_spreadsheet
    end
  end
end
