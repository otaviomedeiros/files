class FilesController < ApplicationController

  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with name: "admin", password: "admin"

  def create
    user_file = UserFile.create!(params.permit(:name))
    user_file.file.attach(params[:file])

    render json: user_file, status: :ok
  end

  def index
    user_files = UserFile.all

    files = user_files.map do |user_file|
      file_info = { name: user_file.name }
      file_info[:url] = user_file.file.service_url if user_file.file.attached?
      file_info
    end

    render json: files, status: :ok
  end

end
