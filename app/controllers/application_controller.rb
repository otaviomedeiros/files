class ApplicationController < ActionController::API
  before_action do
    ActiveStorage::Current.host = Rails.application.routes.default_url_options[:host]
  end
end
