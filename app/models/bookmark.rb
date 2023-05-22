# == Schema Information
#
# Table name: bookmarks
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  message_id :integer
#  user_id    :integer
#
class Bookmark < ApplicationRecord
  belongs_to :user, :required=> true
  belongs_to :message, :required=> true

  belongs_to(:recipe_to_bookmark, {
    :class_name => "Message",
    :foreign_key => "message_id"
  })

end
