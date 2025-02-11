require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'PATCH #update' do
    let!(:tenant) { create(:tenant) }
    let!(:text_property) { create(:property, tenant: tenant, name: 'property_1', field_type: Property::TEXT) }
    let!(:select_property) { create(:property, tenant: tenant, name: 'property_2', field_type: Property::SINGLE_SELECT, options: { "values" => [ "value_1", "value_2" ] }) }
    let!(:user) { create(:user, tenant: tenant) }

    let(:property_values) { [
      { name: 'property_1', value: 'text_value' },
      { name: 'property_2', value: 'value_1' }
    ] }

    context 'with valid parameters' do
      before do
        patch :update, params: { id: user.id, users: { property_values: property_values } }
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns user id in response' do
        expect(JSON.parse(response.body)['user_id']).to eq(user.id)
      end

      it 'updates the user property values' do
        expect(user.property_values.count).to eq(2)
        expect(user.property_value_items.count).to eq(2)

        text_value = user.property_values.find_by(property: text_property)
        expect(text_value.property_value_items.first.value).to eq('text_value')

        select_value = user.property_values.find_by(property: select_property)
        expect(select_value.property_value_items.first.value).to eq('value_1')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_property_values) { [
        { name: 'property_2', value: 'invalid_option' }  # value not in options
      ] }

      before do
        patch :update, params: { id: user.id, users: { property_values: invalid_property_values } }
      end

      it 'returns unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors in response' do
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end

    context 'with invalid user id' do
      before do
        patch :update, params: { id: 'invalid_id', users: { property_values: property_values } }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
