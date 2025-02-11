require 'rails_helper'

RSpec.describe Api::V1::TenantsController, type: :controller do
  describe 'PATCH #update' do
    let(:tenant) { create(:tenant) }

    context 'with valid parameters' do
      let(:valid_properties) do
        {
          property_params: [
            {
              name: 'department',
              field_type: 'single_select',
              options: { values: [ 'A', 'B', 'C' ] }
            }
          ]
        }
      end

      before do
        patch :update, params: { id: tenant.id, properties: valid_properties }
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns tenant id in response' do
        expect(JSON.parse(response.body)['tenant_id']).to eq(tenant.id)
      end

      it 'creates new property for the tenant' do
        expect(tenant.properties.count).to eq(1)
        property = tenant.properties.first
        expect(property.name).to eq('department')
        expect(property.field_type).to eq('single_select')
        expect(property.options).to eq({ 'values' => [ 'A', 'B', 'C' ] })
      end
    end

    context 'without options' do
      let(:valid_properties) do
        {
          property_params: [
            {
              name: 'department',
              field_type: 'text'
            }
          ]
        }
      end

      before do
        patch :update, params: { id: tenant.id, properties: valid_properties }
      end

      it 'returns success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns tenant id in response' do
        expect(JSON.parse(response.body)['tenant_id']).to eq(tenant.id)
      end

      it 'creates new property for the tenant' do
        expect(tenant.properties.count).to eq(1)
        property = tenant.properties.first
        expect(property.name).to eq('department')
        expect(property.field_type).to eq('text')
        expect(property.options).to eq({})
      end
    end

    context 'with invalid parameters' do
      let(:invalid_properties) do
        {
          property_params: [
            {
              name: 'department',
              field_type: 'invalid_type',
              options: []
            }
          ]
        }
      end

      before do
        patch :update, params: { id: tenant.id, properties: invalid_properties }
      end

      it 'returns unprocessable_entity status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns errors in response' do
        expect(JSON.parse(response.body)).to have_key('errors')
      end

      it 'does not update the tenant' do
        original_name = tenant.name
        tenant.reload
        expect(tenant.name).to eq(original_name)
      end

      it 'does not create new properties' do
        expect(tenant.properties.count).to eq(0)
      end
    end

    context 'with invalid tenant id' do
      before do
        patch :update, params: { id: 'invalid_id', properties: {} }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
