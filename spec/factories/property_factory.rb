FactoryBot.define do
  factory :property do
    tenant
    sequence(:name) { |n| "Property #{n}" }
    field_type { Property::TEXT }

    trait :text do
      field_type { Property::TEXT }
    end

    trait :number do
      field_type { Property::NUMBER }
    end

    trait :single_select do
      field_type { Property::SINGLE_SELECT }
      options { { 'values' => [ 'Option 1', 'Option 2' ] } }
    end

    trait :multi_select do
      field_type { Property::MULTI_SELECT }
      options { { 'values' => [ 'Option 1', 'Option 2', 'Option 3' ] } }
    end
  end
end
