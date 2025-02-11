module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

      private

      def record_invalid(exception)
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      def record_not_found(exception)
        render json: { error: "#{exception.model} not found" }, status: :not_found
      end
    end
  end
end
