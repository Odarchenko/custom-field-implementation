module Api
  module V1
    class TenantsController < BaseController
      def update
        tenant = Tenant.find(params[:id])

        tenant = UpdateTenantService.update_tenant(tenant, tenant_update_params)

        if tenant.errors.empty?
          render json: { tenant_id: tenant.id }, status: :ok
        else
          render json: { errors: tenant.errors }, status: :unprocessable_entity
        end
      end

      private

      def tenant_update_params
        params.require(:properties)
              .permit(:name, :description, property_params: [ :name, :field_type, options: {} ])
              .to_unsafe_h
      end
    end
  end
end
