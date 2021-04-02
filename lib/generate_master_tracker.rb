require 'fileutils'
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

class GenerateMasterTracker

  def self.call(estimates)
    template = Rails.root.join("lib", "tracker_template.xlsx")
    destination = Rails.root.join("tmp", "MasterTracker.xlsx")

    FileUtils.cp(template, destination)

    workbook = RubyXL::Parser.parse(template)
    worksheet = workbook[0]

    estimates = estimates.includes(:trees, :arborist, :invoice, :customer, :site, :costs).order("created_at ASC, status DESC")

    estimates.each_with_index do |estimate, i|
      row = 1 + i
      discount = estimate.invoice && estimate.invoice.discount ? "YES" : "NO"
      customer = estimate.customer || Customer.new
      contact = customer&.preferred_contact || ""

      insert(worksheet, row, 0, !estimate.is_unknown ? estimate.invoice.number : 'UNKNOWN')
      insert(worksheet, row, 1, estimate.status.gsub("_", " ").capitalize)

      insert(worksheet, row, 2, estimate.created_at.strftime("%-d-%b-%Y")) rescue ""
      insert(worksheet, row, 3, estimate.created_at.strftime("%B")) rescue ""
      insert(worksheet, row, 4, estimate.created_at.strftime("%Y")) rescue ""


      insert(worksheet, row, 5, estimate.invoice.paid_at.strftime("%-d-%b-%Y")) rescue ""
      insert(worksheet, row, 6, estimate.invoice.paid_at.strftime("%B")) rescue ""
      insert(worksheet, row, 7, estimate.invoice.paid_at.strftime("%Y")) rescue ""

      insert(worksheet, row, 8, customer.name)
      insert(worksheet, row, 9, estimate.street || estimate.site&.address&.street)
      insert(worksheet, row, 10, estimate.city || estimate.site&.address&.city)
      insert(worksheet, row, 11, estimate.trees.count)
      insert(worksheet, row, 12, estimate.trees.first.work_name) rescue ""
      insert(worksheet, row, 13, contact.capitalize)
      insert(worksheet, row, 14, customer.phone)
      insert(worksheet, row, 15, customer.email)
      insert(worksheet, row, 16, discount)

      if estimate.quote_sent_date.present?
        insert(worksheet, row, 17, estimate.total_cost)
        insert(worksheet, row, 18, estimate.total_cost * 0.13)
        insert(worksheet, row, 19, estimate.total_cost * 1.13)

        if estimate.invoice.present? && estimate.invoice.sent_at.present? && !estimate.is_unknown
          insert(worksheet, row, 20, estimate.outstanding_amount * 1.13)
        end
      end
      raw_link = Rails.application.routes.url_helpers.estimate_path(estimate)
      link = %Q{HYPERLINK("#{raw_link}","Estimate")}
      worksheet.add_cell(row, 33, '', link)
      worksheet[row][33].change_font_color('0000ff')

    end

    workbook.write(destination)
  end


  def self.insert(worksheet, row, column, contents)
    worksheet.insert_cell(row, column, contents)
  end

end
