client_id = ENV["GOOGLE_CLIENT_ID"]
client_secret = ENV["GOOGLE_CLIENT_SECRET"]

if client_id.present? && client_secret.present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
             client_id,
             client_secret,
             scope: "userinfo.email,userinfo.profile",
             prompt: "select_account",
             access_type: "offline",
             image_aspect_ratio: "square",
             image_size: 200
  end
else
  Rails.logger.warn("Google OAuth not configured. Missing GOOGLE_CLIENT_ID and/or GOOGLE_CLIENT_SECRET.")
end

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.silence_get_warning = true
OmniAuth.config.logger = Rails.logger
