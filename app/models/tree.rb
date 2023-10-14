class Tree < ActiveRecord::Base
  belongs_to :estimate
  has_many :tree_images

  accepts_nested_attributes_for :tree_images

  after_create :set_default_job_type

  scope :stumping_possible, -> { where(work_type: [0,3,4,5]) }

  enum work_type: {
    removal: 0,
    trim: 1,
    broken_limbs: 2,
    stump_removal: 3,
    other: 4,
    tree_services: 5
  }

  PROPERTY_JOB_TYPES = {
    tree_services: 'Tree Services',
    plumbing_and_water: 'Plumbing and Water',
    electrical_and_lighting: 'Electrical and Lighting',
    landscaping_and_garden_plants: 'Landscaping and Garden Plants',
    snow: 'Snow',
    windows_and_doors: 'Windows and Doors',
    flooring: 'Flooring',
    roof_and_siding: 'Roof and Siding',
    neighbours_and_neighbourhood: 'Neighbours and Neighbourhood',
    other: 'Other'
  }

  JOB_TYPES = {
    removal: 'Tree Removal',
    trim: 'Trim',
    broken_limbs: 'Broken Limbs',
    stump_removal: 'Stump Removal'
  }.merge(PROPERTY_JOB_TYPES)

	WORK_TYPES = ['Tree Removal', 'Trim', 'Broken Limbs', 'Stump Removal', 'Other', 'Tree Services'].freeze

	def self.work_type_for_name(name)
		Tree::WORK_TYPES.index(name)
	end

	def formatted_work_name(identifier)
		[WORK_TYPES[self[:work_type]], identifier].compact.join(" ")
	end

  def formatted_job_type
    name = JOB_TYPES[self.job_type.to_sym]

    if job_type == 'removal' && stump_removal
      name += " + Stump Removal"
    end

    name
  end

	def work_name
    name = work_type.capitalize.gsub("_", " ")

    if work_type == 'removal' && stump_removal
      name += " + Stump Removal"
    end

    name
	end

  def set_default_job_type
    return unless self.work_type && !self.job_type
    self.update(job_type: self.work_type)
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
