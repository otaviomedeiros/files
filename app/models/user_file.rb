class UserFile < ApplicationRecord
  has_one_attached :file
  has_and_belongs_to_many :tags

  validates_presence_of :name, :tags

  scope :contains_all_tags, ->(tags) do
    where(%{
      (
      	select count(*)
      	from tags_user_files tuf
      	inner join tags t on t.id = tuf.tag_id
      	where t.name in (?)
      	and tuf.user_file_id = user_files.id
      ) = ?
    }, tags, tags.size)
  end

  scope :do_not_contain_any_tag, ->(tags) do
    where(%{
      not exists(
        select t.id
      	from tags_user_files tuf
      	inner join tags t on t.id = tuf.tag_id
      	where t.name in (?)
      	and tuf.user_file_id = user_files.id
      )
    }, tags)
  end

  scope :tag_search_query, ->(positive_tags, negative_tags) do
    query = self
    query = contains_all_tags(positive_tags) unless positive_tags.empty?
    query = query.do_not_contain_any_tag(negative_tags) unless negative_tags.empty?
    query
  end

  def self.create_file_with_tags(params = { name: nil, file: nil, tags: [] })
    user_file = UserFile.create(name: params[:name]) do |uf|
      uf.tags << (params[:tags] || []).map{|tag_name| Tag.find_or_create_by(name: tag_name)}
    end

    user_file.file.attach(params[:file]) if user_file.persisted?
    user_file
  end
end
