# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Oauth2Meteor < OmniAuth::Strategies::OAuth2
      option :name, "oauth2_meteor"

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
