# frozen_string_literal: true

require_relative '../lib/darebee_scraped_seed_data'

# rubocop:disable Metrics/MethodLength
def featured_product_definitions
  [
    {
      title: '12-Week Beginner Strength Blueprint',
      price: 79.00,
      description: 'A structured entry-level barbell plan that teaches core lifts, ' \
                   'weekly progression, and recovery habits.',
      category_names: ['Strength Training']
    },
    {
      title: 'Upper/Lower Muscle Growth System',
      price: 69.00,
      description: 'A four-day hypertrophy split for lifters who want balanced ' \
                   'upper and lower body growth without guesswork.',
      category_names: ['Muscle Building']
    },
    {
      title: 'Busy Professional 45-Minute Training Plan',
      price: 59.00,
      description: 'A time-efficient training program for customers who need ' \
                   'effective sessions that fit around work and school.',
      category_names: ['Strength Training', 'Muscle Building']
    },
    {
      title: '8-Week Home Dumbbell Builder',
      price: 49.00,
      description: 'A progressive home-based program designed around dumbbells, benches, and limited space.',
      category_names: ['Muscle Building']
    },
    {
      title: 'Performance Meal Prep Template Pack',
      price: 29.00,
      description: 'Reusable nutrition templates with simple meal structures and ' \
                   'macro-friendly options for training weeks.',
      category_names: ['Nutrition Templates']
    },
    {
      title: 'High-Protein Fat Loss Nutrition Guide',
      price: 35.00,
      description: 'A digital guide focused on sustainable calorie control, ' \
                   'protein planning, and adherence strategies.',
      category_names: ['Nutrition Templates']
    },
    {
      title: 'Desk Worker Mobility Reset',
      price: 24.00,
      description: 'Short daily mobility routines that reduce stiffness from sitting and improve movement quality.',
      category_names: ['Mobility & Recovery']
    },
    {
      title: 'Post-Leg-Day Recovery Flow',
      price: 19.00,
      description: 'A guided mobility and recovery sequence to improve lower-body readiness between training sessions.',
      category_names: ['Mobility & Recovery']
    },
    {
      title: 'Powerbuilding Phase One',
      price: 89.00,
      description: 'A blended strength and hypertrophy program for intermediate ' \
                   'lifters chasing performance and physique goals.',
      category_names: ['Strength Training', 'Muscle Building']
    },
    {
      title: 'Coach-Style Weekly Training Template',
      price: 39.00,
      description: 'A reusable planning template that helps customers organize ' \
                   'sessions, track progress, and stay consistent.',
      category_names: ['Strength Training']
    }
  ]
end
# rubocop:enable Metrics/MethodLength

admin_email = ENV.fetch('EGYMA_ADMIN_EMAIL', 'admin@egyma.local')
admin_password = ENV.fetch('EGYMA_ADMIN_PASSWORD', 'Password123!')

AdminUser.find_or_create_by!(email: admin_email) do |admin|
  admin.password = admin_password
  admin.password_confirmation = admin_password
end

page_definitions = [
  {
    title: 'About Egyma',
    slug: 'about',
    published: true,
    body: <<~BODY
      Egyma is a digital fitness marketplace based in Winnipeg, Manitoba.

      For the past four years, the business has helped fitness professionals sell structured digital products such as workout programs, nutrition templates, mobility systems, and personalized coaching resources.

      The goal of the platform is simple: make it easier for customers to discover practical, well-organized fitness resources without relying on direct messages, scattered links, or third-party delivery platforms.
    BODY
  },
  {
    title: 'Contact Egyma',
    slug: 'contact',
    published: true,
    body: <<~BODY
      Egyma supports customers and coaches from Winnipeg, Manitoba.

      General support: support@egyma.local
      Creator partnerships: creators@egyma.local

      Contact the business for product questions, account support, or digital marketplace inquiries related to training, mobility, recovery, and nutrition resources.
    BODY
  }
]

page_definitions.each do |definition|
  page = Page.find_or_initialize_by(slug: definition[:slug])
  page.title = definition[:title]
  page.body = definition[:body]
  page.published = definition[:published]
  page.save!
end

province_definitions = [
  ['Alberta', 'AB', 0.05, 0.0, 0.0],
  ['British Columbia', 'BC', 0.05, 0.07, 0.0],
  ['Manitoba', 'MB', 0.05, 0.07, 0.0],
  ['New Brunswick', 'NB', 0.0, 0.0, 0.15],
  ['Newfoundland and Labrador', 'NL', 0.0, 0.0, 0.15],
  ['Northwest Territories', 'NT', 0.05, 0.0, 0.0],
  ['Nova Scotia', 'NS', 0.0, 0.0, 0.15],
  ['Nunavut', 'NU', 0.05, 0.0, 0.0],
  ['Ontario', 'ON', 0.0, 0.0, 0.13],
  ['Prince Edward Island', 'PE', 0.0, 0.0, 0.15],
  ['Quebec', 'QC', 0.05, 0.09975, 0.0],
  ['Saskatchewan', 'SK', 0.05, 0.06, 0.0],
  ['Yukon', 'YT', 0.05, 0.0, 0.0]
]

province_definitions.each do |name, code, gst_rate, pst_rate, hst_rate|
  province = Province.find_or_initialize_by(code: code)
  province.name = name
  province.gst_rate = gst_rate
  province.pst_rate = pst_rate
  province.hst_rate = hst_rate
  province.save!
end

category_definitions = [
  {
    name: 'Strength Training',
    description: 'Programs focused on progressive overload, strength development, and confident barbell work.'
  },
  {
    name: 'Muscle Building',
    description: 'Hypertrophy-focused training systems for gym users who want structure and measurable growth.'
  },
  {
    name: 'Nutrition Templates',
    description: 'Practical meal planning and macro templates built for busy professionals and fitness clients.'
  },
  {
    name: 'Mobility & Recovery',
    description: 'Mobility flows, warm-ups, and recovery plans that improve movement quality and consistency.'
  }
]

categories = category_definitions.each_with_object({}) do |definition, memo|
  category = Category.find_or_create_by!(name: definition[:name]) do |record|
    record.description = definition[:description]
    record.slug = definition[:name].parameterize
  end

  memo[definition[:name]] = category
end

scraped_product_definitions = DarebeeScrapedSeedData.seed_product_definitions
all_product_definitions = featured_product_definitions + scraped_product_definitions

all_product_definitions.each do |definition|
  product = Product.find_or_initialize_by(title: definition[:title])
  product.description = definition[:description]
  product.price = definition[:price]
  product.active = true
  product.categories = definition[:category_names].map { |name| categories.fetch(name) }
  product.save!
end
