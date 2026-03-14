# == Schema Information
#
# Table name: work_actions
#
#  id           :integer          not null, primary key
#  estimate_id  :integer          not null
#  work_type    :string(255)      not null
#  tree_index   :integer          not null
#  tree_stories :integer
#  info         :text(65535)
#  cost         :float(24)
#  status       :string(255)      not null
#
class WorkAction < ActiveRecord::Base
	
end
