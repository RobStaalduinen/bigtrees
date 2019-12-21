module StatusDriver
  extend ActiveSupport::Concern
  
  included do
    after_update :update_estimate_status

    def update_estimate_status
      self.estimate.save!
    end
  end
end
