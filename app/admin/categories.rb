# frozen_string_literal: true

ActiveAdmin.register Category do
  permit_params :name, :slug, :description

  includes :products

  filter :name
  filter :slug
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :slug
    column('Products') { |category| category.products.count }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :slug
      row :description
      row('Products') { |category| category.products.order(:title).pluck(:title).join(', ') }
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Category Details' do
      f.input :name
      f.input :slug, hint: 'Leave blank to generate automatically from the category name.'
      f.input :description, as: :text, input_html: { rows: 4 }
    end

    f.actions
  end

  controller do
    def create
      super do |success, failure|
        success.html { redirect_to resource_path(resource), notice: 'Category saved successfully.' }
        failure.html { render :new, status: :unprocessable_content }
      end
    end

    def update
      super do |success, failure|
        success.html { redirect_to resource_path(resource), notice: 'Category updated successfully.' }
        failure.html { render :edit, status: :unprocessable_content }
      end
    end

    def destroy
      super do |success, _failure|
        success.html { redirect_to admin_categories_path, notice: 'Category removed successfully.' }
      end
    end
  end
end
