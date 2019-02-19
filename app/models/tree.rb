class Tree < ActiveRecord::Base
  belongs_to :estimate
  has_many :tree_images

  enum work_type: { 
		removal: 0,
		trim: 1, 
		broken_limbs: 2
	}

	WORK_NAMES={'removal' => "Removal", 'trim' => "Trim", 'broken_limbs' => "Broken Limbs"}

	def work_name_for_type
		WORK_NAMES[self.work_type]
	end
end
