# VardiyaPro

Ruby on Rails 8 API + PostgreSQL ile geliştirilmiş Vardiya/Shift Yönetim Sistemi

## 🏗️ Geliştirme Metodolojisi
- **Spec-Driven Development** (GitHub Spec Kit)
- **POML** (Microsoft Prompt Orchestration Markup Language)
- **Rails 8 Solid Stack** (PostgreSQL-based cache, queue, cable)

## 🚀 Teknoloji Stack
- Ruby 3.3.6
- Rails 8.1.0
- PostgreSQL 15
- JWT Authentication
- Solid Cache, Solid Queue, Solid Cable (Rails 8)

## 📚 Referans Proje
Bu proje, [Scale Platform](https://github.com/Srhot/scale-platform) mimarisinden ilham alınarak geliştirilmiştir.

## 🏛️ Proje Anayasası
Detaylı proje kuralları ve prensipleri için [`constitution.md`](./constitution.md) dosyasına bakınız.

## 📦 Kurulum

### Gereksinimler
```bash
Ruby 3.3.6+
PostgreSQL 15
Bundler 2.x
```

### Adımlar
```bash
# Dependencies
bundle install

# Database setup
rails db:create
rails db:migrate

# Solid Stack migrations
rails solid_cache:install:migrations
rails solid_queue:install:migrations
rails solid_cable:install:migrations
rails db:migrate

# Start server
rails server
```

## 🔐 Environment Variables

Create `.env` file:
```bash
DATABASE_PASSWORD=your_password
JWT_SECRET=your_jwt_secret
```

## 🧪 Testing

### RSpec Tests
```bash
bundle exec rspec
```

### Postman/Newman Tests
```bash
# Run API tests
newman run test/postman/VardiyaPro_API.postman_collection.json \
  -e test/postman/VardiyaPro.postman_environment.json
```

## 📖 API Documentation

Base URL: `http://localhost:3000/api/v1`

### Authentication
- `POST /auth/login` - Get JWT token
- `POST /auth/refresh` - Refresh token

### Shifts
- `GET /shifts` - List all shifts (paginated)
- `POST /shifts` - Create new shift
- `PUT /shifts/:id` - Update shift
- `DELETE /shifts/:id` - Delete shift

*(Full API documentation coming soon)*

---

**Proje Claude AI ile Spec-Driven Development metodolojisi kullanılarak geliştirilmektedir.**
