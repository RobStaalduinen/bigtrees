module Nylas
  class Attachment
    def initialize(name:, type: 'application.pdf', file_path:)
      @name = name
      @type = type
      @file_path = file_path
    end

    def definition_entry
      {
        filename: @name,
        content_type: @type,
        content: Base64.strict_encode64(File.read(@file_path)),
      }
    end
  end
end