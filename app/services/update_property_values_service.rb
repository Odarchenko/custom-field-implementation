class UpdatePropertyValuesService
  def self.update_property_values(user, property_values)
    new(user, property_values).call
  end

  def initialize(user, property_values)
    @user = user
    @property_values = property_values
    @property_ids = Set.new
  end

  def call
    validate_input

    if user.errors.empty?
      ActiveRecord::Base.transaction do
        remove_old_property_value_items

        property_values_data = build_property_values
        import_property_values(property_values_data)
        property_value_items_data = build_property_value_items
        create_new_property_value_items(property_value_items_data)
      end
    end

    user
  end

  private

  attr_reader :user, :property_values, :property_ids

  def validate_input
    property_values.each do |property_value|
      property = indexed_properties[property_value[:name]]

      next add_invalid_property_name_error(property_value[:name]) unless property

      property_ids << property.id
      validate_property_value(property, property_value[:value])
    end
  end

  def remove_old_property_value_items
    PropertyValueItem.joins(:property_value)
                     .where(property_value: { user: user, property_id: property_ids })
                     .delete_all
  end

  def import_property_values(import_data)
    PropertyValue.import(import_data, on_duplicate_key_ignore: true, raise_error: true)
  end

  def create_new_property_value_items(import_data)
    PropertyValueItem.import(import_data, on_duplicate_key_ignore: true, raise_error: true)
  end

  def build_property_value_items
    property_values.each_with_object([]) do |property_value, data|
      property = indexed_properties[property_value[:name]]
      property_value_record = indexed_property_values[property.id]

      Array.wrap(property_value[:value]).each do |value|
        data << property_value_record.property_value_items.new(value: value)
      end
    end
  end

  def build_property_values
    property_values.map do |property_value|
      property = indexed_properties[property_value[:name]]
      user.property_values.find_or_initialize_by(property: property)
    end
  end

  def validate_property_value(property, value)
    return if value_valid?(property, value)

    add_invalid_property_value_error(property.name, value)
  end

  def value_valid?(property, value)
    case property.field_type
    when Property::TEXT
      value.is_a?(String)
    when Property::NUMBER
      value.is_a?(Integer)
    when Property::SINGLE_SELECT
      property.options["values"].include?(value)
    when Property::MULTI_SELECT
      value.is_a?(Array) && value.all? { |v| property.options["values"].include?(v) }
    end
  end

  def add_invalid_property_name_error(property_name)
    user.errors.add(:property_values, "Property #{property_name} not found")
  end

  def add_invalid_property_value_error(property_name, value)
    user.errors.add(:property_values, "Property #{property_name} has invalid value")
  end

  def indexed_property_values
    @indexed_property_values ||= user.property_values.index_by(&:property_id)
  end

  def indexed_properties
    @indexed_properties ||= user.tenant.properties.index_by(&:name)
  end
end
