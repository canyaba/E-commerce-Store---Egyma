# frozen_string_literal: true

class BackfillDefaultPages < ActiveRecord::Migration[7.1]
  class MigrationPage < ApplicationRecord
    self.table_name = 'pages'
  end

  ABOUT_BODY = <<~BODY
    Egyma is a digital fitness marketplace based in Winnipeg, Manitoba.

    For the past four years, the business has helped fitness professionals sell structured digital products such as workout programs, nutrition templates, mobility systems, and personalized coaching resources.

    The goal of the platform is simple: make it easier for customers to discover practical, well-organized fitness resources without relying on direct messages, scattered links, or third-party delivery platforms.
  BODY

  CONTACT_BODY = <<~BODY
    Egyma supports customers and coaches from Winnipeg, Manitoba.

    General support: support@egyma.local
    Creator partnerships: creators@egyma.local

    Contact the business for product questions, account support, or digital marketplace inquiries related to training, mobility, recovery, and nutrition resources.
  BODY

  def up
    default_pages.each do |attributes|
      page = MigrationPage.find_or_initialize_by(slug: attributes[:slug])
      page.title = attributes[:title]
      page.body = attributes[:body]
      page.published = true if page.new_record?
      page.save!
    end
  end

  def down
    MigrationPage.where(slug: default_pages.pluck(:slug)).delete_all
  end

  private

  def default_pages
    [
      { title: 'About Egyma', slug: 'about', body: ABOUT_BODY },
      { title: 'Contact Egyma', slug: 'contact', body: CONTACT_BODY }
    ]
  end
end
