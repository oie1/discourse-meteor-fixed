# frozen_string_literal: true

module Auth
    class MeteorAuthenticator < ::Auth::Authenticator
      def name
        "meteor"
      end
  
      def register_middleware(omniauth)
        omniauth.provider(
          :oauth2_meteor,
          name: "meteor",
          client_id: SiteSetting.meteor_client_id,
          client_secret: SiteSetting.meteor_client_secret,
          provider_ignores_state: true,
          client_options: {
            site: "https://accounts.meteor.com",
            authorize_url: "/oauth2/authorize",
            token_url: "/oauth2/token",
          },
        )
      end
  
      def after_authenticate(auth)
        result = Auth::Result.new
        token = Addressable::URI.escape(auth["credentials"]["token"])
        token.gsub!(/\+/, "%2B")
  
        bearer_token = "Bearer #{token}"
        connection = Faraday.new { |f| f.adapter FinalDestination::FaradayAdapter }
        headers = { "Authorization" => bearer_token, "Accept" => "application/json" }
        response =
          connection.run_request(:get, "https://accounts.meteor.com/api/v1/identity", nil, headers)
        user = JSON.parse(response.body)
  
        result.username = user["username"]
        if user["emails"].present?
          email = user["emails"].find { |e| e["primary"] }
          if email.present?
            result.email = email["address"]
            result.email_valid = email["verified"]
          end
        end
  
        current_info = ::PluginStore.get("meteor", "meteor_user_#{user["id"]}")
        result.user = User.where(id: current_info[:user_id]).first if current_info
  
        result.user ||= User.find_by_email(result.email) if result.email && result.email_valid
  
        result.extra_data = { meteor_user_id: user["id"] }
        result
      end
  
      def after_create_account(user, auth)
        ::PluginStore.set(
          "meteor",
          "meteor_user_#{auth[:extra_data][:meteor_user_id]}",
          { user_id: user.id },
        )
      end
  
      def enabled?
        SiteSetting.enable_login_with_meteor
      end
    end
  end
  