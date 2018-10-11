class Tag < ApplicationRecord
  has_and_belongs_to_many :user_files

  scope :all_tags_associated_with_matching_files, ->(positive_tags, negative_tags) do
    Tag.select('tags.name, count(tags.name) as count')
      .joins(:user_files)
      .where(tags_user_files: {
        user_file_id: UserFile.tag_search_query(positive_tags, negative_tags).pluck(:id)
      })
      .group('tags.name')
  end
end
