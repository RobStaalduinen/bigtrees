# frozen_string_literal: true

module Trackers
  class RepairRequests < Base
    def generate
      setup_worksheet("repair_request_template.xlsx", "RepairRequests.xlsx")
      requests = EquipmentRequest.submitted.includes(:vehicle, :arborist).order('equipment_requests.created_at DESC')

      requests.each_with_index do |request, i|
        row = i + 1

        insert(row, 0, request.created_at.strftime("%-d-%b-%Y"))
        insert(row, 1, request.category.capitalize)
        insert(row, 2, request.description)

        if request.image_path
          image_link = Rails.application.routes.url_helpers.images_url(image_path: request.image_path)
          link = %Q{HYPERLINK("#{image_link}","Image")}
          worksheet.add_cell(row, 3, '', link)
          worksheet[row][3].change_font_color('0000ff')
        else
          insert(row, 3, 'None')
        end
      end

      write_spreadsheet
    end
  end
end
