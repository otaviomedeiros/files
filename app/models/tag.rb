class Tag < ApplicationRecord
  has_and_belongs_to_many :user_files

  scope :all_tags_associated_with_matching_files, ->(positive_tags, negative_tags) do
    Tag.find_by_sql(%{
      SELECT tt.name as name, count(user_files.id) as count
      FROM user_files
      inner join tags_user_files ttuf on ttuf.user_file_id = user_files.id
      inner join tags tt on tt.id = ttuf.tag_id
      WHERE (
            (
            	select count(*)
            	from tags_user_files tuf
            	inner join tags t on t.id = tuf.tag_id
            	where t.name in (#{positive_tags.map{|tag| "'#{tag}'"}.join(',')})
            	and tuf.user_file_id = user_files.id
            ) = #{positive_tags.size}
          ) AND (
            not exists(
              select t.id
            	from tags_user_files tuf
            	inner join tags t on t.id = tuf.tag_id
            	where t.name in (#{negative_tags.map{|tag| "'#{tag}'"}.join(',')})
            	and tuf.user_file_id = user_files.id
            )
          )
      group by tt.name
      })
  end
end
