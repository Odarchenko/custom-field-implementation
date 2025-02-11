RSpec.describe UpdateTenantService do
  let(:subject) { described_class.update_tenant(tenant, tenant_params) }
  let(:tenant)        { create(:tenant) }
  let(:tenant_params) { { property_params: property_params } }

  describe '.update_tenant' do
    context 'when creating new properties' do
      let(:property_params) do
        [
          {
            name: 'age',
            field_type: 'number'
          },
          {
            name: 'status',
            field_type: 'single_select',
            options: { values: [ 'active', 'inactive' ] }
          }
        ]
      end

      it 'creates new properties for the tenant' do
        expect { subject }.to change(Property, :count).by(2)
      end

      it 'creates new properties with the correct field types' do
        subject

        expect(tenant.properties.first).to have_attributes(name: 'age', field_type: 'number')
        expect(tenant.properties.last).to have_attributes(name: 'status', field_type: 'single_select')
      end
    end

    context 'when updating existing properties' do
      let!(:existing_property) do
        create(:property,
          tenant: tenant,
          name: 'age',
          field_type: 'text'
        )
      end

      let(:property_params) do
        [
          {
            name: 'age',
            field_type: 'number'
          }
        ]
      end

      it 'does not create new properties' do
        expect { subject }.not_to change(Property, :count)
      end

      it 'updates existing property' do
        subject

        existing_property.reload
        expect(existing_property).to have_attributes(name: 'age', field_type: 'number')
      end
    end

    context 'when property params are invalid' do
      let(:property_params) do
        [
          {
            name: '',
            field_type: 'number'
          }
        ]
      end

      it 'adds errors to tenant and does not create properties' do
        expect { subject }.not_to change(Property, :count)

        expect(tenant.errors[:properties]).to be_present
      end
    end

    context 'when property has invalid field_type' do
      let(:property_params) do
        [
          {
            name: 'age',
            field_type: 'invalid_type'
          }
        ]
      end

      let(:tenant_params) do
        { property_params: property_params }
      end

      it 'adds errors to tenant and does not create properties' do
        expect { subject }.not_to change(Property, :count)

        expect(tenant.errors[:properties]).to be_present
      end
    end

    context 'when trying to create duplicate property names' do
      let(:property_params) do
        [
          {
            name: 'age',
            field_type: 'number',
            options: { min: 0, max: 100 }
          },
          {
            name: 'age',
            field_type: 'text',
            options: {}
          }
        ]
      end


      it 'raises an error and does not create any properties' do
        expect { subject }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end
