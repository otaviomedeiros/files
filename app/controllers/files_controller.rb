class FilesController < ApplicationController

  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with name: "admin", password: "admin"

  def create
    user_file = UserFile.create!(params.permit(:name)) do |uf|
      tags = params.permit(tags: [])
      uf.tags << tags[:tags].map{|tag_name| Tag.find_or_create_by(name: tag_name)}
    end

    user_file.file.attach(params[:file])

    render json: user_file, status: :ok
  end

  def search
    tags_with_sign = params[:tag_search_query].scan(/(\+\w+|\-\w+)/).flatten
    positive_tags_with_sign = tags_with_sign.select{|tag| tag.start_with?('+')}
    negative_tags_with_sign = tags_with_sign.select{|tag| tag.start_with?('-')}

    normalized_positive_tags = positive_tags_with_sign.map{|tag| tag.slice(1, tag.size)}
    normalized_negative_tags = negative_tags_with_sign.map{|tag| tag.slice(1, tag.size)}

    user_files = UserFile.find_by_sql(%{
      select *
      from user_files uf
      where (
      	select count(*)
      	from tags_user_files tuf
      	inner join tags t on t.id = tuf.tag_id
      	where t.name in (#{normalized_positive_tags.map{|tag| "'#{tag}'"}.join(',')})
      	and tuf.user_file_id = uf.id
      ) = #{normalized_positive_tags.size}
      and (
      	select count(*)
      	from tags_user_files tuf
      	inner join tags t on t.id = tuf.tag_id
      	where t.name in (#{normalized_negative_tags.map{|tag| "'#{tag}'"}.join(',')})
      	and tuf.user_file_id = uf.id
      ) = 0
    })

    files = user_files.map do |user_file|
      file_info = { name: user_file.name }
      file_info[:url] = user_file.file.service_url if user_file.file.attached?
      file_info
    end

    render json: files, status: :ok
  end

end
