FactoryBot.define do
  factory :property_value_item do
    association :property_value

    sequence(:value) { |n| "Item #{n}" }
  end
end
