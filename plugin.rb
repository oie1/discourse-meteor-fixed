# frozen_string_literal: true
# name: discourse-meteor
# about: Meteor's OAuth Plugin
# version: 0.1
# authors: Robin Ward

enabled_site_setting :enable_login_with_meteor

gem "omniauth-oauth2", "1.7.1"

register_svg_icon "fab-meteor"

require_relative "lib/auth/meteor_authenticator"
require_relative "lib/validators/enable_login_with_meteor_validator"
require_relative "lib/omniauth/strategies/oauth2_meteor"

auth_provider authenticator: Auth::MeteorAuthenticator.new, icon: "fab-meteor"

register_css <<~CSS
  button.btn-social.meteor {
    background-color: #de4f4f;
  }
CSS
