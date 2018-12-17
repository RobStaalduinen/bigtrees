class Tree < ActiveRecord::Base
  belongs_to :estimate

  enum work_type: { 
		removal: 0,
		trim: 1, 
		broken_limbs: 2
	}
end
