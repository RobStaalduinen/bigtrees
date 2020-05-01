module HoursHelper

  def iterate_through_arborist_hours(records)
    records.group_by { |w| w.arborist.name }.sort_by{ |name, _| name}.each do |name, arborist_records|
      yield(name, arborist_records)
    end
  end
end
