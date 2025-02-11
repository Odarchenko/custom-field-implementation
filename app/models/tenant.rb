class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :properties, dependent: :destroy

  validates :name, presence: true
end
