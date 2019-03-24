class Tree < ActiveRecord::Base
  belongs_to :estimate
	has_many :tree_images
	
	accepts_nested_attributes_for :tree_images

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

	def stump_removal_answer
		self.stump_removal? ? 'Yes' : 'No'
	end
end
