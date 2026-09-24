# frozen_string_literal: true

# Public, unauthenticated marketing + legal pages.
#
# These exist primarily to satisfy the Google OAuth verification and Microsoft
# publisher verification requirements for the Nylas email integration, which
# require a homepage, a terms of service URL and a privacy policy URL on the
# same domain as the app. They are plain ERB (no Vue) and use a self-contained
# layout so they render without the admin JS/CSS bundles.
class StaticPagesController < ApplicationController
  layout 'static_page'

  def home; end

  def terms; end

  def privacy; end
end
