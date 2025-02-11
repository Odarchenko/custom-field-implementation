class Property < ApplicationRecord
  TEXT = "text".freeze
  NUMBER = "number".freeze
  SINGLE_SELECT = "single_select".freeze
  MULTI_SELECT = "multi_select".freeze

  FIELD_TYPES = [ TEXT, NUMBER, SINGLE_SELECT, MULTI_SELECT ].freeze

  belongs_to :tenant

  has_many :property_values, dependent: :destroy
  has_many :property_value_items, through: :property_values

  validates :name, presence: true
  validates :field_type, presence: true, inclusion: { in: FIELD_TYPES }
  validates :tenant_id, uniqueness: { scope: :name }
  validate :validate_options

  private

  def validate_options
    return unless [ SINGLE_SELECT, MULTI_SELECT ].include?(field_type)
    return if options.is_a?(Hash) && options["values"].is_a?(Array)

    errors.add(:options, "must be a hash with a 'values' key that is an array")
  end
end
