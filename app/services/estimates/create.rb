module Estimates
  class Create
    def self.call(**kwargs)
      new(**kwargs).call
    end

    def initialize(estimate_params:, org:, current_user:, policy_scope:,
                   site_params: nil, customer_params: nil, customer_detail_params: nil,
                   job_attributes: nil)
      @estimate_params        = estimate_params
      @org                    = org
      @current_user           = current_user
      @policy_scope           = policy_scope
      @site_params            = site_params
      @customer_params        = customer_params
      @customer_detail_params = customer_detail_params
      @job_attributes         = job_attributes
    end

    def call
      estimate = Estimate.new(@estimate_params)
      estimate.arborist     = arborist_for(estimate)
      estimate.organization = @org
      estimate.save

      create_site(estimate)       if @site_params.present?
      create_customer(estimate)   if @customer_params.present?
      create_job(estimate)        if @job_attributes.present?

      estimate
    end

    private

    def arborist_for(_estimate)
      if @current_user.organization_memberships.exists?(organization: @org)
        @current_user
      else
        @org.default_arborist
      end
    end

    def create_site(estimate)
      site = estimate.site || Site.new(estimate: estimate)
      site.update(@site_params)
    end

    def create_customer(estimate)
      customer = @policy_scope.find_by(id: @customer_params[:id]) || Customer.create(@customer_params)
      estimate.update(customer: customer)

      customer_detail = estimate.customer_detail || CustomerDetail.new(estimate: estimate)
      customer_detail.update(@customer_detail_params)
    end

    def create_job(estimate)
      job = estimate.job || Job.new(estimate: estimate)
      job.update(@job_attributes)

      if @job_attributes[:assigned_arborists].present?
        @job_attributes[:assigned_arborists].each do |arborist_id|
          JobAssignment.create(job: job, arborist_id: arborist_id)
        end
      end
    end
  end
end
