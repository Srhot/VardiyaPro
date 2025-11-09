# VardiyaPro - Proje Anayasası (Constitution)

Bu doküman, VardiyaPro projesinin **değişmez kurallarını** ve **temel prensiplerini** tanımlar.
Spec-Driven Development ve POML (Prompt Orchestration Markup Language) prensipleriyle oluşturulmuştur.

---

<constitution>

## <article id="project-architecture">
### **Proje Mimarisi**

<rule priority="critical">
**Mimari:** Full-Stack Rails 8 Application (API + Views)
- Backend: RESTful API endpoints
- Frontend: Rails Views (Hotwire/Turbo)
- Test Interface: Postman + Newman (automated API tests)
</rule>

<rule priority="high">
**Service Objects Pattern:** Scale Platform mimarisini takip et
- Business logic controller'da değil, Service Objects'te olmalı
- Örnek: `Shifts::CreateService`, `Users::AuthenticationService`
- Her servis tek sorumluluk prensibiyle çalışır (Single Responsibility)
</rule>

<rule priority="medium">
**Code Organization:**
- Models: Data + validations
- Controllers: Request handling (thin controllers)
- Services: Business logic
- Jobs: Background tasks (Solid Queue)
</rule>

</article>

## <article id="security">
### **Güvenlik Gereksinimleri**

<rule priority="critical">
**Authentication:** JWT (JSON Web Tokens)
- Access token expiry: 1 hour
- Refresh token expiry: 7 days
- Token storage: HTTP-only cookies (XSS protection)
</rule>

<rule priority="critical">
**ASLA Hardcoded Secrets:**
```ruby
# ❌ YANLIŞ
password: "2113-Oney"
jwt_secret: "mysecret123"

# ✅ DOĞRU
password: <%= ENV.fetch("DATABASE_PASSWORD") { "development_password" } %>
jwt_secret: ENV.fetch('JWT_SECRET') { Rails.application.secret_key_base }
```
Scale Platform hatasını tekrarlama!
</rule>

<rule priority="high">
**Password Encryption:**
- Bcrypt kullan (Rails default)
- Minimum password length: 8 karakter
- PII data (telefon, email) şimdilik plaintext (performans için), gerekirse sonra encrypt
</rule>

<rule priority="medium">
**HTTPS:**
- Development: HTTP (kolay geliştirme)
- Production: HTTPS zorunlu (`config.force_ssl = true` - tek satır değişiklik)
</rule>

<rule priority="high">
**SQL Injection Önleme:**
- ASLA raw SQL (`User.where("name = '#{params[:name]}'")`)
- Her zaman parameterized queries (`User.where(name: params[:name])`)
</rule>

</article>

## <article id="testing">
### **Test Stratejisi**

<rule priority="high">
**Test Framework:** RSpec (Scale Platform ile tutarlı)
- Unit tests: Models, Services
- Integration tests: Controllers, API endpoints
- E2E tests: Playwright (BDD - en son aşama)
</rule>

<rule priority="medium">
**Test Yaklaşımı:**
- İlk önce feature'ı geliştir, sonra test yaz (pragmatic approach)
- Kritik business logic'ler MUTLAKA test edilmeli
- Minimum coverage: Kritik endpoint'ler için %80
</rule>

<rule priority="high">
**Postman + Newman:**
- Her API endpoint için Postman collection oluştur
- Newman ile CI/CD entegrasyonu
- Pre-request scripts ile authentication token yönetimi
</rule>

</article>

## <article id="performance">
### **Performance Hedefleri**

<rule priority="high">
**API Response Time:**
- Target: < 500ms (profesyonel standart)
- Warning threshold: > 1s (log warning)
- Critical threshold: > 3s (alert)
</rule>

<rule priority="high">
**Pagination:**
- Tüm list endpoint'leri paginate edilmeli
- Default: 50 kayıt/sayfa
- Max: 100 kayıt/sayfa
- Gem: `kaminari` veya `pagy`
</rule>

<rule priority="medium">
**Caching:**
- Solid Cache (Rails 8 - PostgreSQL-based)
- Cache edilecekler: List endpoint'leri, sık okunan data
- Cache süresi: 5 dakika (shift listesi için)
- Cache invalidation: Create/Update/Delete işlemlerinde
</rule>

<rule priority="medium">
**Database Optimization:**
- Connection pool: 5 (development), 20 (production)
- Slow query logging: > 100ms
- N+1 query'lerini önle: `includes`, `joins` kullan
</rule>

</article>

## <article id="database">
### **Database Standartları**

<rule priority="critical">
**PostgreSQL 15:**
- Version: 15.x
- Encoding: UTF-8
- Timezone: UTC (her zaman)
</rule>

<rule priority="critical">
**Migration Kuralları:**
- Her migration **reversible** olmalı (`up`/`down` veya `change`)
- ASLA production'da `rails db:schema:load` (Scale Platform hatası)
- Sadece `rails db:migrate` kullan
</rule>

<rule priority="high">
**Solid Stack (Rails 8):**
- Solid Cache: PostgreSQL-based caching
- Solid Queue: Background jobs
- Solid Cable: WebSockets (real-time notifications için)
- Hepsinin migration'larını kur: `rails solid_*:install:migrations`
</rule>

</article>

## <article id="development">
### **Development Workflow**

<rule priority="medium">
**Code Style:**
- RuboCop KULLANMA (development hızını düşürür)
- Manuel code review yeterli
- Tutarlı stil: Rails conventions takip et
</rule>

<rule priority="high">
**Git Workflow:**
- Branch naming: `claude/vardiyapro-*`
- Commit messages: Açıklayıcı, İngilizce
- Push: `git push -u origin <branch>` (her zaman -u flag)
</rule>

<rule priority="medium">
**Environment:**
- Docker KULLANMA (GitHub Code + VSCode ile development)
- PostgreSQL: Local installation
- Ruby: 3.3.9
- Rails: 8.1.0
</rule>

</article>

## <article id="non-negotiable">
### **Değişmez Kurallar (Non-Negotiable)**

<rule priority="CRITICAL">
**Scale Platform Hatalarını Tekrarlama:**

1. ❌ **Gemfile.lock conflicts:**
   - ✅ Ruby version explicit: `ruby "3.3.9"`
   - ✅ Gem versions locked: `gem "pg", "~> 1.6.2"`

2. ❌ **PostgreSQL native extension hatası:**
   - ✅ Development dependencies: `libpq-dev` kurulu olmalı
   - ✅ `bundle config build.pg --with-pg-config=/usr/bin/pg_config`

3. ❌ **Hardcoded passwords:**
   - ✅ `database.yml`: `ENV.fetch("DATABASE_PASSWORD")`
   - ✅ `.env` file + `.gitignore`

4. ❌ **Solid gems migration unutulması:**
   - ✅ `rails solid_cache:install:migrations`
   - ✅ `rails solid_queue:install:migrations`
   - ✅ `rails solid_cable:install:migrations`

5. ❌ **JWT secret missing:**
   - ✅ `config/initializers/jwt.rb` oluştur
   - ✅ `ENV['JWT_SECRET']` fallback ile

6. ❌ **CORS production'da kapalı:**
   - ✅ `rack-cors` gem
   - ✅ API endpoint'leri için CORS enable
</rule>

<rule priority="CRITICAL">
**Asla Production'a Push Etme Kuralları:**
- ❌ Test edilmemiş critical feature
- ❌ Hardcoded secret/password içeren kod
- ❌ Migration'ı geri alınamaz (irreversible)
- ❌ SQL injection riski olan query
</rule>

</article>

</constitution>

---

## 📌 Özet: Proje DNA'sı

| Konu | Karar |
|------|-------|
| **Mimari** | Full-Stack Rails 8 + Service Objects |
| **Auth** | JWT (1h access, 7d refresh) |
| **Database** | PostgreSQL 15 + Solid Stack |
| **Test** | RSpec + Postman/Newman + Playwright (BDD) |
| **Performance** | <500ms, pagination (50/page), Solid Cache |
| **Code Style** | Rails conventions (RuboCop yok) |
| **Deployment** | GitHub Code + VSCode (Docker yok) |
| **Non-Negotiable** | Scale Platform hatalarını önle! |

---

**Oluşturulma:** 2025-11-09
**Durum:** Active
**Son Güncelleme:** Initial version
