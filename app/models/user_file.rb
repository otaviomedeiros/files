class UserFile < ApplicationRecord
  has_one_attached :file
  has_and_belongs_to_many :tags

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
end
