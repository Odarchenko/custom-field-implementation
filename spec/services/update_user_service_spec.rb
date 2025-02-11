RSpec.describe UpdateUserService do
  subject { described_class.update_user(user, user_params) }

  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:text_property) { create(:property, :text, tenant: tenant, name: 'description') }

  describe '.call' do
    context 'when updating without property values' do
      let(:user_params) { {} }

      it 'returns the user without changes' do
        expect(subject).to eq(user)
      end
    end

    context 'when updating with property values' do
      let(:user_params) do
        {
          property_values: [ { name: text_property.name, value: 'New description' } ]
        }
      end

      it 'updates the user property values' do
        expect(UpdatePropertyValuesService).to receive(:update_property_values)
          .with(user, user_params[:property_values])
          .and_return(user)

        expect(subject).to eq(user)
      end
    end

    context 'when property values update fails' do
      let(:user_params) do
        {
          property_values: [ { name: text_property.name, value: 'New description' } ]
        }
      end

      before do
        allow(UpdatePropertyValuesService).to receive(:update_property_values)
          .with(user, user_params[:property_values])
          .and_return(user)

        user.errors.add(:property_values, 'Invalid property value')
      end

      it 'returns user with errors' do
        result = subject
        expect(result.errors[:property_values]).to include('Invalid property value')
      end
    end
  end
end
