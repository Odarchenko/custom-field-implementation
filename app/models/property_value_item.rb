class PropertyValueItem < ApplicationRecord
  belongs_to :property_value

  validates :value, presence: true
  validates :value, uniqueness: { scope: :property_value_id }
end
