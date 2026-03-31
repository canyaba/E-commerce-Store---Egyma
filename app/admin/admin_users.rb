# frozen_string_literal: true

ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :remember_created_at
    column :created_at
    actions
  end

  filter :email
  filter :remember_created_at
  filter :created_at

  show do
    attributes_table do
      row :email
      row :remember_created_at
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
