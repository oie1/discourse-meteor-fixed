# frozen_string_literal: true

module Validators
    class EnableLoginWithMeteorValidator
      def initialize
        @validator = SiteSettingValidator.new
      end
  
      def valid_value?(val)
        return true unless val
        @validator.valid?("meteor_client_id") && @validator.valid?("meteor_client_secret")
      end
    end
  end
  