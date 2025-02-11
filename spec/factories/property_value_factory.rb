FactoryBot.define do
  factory :property_value do
    association :property
    association :user
  end
end
