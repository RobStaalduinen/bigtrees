class Tree < ActiveRecord::Base
  belongs_to :estimate
  has_many :tree_images

  enum work_type: { 
		removal: 0,
		trim: 1, 
		broken_limbs: 2
	}
end
