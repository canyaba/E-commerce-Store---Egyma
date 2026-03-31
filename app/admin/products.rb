# frozen_string_literal: true

ActiveAdmin.register Product do
  permit_params :title, :description, :price, :active, :image, category_ids: []

  includes :categories, image_attachment: :blob

  scope :all
  scope('Active') { |products| products.where(active: true) }
  scope('Inactive') { |products| products.where(active: false) }

  filter :title
  filter :description
  filter :price
  filter :active
  filter :categories
  filter :created_at

  index do
    selectable_column
    id_column
    column :title
    column('Categories') { |product| product.categories.order(:name).pluck(:name).join(', ') }
    column(:price) { |product| number_to_currency(product.price) }
    column :active
    column :image do |product|
      if product.image.attached?
        helpers.image_tag(helpers.url_for(product.image), alt: product.title, size: '80x80')
      else
        status_tag('missing', class: 'warning')
      end
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :title
      row :description
      row(:price) { |product| number_to_currency(product.price) }
      row :active
      row('Categories') { |product| product.categories.order(:name).pluck(:name).join(', ') }
      row :image do |product|
        if product.image.attached?
          helpers.image_tag(helpers.url_for(product.image), alt: product.title, size: '180x180')
        else
          'No image uploaded'
        end
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Product Details' do
      f.input :title, input_html: { autocomplete: 'off' }
      f.input :description, as: :text, input_html: { rows: 6 }
      f.input :price
      f.input :active
      f.input :categories, as: :check_boxes, collection: Category.order(:name)
      f.input :image,
              as: :file,
              hint: if f.object.image.attached?
                      helpers.image_tag(helpers.url_for(f.object.image), alt: f.object.title, size: '120x120')
                    else
                      content_tag(:span, 'No image uploaded')
                    end
    end

    f.actions
  end

  controller do
    def create
      super do |success, failure|
        success.html { redirect_to resource_path(resource), notice: 'Product saved successfully.' }
        failure.html { render :new, status: :unprocessable_content }
      end
    end

    def update
      super do |success, failure|
        success.html { redirect_to resource_path(resource), notice: 'Product updated successfully.' }
        failure.html { render :edit, status: :unprocessable_content }
      end
    end

    def destroy
      super do |success, _failure|
        success.html { redirect_to admin_products_path, notice: 'Product removed successfully.' }
      end
    end
  end
end
