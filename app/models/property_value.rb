class PropertyValue < ApplicationRecord
  belongs_to :property
  belongs_to :user

  has_many :property_value_items, dependent: :destroy
end
