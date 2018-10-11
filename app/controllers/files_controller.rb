require File.dirname(__FILE__) + '/../parser/tag_search_query_parser'

class FilesController < ApplicationController

  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with name: "admin", password: "admin"

  LIMIT = 10

  def create
    user_file = UserFile.create!(params.permit(:name)) do |uf|
      tags = params.permit(tags: [])
      uf.tags << tags[:tags].map{|tag_name| Tag.find_or_create_by(name: tag_name)}
    end

    user_file.file.attach(params[:file])

    render json: { url: user_file.file.service_url }, status: :ok
  end

  def search
    tags_parsers = TagSearchQueryParser.new(params[:tag_search_query])
    tags = tags_parsers.parse

    user_files = UserFile.tag_search_query(tags[:+], tags[:-])
      .limit(limit)
      .offset((params[:page].to_i - 1) * limit)
      .order(:id)

    all_tags_associated_with_matching_files = Tag.all_tags_associated_with_matching_files(tags[:+], tags[:-])

    render json: {
      total_records: UserFile.tag_search_query(tags[:+], tags[:-]).count,
      related_tags: related_tags(all_tags_associated_with_matching_files),
      records: records(user_files)
    }
  end

  private

  def limit
    params[:limit] ? params[:limit].to_i : LIMIT
  end

  def records(user_files)
    user_files.map do |user_file|
      file_info = { name: user_file.name }
      file_info[:url] = user_file.file.service_url if user_file.file.attached?
      file_info
    end
  end

  def related_tags(tags)
    tags.map{|tag| { tag: tag.name, file_count: tag.count }}
  end

end
