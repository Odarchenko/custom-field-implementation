FactoryBot.define do
  factory :user do
    tenant
    sequence(:name) { |n| "User #{n}" }
  end
end
