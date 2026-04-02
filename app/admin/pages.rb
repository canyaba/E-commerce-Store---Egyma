# frozen_string_literal: true

ActiveAdmin.register Page do
  permit_params :title, :slug, :body, :published

  actions :all, except: :destroy

  filter :title
  filter :slug
  filter :published
  filter :updated_at

  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :published
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :title
      row :slug
      row :published
      row(:body) { |page| simple_format(page.body) }
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Page Details' do
      f.input :title
      f.input :slug, hint: 'Leave blank to generate a slug from the page title.'
      f.input :published
      f.input :body, as: :text, input_html: { rows: 14 }
    end

    f.actions
  end

  controller do
    def create
      super do |success, failure|
        success.html { redirect_to resource_path(resource), notice: 'Page saved successfully.' }
        failure.html { render :new, status: :unprocessable_content }
      end
    end

    def update
      super do |success, failure|
        success.html { redirect_to resource_path(resource), notice: 'Page updated successfully.' }
        failure.html { render :edit, status: :unprocessable_content }
      end
    end
  end
end
