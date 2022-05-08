class Tree < ActiveRecord::Base
  belongs_to :estimate
  has_many :tree_images

  accepts_nested_attributes_for :tree_images

  scope :stumping_possible, -> { where(work_type: [0,3,4,5]) }

  enum work_type: {
    removal: 0,
    trim: 1,
    broken_limbs: 2,
    stump_removal: 3,
    other: 4,
    tree_services: 5,
    other_services: 6
  }

	WORK_TYPES = ['Tree Removal', 'Trim', 'Broken Limbs', 'Stump Removal', 'Other', 'Tree Services', 'Other Tree Services'].freeze

	def self.work_type_for_name(name)
		Tree::WORK_TYPES.index(name)
	end

	def work_name
    name = work_type.capitalize.gsub("_", " ")

    if work_type == 'removal' && stump_removal
      name += " + Stump Removal"
    end

    name
	end

	def stump_removal_answer
		(self.work_type == 'stump_removal' || self.stump_removal == true) ? 'Yes' : 'No'
	end

	def initial_costs
		costs = [Cost.json_cost(self.work_name, nil)]
		costs += [Cost.json_cost("Stump Removal", nil)] if self.stump_removal
		costs
	end
end
