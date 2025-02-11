module Api
  module V1
    class UsersController < BaseController
      def update
        user = User.find(params[:id])
        user = UpdateUserService.update_user(user, user_params)

        if user.errors.empty?
          render json: { user_id: user.id }, status: :ok
        else
          render json: { errors: user.errors }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:users).permit(property_values: [ :name, :value ]).to_unsafe_h
      end
    end
  end
end
