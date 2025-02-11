RSpec.describe PropertyValue, type: :model do
  describe 'associations' do
    it { should belong_to(:property) }
    it { should belong_to(:user) }
    it { should have_many(:property_value_items) }
  end
end
