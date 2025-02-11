class UpdateUserService
  def self.update_user(user, user_params)
    new(user, user_params).call
  end

  def initialize(user, user_params)
    @user = user
    @user_params = user_params
  end

  def call
    # here should be some logic to update the user
    update_user_property_values if user_params[:property_values].to_a.any?

    user
  end

  private

  attr_reader :user, :user_params

  def update_user_property_values
    UpdatePropertyValuesService.update_property_values(user, user_params[:property_values])
  end
end
