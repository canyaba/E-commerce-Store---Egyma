# frozen_string_literal: true

class AccountProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_profile, only: %i[show edit update]

  def show; end

  def edit
    @provinces = Province.alphabetical
  end

  def update
    @provinces = Province.alphabetical
    @user.assign_attributes(account_params)

    if @user.save(context: :profile)
      redirect_to account_path, notice: 'Account details updated successfully.'
    else
      flash.now[:alert] = 'Please fix the account details below.'
      render :edit, status: :unprocessable_content
    end
  end

  private

  def load_profile
    @user = current_user
  end

  def account_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :address_line_1,
      :address_line_2,
      :city,
      :postal_code,
      :province_id
    )
  end
end
