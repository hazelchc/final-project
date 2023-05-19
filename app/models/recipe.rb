# == Schema Information
#
# Table name: recipes
#
#  id         :integer          not null, primary key
#  ingredient :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Recipe < ApplicationRecord
end
