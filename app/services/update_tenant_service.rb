class UpdateTenantService
  def self.update_tenant(tenant, tenant_params)
    new(tenant, tenant_params).call
  end

  def initialize(tenant, tenant_params)
    @tenant = tenant
    @tenant_params = tenant_params
  end

  def call
    # here can be some logic to update the tenant fields in future
    properties = build_properties

    import_properties(properties) if properties.any? && tenant.errors.empty?

    tenant
  end

  private

  attr_reader :tenant, :tenant_params

  def import_properties(properties)
    Property.import(properties,
      on_duplicate_key_update: {
        conflict_target: [ :name, :tenant_id ],
        columns: [ :field_type, :options ]
      },
      raise_error: true,
      all_or_none: true
    )
  end

  def build_properties
    tenant_params[:property_params].map do |property_params|
      property = tenant.properties.find_or_initialize_by(name: property_params[:name])

      property.assign_attributes(
        field_type: property_params[:field_type],
        options: property_params[:options].to_h
      )

      tenant.errors.add(:properties, property.errors.full_messages.join(", ")) unless property.valid?

      property
    end
  end
end
