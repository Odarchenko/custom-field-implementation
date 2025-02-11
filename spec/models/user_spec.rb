RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:tenant) }
    it { should have_many(:property_values).dependent(:destroy) }
    it { should have_many(:property_value_items).through(:property_values) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
