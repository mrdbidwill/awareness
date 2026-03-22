# Awareness - Mycology Knowledge Base

A Rails 8 application for mushroom identification, cataloging, and research. Awareness focuses on character-based data, taxonomy, images, and comparisons. It also integrates the AutoGlossary and MycoWriter engines for glossary terms and genus/species suggestions.

Thanks, AI, for all the hard work! But this is still a work in progress, and there is much left for humans to do.

## Live Site

Visit [https://awareness.com](https://awareness.com) to see the application in action.

## Sister Projects

- **MycoWriter**: Informational website at [https://mycowriter.com](https://mycowriter.com)
- **Auto-Glossary**: Informational website at [https://auto-glossary.com](https://auto-glossary.com)

## Table of Contents

- [Key Features](#key-features)
- [Documentation](#documentation)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [Running Tests](#running-tests)
- [Deployment](#deployment)
- [Technology Stack](#technology-stack)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## Key Features

- **Mushroom character tracking** with flexible morphological and microscopic data
- **Image management** with EXIF extraction (camera/lens data when available)
- **Taxonomic reference data** including MBList integration
- **Search and comparison** tools for character-based filtering and specimen comparisons
- **Grouping and organization** with clusters, groups, and genus/species associations
- **Articles** with admin-managed publishing workflows
- **Admin tools** for lookup data management, version history (PaperTrail), and database exports
- **Authentication** via Devise with optional two-factor authentication
- **Glossary and suggestion engines** via AutoGlossary and MycoWriter
- **iNaturalist utilities** for observation field exports (CSV/JSON)

## Documentation

Start with the documentation index: `docs/INDEX.md`.

Project memory and decision history live in:
- `docs/PROJECT_MEMORY.md`
- `docs/decision-log.md`

## Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby**: 3.4.3
- **Rails**: 8.0.2
- **MySQL**: 5.6.4+ (or MariaDB equivalent)
- **Bundler**
- **ImageMagick** or **libvips**
- **exiftool** (recommended for HEIC/RAW metadata)
- **Node.js**: Optional, only if you use `npm run build` or `npm run watch`

### System Dependencies

#### macOS
```bash
brew install mysql imagemagick libvips exiftool
```

#### Ubuntu/Debian
```bash
sudo apt-get install mysql-server libmysqlclient-dev imagemagick libvips-tools libimage-exiftool-perl
```

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/awarenesswill/awareness.git
   cd awareness
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```

4. **Prepare the database**
   ```bash
   bin/rails db:prepare
   ```

   The setup script `bin/setup` runs the same database preparation and then starts `bin/dev`.

## Configuration

Create a `.env` file in the root directory (see `.env.example`) and set:

```bash
# Rails credentials
RAILS_MASTER_KEY=your_master_key_here

# Two-factor authentication encryption key
OTP_SECRET_ENCRYPTION_KEY=your_otp_secret_key_here

# App host (used in links/emails)
APP_HOST=localhost:3000

# Database
MYSQL_USER=awareness_user
MYSQL_PASSWORD=devpassword
DB_HOST=127.0.0.1
# MYSQL_SOCKET=/path/to/mysql.sock   # Optional, macOS/Homebrew

# Active Storage (Cloudflare R2)
ACTIVE_STORAGE_SERVICE=r2
R2_BUCKET=your_bucket
R2_ENDPOINT=https://<accountid>.r2.cloudflarestorage.com
R2_REGION=auto
R2_ACCESS_KEY_ID=your_access_key
R2_SECRET_ACCESS_KEY=your_secret_key
R2_PUBLIC_BASE_URL=https://images.awareness.com

# AdSense (public pages only)
ADSENSE_ENABLED=false
ADSENSE_CLIENT_ID=ca-pub-...
```

Generate an OTP secret key if needed:
```bash
bundle exec rails secret
```

Database configuration lives in `config/database.yml` and is driven by environment variables.

AdSense is gated to public/anonymous sessions only; authenticated sessions never render the AdSense script.

## Database Setup

### Seed Data

Seed data creates permissions and reference data (countries/states):
```bash
bundle exec rails db:seed
```

### Reference Data Imports (Optional)

If you have an admin export from Awareness (lookup tables and/or MBList), you can import it with:
```bash
mysql -u your_mysql_username -p awareness_development < /path/to/awareness_lookup_tables_YYYYMMDD_HHMMSS.sql
```

## Running the Application

**Recommended (server + Tailwind watcher):**
```bash
bin/dev
```

**Server only:**
```bash
bundle exec rails server
```

Access the application at:
```
http://localhost:3000
```

Admin dashboard (after granting admin privileges):
```
http://localhost:3000/admin
```

## Running Tests

The application uses Minitest.

Before running commands in this repo, acknowledge project memory and use the guard wrapper:
```bash
script/ack_project_memory.sh
bin/with_project_memory script/preflight_test_env.sh
```

**Run all tests:**
```bash
bin/with_project_memory bin/rails test
```

**Run a specific file:**
```bash
bin/with_project_memory bin/rails test test/controllers/admin/database_exports_controller_test.rb
```

**Run with coverage:**
```bash
COVERAGE=true bin/with_project_memory bin/rails test
```

See `docs/TEST_SUITE_STATUS.md` and `docs/TESTING_QUICK_START.md` for guidance.

## Deployment

This application uses Capistrano for deployment. See `config/deploy.rb` and `docs/DEPLOYMENT.md`.

**Deploy to production:**
```bash
bundle exec cap production deploy
```

Additional references:
- `docs/DEPLOYMENT_TROUBLESHOOTING.md`
- `docs/SERVER_BACKUP_INSTRUCTIONS_10_13_2025.md`
- `docs/SOLID_QUEUE_SETUP.md`

## Technology Stack

- **Framework**: Ruby on Rails 8.0.2
- **Ruby Version**: 3.4.3
- **Database**: MySQL 5.6.4+ (or MariaDB)
- **Frontend**: Tailwind CSS (tailwindcss-rails + optional Node CLI), Hotwire, Stimulus, Importmap
- **Authentication**: Devise with TOTP-based 2FA
- **Authorization**: Pundit
- **Background Jobs**: Solid Queue (with Solid Cache/Cable)
- **Versioning**: PaperTrail
- **Testing**: Minitest with FactoryBot
- **Deployment**: Capistrano
- **Image Processing**: ImageMagick/libvips with EXIF extraction

## Contributing

We welcome contributions. Please open an issue or pull request with a clear description of the change and any needed migrations or data updates.

Translation contributions are welcome. See `docs/I18N.md` for guidelines.

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

For questions or issues:
- Open an issue on GitHub
- Visit [https://awareness.com](https://awareness.com)
- Contact: awarenesswill@gmail.com

## Acknowledgments

- **MBList Database**: Taxonomic data from MycoBank MBList database (https://www.mycobank.org), licensed under CC BY-NC-ND.
- Built with Ruby on Rails 8 and modern web technologies

---

**Note**: This is a research and educational tool. Always verify mushroom identifications with expert mycologists before consumption or critical decisions.
