# == Schema Information
#
# Table name: notes
#
#  id          :integer          not null, primary key
#  body        :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  bookmark_id :integer
#  user_id     :integer
#
class Note < ApplicationRecord

  has_many(:notes, {
    :class_name => "Bookmark",
    :foreign_key => "bookmark_id"
  })
end
