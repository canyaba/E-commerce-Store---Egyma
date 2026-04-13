# Egyma

Egyma is a Ruby on Rails ecommerce application for a digital fitness marketplace based in Winnipeg, Manitoba. Fitness professionals can list digital products such as workout programs, nutrition templates, and recovery guides, while customers can browse the catalog, create accounts, add products to a session-backed cart, complete checkout with province-based taxes, and review their past orders.

## Project Scope

This application was built for a college ecommerce project and follows a foundation-first Rails approach:

- PostgreSQL-backed domain model
- ActiveAdmin for admin management
- Devise for admin and customer authentication
- Active Storage for product image uploads
- Session-backed shopping cart
- Province-based tax calculation
- Order snapshotting for historical price and tax preservation
- Stripe sandbox payment flow
- Breadcrumb navigation and multi-size image variants

## Tech Stack

- Ruby `4.0.0`
- Rails `7.1`
- PostgreSQL
- ERB views
- SCSS
- Active Storage
- Devise
- ActiveAdmin
- Stripe
- Minitest
- Rubocop

## Implemented Features

### Admin

- Admin login
- Product CRUD
- Category CRUD
- Province tax-rate management
- Order management with shipped status updates
- Product image upload through Active Storage
- Editable About and Contact pages

### Storefront

- Front-page product browsing
- Category browsing
- Product detail pages
- Keyword search with optional category filtering
- Pagination
- Reusable partial-based UI
- Responsive SCSS styling with Bootstrap utilities
- Breadcrumb navigation for key storefront/account flows
- Public About and Contact pages

### Customer Account and Ecommerce Flow

- Customer sign up, login, and logout
- Session-backed cart
- Separate add, quantity update, and remove cart actions
- Checkout with saved address details
- Province-based GST/PST/HST calculation
- Order and order item snapshots
- Past order history
- Stripe sandbox payment confirmation
- Saved account billing details with province profile management
- End-to-end browser coverage for key admin and customer flows

## Domain Model

Core models currently used by the app:

- `AdminUser`
- `User`
- `Province`
- `Product`
- `Category`
- `ProductCategory`
- `Page`
- `Order`
- `OrderItem`

Orders preserve historical data at checkout time, including:

- purchased product titles
- purchased unit prices
- selected province
- GST/PST/HST rates
- GST/PST/HST amounts
- subtotal
- grand total

## Prerequisites

Before running the project locally, make sure you have:

- Ruby `4.0.0`
- Bundler
- PostgreSQL running locally or in Docker
- ImageMagick or libvips support for Active Storage variants
- Docker Desktop if you want to run the full app stack through `compose.yml`

## Environment Variables

The app uses environment variables for database connection and Stripe sandbox payment.

### PostgreSQL

These defaults are already wired into `config/database.yml`:

```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=egyma_development
POSTGRES_TEST_DB=egyma_test
POSTGRES_PRODUCTION_DB=egyma_production
POSTGRES_PRODUCTION_USER=postgres
POSTGRES_PRODUCTION_PASSWORD=postgres
```

### Stripe Sandbox

Stripe payment is only enabled when this variable is present:

```env
STRIPE_SECRET_KEY=sk_test_your_key_here
```

If `STRIPE_SECRET_KEY` is not set, the order page will still work, but the Stripe payment action will remain unavailable.

### Optional S3-Compatible Active Storage

Cloud-backed file storage can be enabled in production by setting:

```env
ACTIVE_STORAGE_SERVICE=amazon
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=ca-central-1
AWS_BUCKET=your-bucket-name
```

This is configured in `config/storage.yml`, but you still need a real bucket and credentials to use it.

### Seeded Admin Credentials

These can be overridden before running `db:seed`:

```env
EGYMA_ADMIN_EMAIL=admin@egyma.local
EGYMA_ADMIN_PASSWORD=Password123!
```

## Local Setup

1. Install dependencies:

```bash
bundle install
```

2. Create the databases:

```bash
bundle exec rails db:create
```

3. Run migrations:

```bash
bundle exec rails db:migrate
```

4. Seed the application:

```bash
bundle exec rails db:seed
```

5. Start the Rails server:

```bash
bundle exec rails server
```

6. Open the app:

```text
http://127.0.0.1:3000
```

## Optional PostgreSQL Docker Example

If you do not want to run PostgreSQL directly on your machine, you can start a local container:

```bash
docker run --name egyma-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=egyma_development -p 5432:5432 -d postgres:16
```

You should also create the test database, either manually or by adjusting the environment and running `rails db:create`.

## Local Docker Compose

The repository also includes `compose.yml` so the app and PostgreSQL can run together in containers:

```bash
docker compose up --build
```

This starts:

- `db` on PostgreSQL 16
- `web` on `http://127.0.0.1:3000`

The containerized app uses the production Docker image with local disk storage and an internal PostgreSQL service, which is enough for local rubric evidence around containerization.

## Useful Routes

- `/` - storefront home page
- `/search` - keyword search
- `/cart` - shopping cart
- `/checkout` - checkout page
- `/orders` - customer order history
- `/about` - public About page
- `/contact` - public Contact page
- `/admin` - ActiveAdmin backend

## Test and Quality Commands

Run the application test suite:

```bash
bundle exec rails test
```

Run linting:

```bash
bundle exec rubocop app config db test
```

Check Zeitwerk loading:

```bash
bundle exec rails zeitwerk:check
```

Run browser-level system tests:

```bash
bundle exec rails test:system
```

## Source Control Workflow

This project is intended to be developed with short-lived feature branches and descriptive commits. For grading and portfolio evidence:

- keep `main` stable
- open pull requests for meaningful features or fixes
- prefer merge commits over squash merges when preserving branch history matters
- run tests and Rubocop before merging

## Seed Data

The seed file creates:

- 1 admin user
- all Canadian provinces and territories with tax rates
- 4 catalog categories
- 100+ digital fitness products seeded from a committed DAREBEE metadata snapshot plus local featured products
- default published About and Contact pages

### Scraped Seed Snapshot

Requirement `1.7` is implemented with a committed DAREBEE snapshot rather than live scraping during `db:seed`.

- Source catalog: `https://www.darebee.com/programs.html` and paginated workout pages under `https://www.darebee.com/workouts.html`
- Captured fields: source title, source URL, source type, category mapping, and generated Egyma-friendly pricing and descriptions
- Normal seeding stays offline and deterministic because it reads from `db/data/darebee_products.json`

To refresh the committed snapshot intentionally:

```bash
bundle exec rake data:scrape_darebee[120]
```

The scraper uses public DAREBEE metadata only. It does not copy long-form page content into the application.

## Continuous Integration

GitHub Actions CI is configured in `.github/workflows/ci.yml` to run:

- `bundle exec rails test`
- `bundle exec rubocop app config db test`

This gives the project a repeatable quality gate on pushes and pull requests.

## Payment Notes

Stripe uses test mode only. A typical manual payment verification flow is:

1. Create a customer account
2. Add products to the cart
3. Complete checkout
4. Open the generated order
5. Start Stripe sandbox payment
6. Return through the success callback
7. Confirm the order is marked `paid`
8. Mark the order `shipped` from ActiveAdmin

## Accessibility and Code Quality

This project intentionally follows conventional Rails patterns:

- thin controllers
- strong parameters
- model validations
- semantic HTML
- visible form labels
- flash messages and validation feedback
- reusable partials for repeated UI
- Rubocop-friendly code

## Current Notes

- The app uses server-rendered Rails views only. No SPA frontend is involved.
- Product files and download fulfillment are not implemented yet; the current marketplace flow focuses on catalog, checkout, and payment foundations.
- Git and GitHub grading evidence depends on real commit history and branch usage, which must be maintained outside the README itself.
