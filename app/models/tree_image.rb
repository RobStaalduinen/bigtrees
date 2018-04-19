class TreeImage < ActiveRecord::Base
attr_accessible *column_names

# has_attached_file :pdf_ticket,
# :path =>  "ticketing/:rails_env/:class/:event_id/:reservation/:ticket_name.:content_type_extension"
end
