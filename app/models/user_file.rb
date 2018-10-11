class UserFile < ApplicationRecord
  has_one_attached :file
  has_and_belongs_to_many :tags

  scope :tag_search_query, ->(positive_tags, negative_tags) do
    find_by_sql(%{
      select *
      from user_files uf
      where (
      	select count(*)
      	from tags_user_files tuf
      	inner join tags t on t.id = tuf.tag_id
      	where t.name in (#{positive_tags.map{|tag| "'#{tag}'"}.join(',')})
      	and tuf.user_file_id = uf.id
      ) = #{positive_tags.size}
      and (
      	select count(*)
      	from tags_user_files tuf
      	inner join tags t on t.id = tuf.tag_id
      	where t.name in (#{negative_tags.map{|tag| "'#{tag}'"}.join(',')})
      	and tuf.user_file_id = uf.id
      ) = 0
    })
  end
end
