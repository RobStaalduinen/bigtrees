class Tree < ActiveRecord::Base
  belongs_to :estimate
	has_many :tree_images
	
	accepts_nested_attributes_for :tree_images

	scope :stumping_possible, -> { where(work_type: [0,3]) }

  enum work_type: { 
		removal: 0,
		trim: 1, 
		broken_limbs: 2,
		stump_removal: 3
	}

	#WORK_NAMES={'removal' => "Removal", 'trim' => "Trim", 'broken_limbs' => "Broken Limbs"}
	WORK_TYPES = ['Tree Removal', 'Trim', 'Broken Limbs', 'Stump Removal'].freeze

	def self.work_type_for_name(name)
		Tree::WORK_TYPES.index(name)
	end

	def formatted_work_name(identifier)
		[WORK_TYPES[self[:work_type]], identifier].compact.join(" ")
	end

	def work_name
		self.work_type.capitalize.gsub("_", " ")
	end

	def stump_removal_answer
		(self.work_type == 'stump_removal' || self.stump_removal == true) ? 'Yes' : 'No'
	end
end
