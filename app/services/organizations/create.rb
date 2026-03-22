# frozen_string_literal: true

module Organizations
  class Create
    JOB_SURVEY_QUESTIONS = [
      'If necessary, I have made contact with the homeowner',
      'Crew understands the work required',
      'Crew is aware if the hazards on site',
      'Crew is wearing proper safety gear',
      'If necessary, traffic control is properly set up',
      'Are power lines present?'
    ].freeze

    COMPLETION_SURVEY_QUESTIONS = [
      'The customer is happy with the work.',
      'The customer paid on site.'
    ].freeze

    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @name            = params[:name]
      @legal_name      = params[:legal_name]
      @email           = params[:email]
      @website         = params[:website]
      @contact_person  = params[:contact_person]
      @logo_url        = params[:logo_url]
      @primary_colour  = params[:primary_colour]
      @secondary_colour = params[:secondary_colour]
    end

    def call
      ActiveRecord::Base.transaction do
        create_organization
        create_address
        populate_survey_questions
        create_default_tags
        create_admin_arborist
      end

      { organization: @organization, temporary_password: @temporary_password }
    end

    private

    def create_organization
      @organization = Organization.create!(
        name: @name,
        legal_name: @legal_name,
        email: @email,
        website: @website,
        logo_url: @logo_url,
        primary_colour: @primary_colour,
        secondary_colour: @secondary_colour,
        configuration: {}
      )
    end

    def create_address
      Address.create!(addressable: @organization)
    end

    def populate_survey_questions
      @organization.update!(
        job_survey_questions: JOB_SURVEY_QUESTIONS,
        completion_survey_questions: COMPLETION_SURVEY_QUESTIONS
      )
    end

    def create_default_tags
      Tag.create_default(@organization)
    end

    def create_admin_arborist
      @temporary_password = SecureRandom.hex(8)

      arborist = Arborist.create!(
        name: @contact_person,
        email: @email,
        role: 'admin',
        password: @temporary_password,
        password_confirmation: @temporary_password
      )

      OrganizationMembership.create!(
        organization: @organization,
        arborist: arborist
      )
    end
  end
end
