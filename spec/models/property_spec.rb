RSpec.describe Property, type: :model do
  describe 'associations' do
    it { should belong_to(:tenant) }
    it { should have_many(:property_values).dependent(:destroy) }
    it { should have_many(:property_value_items).through(:property_values) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:field_type) }
    it { should validate_inclusion_of(:field_type).in_array(Property::FIELD_TYPES) }

    describe 'uniqueness' do
      subject { create(:property) }

      it { should validate_uniqueness_of(:tenant_id).scoped_to(:name) }
    end

    it 'validates options for single_select and multi_select' do
      property = build(:property, field_type: 'single_select', options: nil)
      expect(property).not_to be_valid
      expect(property.errors[:options]).to include("must be a hash with a 'values' key that is an array")
    end

    it 'validates that options.values is an array' do
      property = build(:property, field_type: 'single_select', options: { values: nil })
      expect(property).not_to be_valid
      expect(property.errors[:options]).to include("must be a hash with a 'values' key that is an array")
    end
  end
end
