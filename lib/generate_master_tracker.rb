require 'fileutils'

class GenerateMasterTracker

  def self.call(estimates)
    template = Rails.root.join("lib", "tracker_template.xlsx")
    destination = Rails.root.join("tmp", "MasterTracker.xlsx")

    FileUtils.cp(template, destination)

    workbook = RubyXL::Parser.parse(template)
    worksheet = workbook[0]

    estimates = estimates.includes(:trees).includes(:arborist).order("work_date ASC")

    estimates.each_with_index do |estimate, i|
      row = 2 + i
      contact = estimate.preferred_contact || ""
      discount = estimate.discount_applied ? "YES" : "NO"

      insert(worksheet, row, 0, estimate.invoice_number)
      insert(worksheet, row, 1, estimate.work_date.strftime("%d-%b-%Y"))
      insert(worksheet, row, 2, estimate.person_name)
      insert(worksheet, row, 3, estimate.street)
      insert(worksheet, row, 4, estimate.city)
      insert(worksheet, row, 5, estimate.trees.count)
      insert(worksheet, row, 6, estimate.trees.first.work_name) rescue ""
      insert(worksheet, row, 7, contact.capitalize)
      insert(worksheet, row, 8, estimate.phone)
      insert(worksheet, row, 9, estimate.email)
      insert(worksheet, row, 10, discount)

      insert(worksheet, row, 11, estimate.total_cost)
      insert(worksheet, row, 12, estimate.total_cost * 0.13)
      insert(worksheet, row, 12, estimate.total_cost * 1.13)
      insert(worksheet, row, 13, estimate.outstanding_amount * 1.13)

      raw_link = Rails.application.routes.url_helpers.admin_estimates_url(id: 1)
      link = %Q{HYPERLINK("#{raw_link}","Estimate")}
      worksheet.add_cell(row, 26, '', link)
      worksheet[row][26].change_font_color('0000ff')

    end

    workbook.write(destination)
  end


  def self.insert(worksheet, row, column, contents)
    worksheet.insert_cell(row, column, contents)
  end

end
