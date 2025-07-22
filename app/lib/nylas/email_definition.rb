module Nylas
  class EmailDefinition
    def initialize(to:, subject:, outgoing_name:, body:, bcc: [])
      @to = to
      @subject = subject
      @body = body
      @outgoing_name = outgoing_name
      @bcc = bcc
    end
    attr_reader :to, :subject, :body, :outgoing_name

    def receipient_list
      if to.is_a?(Array)
        to.map { |email| { email: email } }
      else
        [{ email: to }]
      end
    end

    def bcc_list
      if @bcc.is_a?(Array)
        @bcc.map { |email| { email: email } }
      else
        [{ email: @bcc }]
      end
    end
  end
end