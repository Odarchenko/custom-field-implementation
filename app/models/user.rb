class User < ApplicationRecord
  belongs_to :tenant
  has_many :property_values, dependent: :destroy
  has_many :property_value_items, through: :property_values
  has_many :update_properties_requests, dependent: :destroy

  validates :name, presence: true
end
