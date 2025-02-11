RSpec.describe PropertyValueItem, type: :model do
  describe 'associations' do
    it { should belong_to(:property_value) }
  end

  describe 'validations' do
    it { should validate_presence_of(:value) }

    describe 'uniqueness' do
      subject { create(:property_value_item) }
      it { should validate_uniqueness_of(:value).scoped_to(:property_value_id) }
    end
  end
end
