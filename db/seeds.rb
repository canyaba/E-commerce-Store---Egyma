# frozen_string_literal: true

admin_email = ENV.fetch('EGYMA_ADMIN_EMAIL', 'admin@egyma.local')
admin_password = ENV.fetch('EGYMA_ADMIN_PASSWORD', 'Password123!')

AdminUser.find_or_create_by!(email: admin_email) do |admin|
  admin.password = admin_password
  admin.password_confirmation = admin_password
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

product_definitions = [
  [
    '12-Week Beginner Strength Blueprint',
    79.00,
    'A structured entry-level barbell plan that teaches core lifts, weekly progression, and recovery habits.',
    ['Strength Training']
  ],
  [
    'Upper/Lower Muscle Growth System',
    69.00,
    'A four-day hypertrophy split for lifters who want balanced upper and lower body growth without guesswork.',
    ['Muscle Building']
  ],
  [
    'Busy Professional 45-Minute Training Plan',
    59.00,
    'A time-efficient training program for customers who need effective sessions that fit around work and school.',
    ['Strength Training', 'Muscle Building']
  ],
  [
    '8-Week Home Dumbbell Builder',
    49.00,
    'A progressive home-based program designed around dumbbells, benches, and limited space.',
    ['Muscle Building']
  ],
  [
    'Performance Meal Prep Template Pack',
    29.00,
    'Reusable nutrition templates with simple meal structures and macro-friendly options for training weeks.',
    ['Nutrition Templates']
  ],
  [
    'High-Protein Fat Loss Nutrition Guide',
    35.00,
    'A digital guide focused on sustainable calorie control, protein planning, and adherence strategies.',
    ['Nutrition Templates']
  ],
  [
    'Desk Worker Mobility Reset',
    24.00,
    'Short daily mobility routines that reduce stiffness from sitting and improve movement quality.',
    ['Mobility & Recovery']
  ],
  [
    'Post-Leg-Day Recovery Flow',
    19.00,
    'A guided mobility and recovery sequence to improve lower-body readiness between training sessions.',
    ['Mobility & Recovery']
  ],
  [
    'Powerbuilding Phase One',
    89.00,
    'A blended strength and hypertrophy program for intermediate lifters chasing performance and physique goals.',
    ['Strength Training', 'Muscle Building']
  ],
  [
    'Coach-Style Weekly Training Template',
    39.00,
    'A reusable planning template that helps customers organize sessions, track progress, and stay consistent.',
    ['Strength Training']
  ]
]

product_definitions.each do |title, price, description, category_names|
  product = Product.find_or_initialize_by(title: title)
  product.description = description
  product.price = price
  product.active = true
  product.categories = category_names.map { |name| categories.fetch(name) }
  product.save!
end
