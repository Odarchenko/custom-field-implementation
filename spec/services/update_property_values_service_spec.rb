RSpec.describe UpdatePropertyValuesService do
  let(:subject) { described_class.update_property_values(user, property_values) }

  let(:tenant) { create(:tenant) }
  let(:user)   { create(:user, tenant: tenant) }

  let(:text_property) { create(:property, :text, tenant: tenant, name: 'text') }
  let(:number_property) { create(:property, :number, tenant: tenant, name: 'number') }
  let(:single_select_property) do
    create(:property, :single_select, tenant: tenant,
                                      name: 'single_select',
                                      options: { 'values' => [ 'Test A', 'Test B' ] })
  end
  let(:multi_select_property) do
    create(:property, :multi_select, tenant: tenant,
                                     name: 'multi_select',
                                     options: { 'values' => [ 'a', 'b', 'c' ] })
  end

  describe '.update_property_values' do
    context 'with text property' do
      context 'when value is valid' do
        let(:property_values) do
          [
            { name: text_property.name, value: 'Test' }
          ]
        end

        it 'creates property value with items' do
          expect { subject }.to change(PropertyValue, :count).by(1)
                          .and change(PropertyValueItem, :count).by(1)

          property_value = PropertyValue.last
          expect(property_value.property_value_items.first.value).to eq('Test')
        end
      end

      context 'with invalid value type' do
        let(:property_values) do
          [
            { name: text_property.name, value: 123 }
          ]
        end

        it 'adds error for invalid value type' do
          subject
          expect(user.errors[:property_values]).to include("Property #{text_property.name} has invalid value")
        end
      end
    end

    context 'with number property' do
      context 'when value is valid' do
        let(:property_values) do
          [
            { name: number_property.name, value: 42 }
          ]
        end

        it 'creates property value with items' do
          expect { subject }.to change(PropertyValue, :count).by(1)
                          .and change(PropertyValueItem, :count).by(1)

          property_value = PropertyValue.last
          expect(property_value.property_value_items.first.value).to eq('42')
        end
      end

      context 'with invalid value type' do
        let(:property_values) do
          [
            { name: number_property.name, value: 'not a number' }
          ]
        end

        it 'adds error for invalid value type' do
          subject
          expect(user.errors[:property_values]).to include("Property #{number_property.name} has invalid value")
        end
      end
    end

    context 'with single select property' do
      context 'when value is valid' do
        let(:property_values) do
          [
            { name: single_select_property.name, value: 'Test A' }
          ]
        end

        it 'creates property value with items' do
          expect { subject }.to change(PropertyValue, :count).by(1)
                          .and change(PropertyValueItem, :count).by(1)

          property_value = PropertyValue.last
          expect(property_value.property_value_items.first.value).to eq('Test A')
        end
      end

      context 'with invalid option' do
        let(:property_values) do
          [
            { name: single_select_property.name, value: 'Invalid' }
          ]
        end

        it 'adds error for invalid option' do
          subject
          expect(user.errors[:property_values]).to include("Property #{single_select_property.name} has invalid value")
        end
      end
    end

    context 'with multi select property' do
      context 'when value is valid' do
        let(:property_values) do
          [
            { name: multi_select_property.name, value: [ 'a', 'b' ] }
          ]
        end

        it 'creates property value with items' do
          expect { subject }.to change(PropertyValue, :count).by(1)
                          .and change(PropertyValueItem, :count).by(2)

          property_value = PropertyValue.last
          expect(property_value.property_value_items.pluck(:value)).to match_array([ 'a', 'b' ])
        end
      end

      context 'with invalid value type' do
        let(:property_values) do
          [
            { name: multi_select_property.name, value: 'not an array' }
          ]
        end

        it 'adds error for invalid value type' do
          subject
          expect(user.errors[:property_values]).to include("Property #{multi_select_property.name} has invalid value")
        end
      end

      context 'with invalid options' do
        let(:property_values) do
          [
            { name: multi_select_property.name, value: [ 'Ruby', 'Invalid' ] }
          ]
        end

        it 'adds error for invalid options' do
          subject
          expect(user.errors[:property_values]).to include("Property #{multi_select_property.name} has invalid value")
        end
      end
    end

    context 'with multiple properties' do
      let(:property_values) do
        [
          { name: text_property.name, value: 'Test' },
          { name: number_property.name, value: 42 },
          { name: single_select_property.name, value: 'Test A' },
          { name: multi_select_property.name, value: [ 'a', 'b' ] }
        ]
      end

      it 'creates all property values with items' do
        expect { subject }.to change(PropertyValue, :count).by(4)
                          .and change(PropertyValueItem, :count).by(5)

        expect(user.errors).to be_empty
      end
    end

    context 'with existing property values' do
      let!(:existing_property_value) do
        create(:property_value, user: user, property: text_property).tap do |pv|
          create(:property_value_item, property_value: pv, value: 'Old text')
        end
      end

      let(:property_values) do
        [
          { name: text_property.name, value: 'New text' }
        ]
      end

      it 'updates existing property value items' do
        expect { subject }.not_to change(PropertyValue, :count)

        existing_property_value.reload
        expect(existing_property_value.property_value_items.first.value).to eq('New text')
      end
    end

    context 'with non-existent property' do
      let(:property_values) do
        [
          { name: 'non_existent', value: 'value' }
        ]
      end

      it 'adds error for non-existent property' do
        subject
        expect(user.errors[:property_values]).to include('Property non_existent not found')
      end
    end

    context 'with property related to another tenant' do
      let(:other_tenant) { create(:tenant) }
      let(:property)     { create(:property, :text, tenant: other_tenant, name: 'description') }

      let(:property_values) do
        [
          { name: property.name, value: 'Some description' }
        ]
      end

      it 'adds error for non-existent property' do
        subject
        expect(user.errors[:property_values]).to include("Property #{property.name} not found")
      end
    end
  end
end
