require 'addressable/uri'

module URI
  def self.escape(url)
    Addressable::URI.encode(url)
  end
end