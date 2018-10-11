class CreateJoinTableUserFileTag < ActiveRecord::Migration[5.2]
  def change
    create_join_table :user_files, :tags do |t|
      t.index [:user_file_id, :tag_id]
      t.index [:tag_id, :user_file_id]
    end
  end
end
