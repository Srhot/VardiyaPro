# VardiyaPro API - Semantic Versioning (Semver) Documentation

## 📋 Hocanın İsteği

> API Sürümleme (Versioning) ve Semantic Kullanımı
> - Kullandığınız veya seçtiğiniz API'nin sürümleme yapısını inceleyin
> - Örnek: /api/v1/users, /api/v2/products
> - Semantic Versioning (semver) kavramını açıklayın (örnek: 1.0.0 → MAJOR.MINOR.PATCH)
> - Örnek bir senaryo yazarak yeni bir sürüm çıktığında test sürecinizin nasıl değişeceğini açıklayın

---

## 🎯 VardiyaPro API Versioning Stratejisi

### Mevcut API Sürümleri

VardiyaPro projesi **URL-based versioning** kullanmaktadır:

```
http://localhost:3000/api/v1/*   (Mevcut - Stable)
http://localhost:3000/api/v2/*   (Yeni - Beta)
```

### Route Yapısı

**config/routes.rb:**

```ruby
Rails.application.routes.draw do
  namespace :api do
    # Version 1 - Stable (Current Production)
    namespace :v1 do
      # Authentication
      post 'auth/login', to: 'auth#login'
      post 'auth/refresh', to: 'auth#refresh'

      # Resources
      resources :departments, only: %i[index show create update]
      resources :shifts
      resources :assignments
      resources :time_entries
      resources :holidays
      resources :users
      resources :notifications

      # Reports
      get 'reports/employee/:id', to: 'reports#employee'
      get 'reports/department/:id', to: 'reports#department'
      get 'reports/overtime', to: 'reports#overtime'
    end

    # Version 2 - Enhanced Features (Beta)
    namespace :v2 do
      # Authentication (same as v1)
      post 'auth/login', to: 'auth#login'

      # Users (enhanced with additional fields)
      resources :users, only: %i[index show create update] do
        member do
          get :profile        # NEW: Enhanced profile
          get :statistics     # NEW: User statistics
        end
      end

      # Departments (enhanced with team metrics)
      resources :departments do
        member do
          get :team_metrics  # NEW: Team performance metrics
        end
      end

      # Shifts (enhanced with capacity planning)
      resources :shifts do
        collection do
          get :capacity_report  # NEW: Capacity planning
        end
      end
    end
  end
end
```

---

## 📖 Semantic Versioning (Semver) Nedir?

Semantic Versioning, yazılım sürümlemesi için kullanılan bir standarttır. Format:

```
MAJOR.MINOR.PATCH
```

### Versiyon Numaraları

| Bileşen | Ne Zaman Artırılır | Örnek | Açıklama |
|---------|-------------------|-------|----------|
| **MAJOR** | Breaking changes (geriye uyumsuz değişiklikler) | 1.0.0 → **2.0.0** | API'nin kullanım şekli değişti, mevcut kodlar çalışmayabilir |
| **MINOR** | Yeni özellikler (geriye uyumlu) | 1.0.0 → 1.**1**.0 | Yeni endpoint/field eklendi ama eskiler çalışmaya devam ediyor |
| **PATCH** | Bug fix (geriye uyumlu) | 1.0.0 → 1.0.**1** | Hata düzeltmesi, performans iyileştirmesi |

### Örnekler

```
v1.0.0  → İlk stable release
v1.0.1  → Bug fix (response time optimization)
v1.1.0  → Yeni feature: Time tracking eklendi
v1.2.0  → Yeni feature: Holiday management eklendi
v2.0.0  → Breaking change: Authentication değişti (JWT → OAuth2)
```

---

## 🔄 VardiyaPro API Version History

### v1.0.0 (Current - Stable)
**Release Date:** 2025-01-08

**Features:**
- ✅ JWT Authentication
- ✅ Department Management
- ✅ Shift Scheduling
- ✅ Assignment Tracking
- ✅ User Management (4 roles)
- ✅ Notifications
- ✅ Reports (employee, department, overtime)
- ✅ Audit Logs

**Endpoints:** 30+ endpoints across 8 resources

---

### v1.1.0 (Phase 3 Update)
**Release Date:** 2025-01-11

**Added (MINOR - Backward Compatible):**
- ✅ **Time Entry Feature**
  - POST /api/v1/assignments/:id/clock_in
  - PATCH /api/v1/time_entries/:id/clock_out
  - GET /api/v1/time_entries

- ✅ **Holiday Feature**
  - GET /api/v1/holidays
  - POST /api/v1/holidays
  - GET /api/v1/holidays/check

**Migration Path:** None required. Existing endpoints unchanged.

**Breaking Changes:** None ✅

---

### v2.0.0 (Planned - Beta)
**Release Date:** TBD

**Enhanced Features (MAJOR - Some Breaking Changes):**

#### 1. **Enhanced User Endpoints**

**Before (v1):**
```json
GET /api/v1/users/:id
Response: {
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "employee"
  }
}
```

**After (v2):**
```json
GET /api/v2/users/:id/profile
Response: {
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "employee",
    "profile": {
      "bio": "...",
      "avatar_url": "...",
      "timezone": "Europe/Istanbul",
      "language": "tr"
    },
    "statistics": {
      "total_shifts": 120,
      "total_hours": 960,
      "attendance_rate": 98.5
    }
  }
}
```

**Breaking Change:** Response structure değişti. `profile` ve `statistics` objesi eklendi.

#### 2. **Enhanced Department Endpoints**

**New Endpoint:**
```
GET /api/v2/departments/:id/team_metrics
```

**Response:**
```json
{
  "data": {
    "department_id": 1,
    "metrics": {
      "total_employees": 25,
      "active_shifts": 12,
      "coverage_rate": 95.2,
      "overtime_hours": 45,
      "avg_satisfaction": 4.3
    }
  }
}
```

#### 3. **Enhanced Shift Endpoints**

**New Endpoint:**
```
GET /api/v2/shifts/capacity_report
```

**Response:**
```json
{
  "data": {
    "date_range": {
      "start": "2025-01-01",
      "end": "2025-01-31"
    },
    "capacity": {
      "required_staff": 500,
      "assigned_staff": 475,
      "fill_rate": 95.0,
      "understaffed_shifts": 12
    }
  }
}
```

---

## 🧪 Test Süreci: Yeni Versiyon Senaryosu

### Senaryo: "users" Endpoint'ine Yeni Alan Eklenmesi

**Durum:** API'nin `GET /api/v1/users/:id` endpoint'ine `phone_verified` boolean field'ı eklenmesi gerekiyor.

### Adım 1: Değişiklik Analizi

**Soru:** Bu değişiklik hangi versiyon tipine girer?

- ❌ MAJOR: Hayır (breaking change değil, sadece yeni field)
- ✅ MINOR: Evet (yeni özellik, geriye uyumlu)
- ❌ PATCH: Hayır (bug fix değil)

**Karar:** Versiyon `1.1.0` → `1.2.0` olacak

### Adım 2: Implementasyon

**Migration:**
```ruby
# db/migrate/20250111_add_phone_verified_to_users.rb
class AddPhoneVerifiedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :phone_verified, :boolean, default: false
  end
end
```

**Model Update:**
```ruby
# app/models/user.rb
class User < ApplicationRecord
  # ...
  validates :phone_verified, inclusion: { in: [true, false] }
end
```

**Controller Update:**
```ruby
# app/controllers/api/v1/users_controller.rb
def show
  render json: {
    data: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      phone_verified: user.phone_verified  # NEW FIELD
    }
  }
end
```

### Adım 3: Postman Collection Update

**Before (v1.1.0):**
```json
{
  "name": "Get User",
  "event": [
    {
      "listen": "test",
      "script": {
        "exec": [
          "pm.test('User has required fields', function () {",
          "    const user = pm.response.json().data;",
          "    pm.expect(user).to.have.property('id');",
          "    pm.expect(user).to.have.property('name');",
          "    pm.expect(user).to.have.property('email');",
          "    pm.expect(user).to.have.property('role');",
          "});"
        ]
      }
    }
  ]
}
```

**After (v1.2.0):**
```json
{
  "name": "Get User",
  "event": [
    {
      "listen": "test",
      "script": {
        "exec": [
          "pm.test('User has required fields', function () {",
          "    const user = pm.response.json().data;",
          "    pm.expect(user).to.have.property('id');",
          "    pm.expect(user).to.have.property('name');",
          "    pm.expect(user).to.have.property('email');",
          "    pm.expect(user).to.have.property('role');",
          "    pm.expect(user).to.have.property('phone_verified');  // NEW",
          "});",
          "",
          "pm.test('phone_verified is boolean', function () {",
          "    const user = pm.response.json().data;",
          "    pm.expect(user.phone_verified).to.be.a('boolean');",
          "});"
        ]
      }
    }
  ]
}
```

### Adım 4: Newman Test Update

**Yeni testler ekle:**

```bash
# Test 1: Existing tests should still pass (backward compatibility)
newman run collection_v1.2.0.json --environment dev.json

# Test 2: New field validation
newman run collection_v1.2.0.json \
  --folder "Users" \
  --reporter cli,json \
  --reporter-json-export reports/v1.2.0-users.json
```

### Adım 5: Changelog Update

**CHANGELOG.md:**

```markdown
# Changelog

## [1.2.0] - 2025-01-15

### Added
- `phone_verified` field to User model and API response
- New validation: phone_verified must be boolean

### Changed
- GET /api/v1/users/:id now includes `phone_verified` in response

### Deprecated
- None

### Removed
- None

### Fixed
- None

### Security
- None

### Migration
No migration required. Existing clients will receive `phone_verified: false` by default.
```

### Adım 6: Backward Compatibility Test

**Test Script:**

```javascript
// Test that old clients (expecting v1.1.0) still work with v1.2.0

pm.test('Backward compatibility: Old clients work', function () {
    const user = pm.response.json().data;

    // Old client expects these fields
    pm.expect(user).to.have.property('id');
    pm.expect(user).to.have.property('name');
    pm.expect(user).to.have.property('email');
    pm.expect(user).to.have.property('role');

    // New field is optional for old clients (they can ignore it)
    // API still returns it, but old clients don't break
});
```

### Adım 7: Documentation Update

**Update API docs:**

```markdown
## GET /api/v1/users/:id

**Response (v1.2.0+):**
```json
{
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "employee",
    "phone_verified": false  // NEW in v1.2.0
  }
}
```

**Changelog:**
- v1.2.0: Added `phone_verified` field
```

---

## 🔀 Version Migration Strategy

### Yöntem 1: URL-Based Versioning (VardiyaPro Kullanıyor)

**장점:**
- ✅ Açık ve net (/api/v1, /api/v2)
- ✅ Farklı versiyonlar aynı anda çalışabilir
- ✅ Kolay test edilebilir

**단점:**
- ❌ Her versiyon için ayrı kod gerekebilir
- ❌ Route dosyası karmaşık olabilir

### Yöntem 2: Header-Based Versioning

```
GET /api/users
Accept: application/vnd.vardiyapro.v1+json
```

### Yöntem 3: Query Parameter Versioning

```
GET /api/users?version=1
```

---

## 📊 Version Deprecation Policy

### Deprecation Timeline

```
v1.0.0 Release         → v2.0.0 Release → v1.0.0 Deprecated → v1.0.0 Removed
    |                       |                  |                   |
    +-- 6 months ----------+-- 3 months ------+-- 3 months -------+

Day 0: v1.0.0 active, v2.0.0 beta
Day 180: v2.0.0 stable, v1.0.0 marked deprecated
Day 270: v1.0.0 removed, clients must use v2.0.0
```

### Deprecation Warnings

**Response Header:**
```
Deprecation: true
Sunset: Sat, 31 Dec 2025 23:59:59 GMT
Link: </api/v2/users>; rel="successor-version"
```

**Response Body:**
```json
{
  "data": { ... },
  "deprecation_warning": {
    "message": "This API version (v1) is deprecated and will be removed on 2025-12-31",
    "successor": "/api/v2/users",
    "documentation": "https://docs.vardiyapro.com/migration-guide"
  }
}
```

---

## 🧪 Testing Matrix: Version Compatibility

### Test Senaryoları

| Test Case | v1.0.0 Client | v1.1.0 Client | v1.2.0 Client | v2.0.0 Client |
|-----------|---------------|---------------|---------------|---------------|
| GET /api/v1/users/:id | ✅ Pass | ✅ Pass | ✅ Pass | ❌ Not applicable |
| GET /api/v1/time_entries | ❌ 404 (not exists) | ✅ Pass | ✅ Pass | ❌ Not applicable |
| GET /api/v2/users/:id/profile | ❌ Not exists | ❌ Not exists | ❌ Not exists | ✅ Pass |

### Newman Test Commands

```bash
# Test v1.0.0 compatibility
newman run v1.0.0_collection.json --environment v1.json

# Test v1.1.0 compatibility
newman run v1.1.0_collection.json --environment v1.json

# Test v1.2.0 compatibility
newman run v1.2.0_collection.json --environment v1.json

# Test v2.0.0 (new features)
newman run v2.0.0_collection.json --environment v2.json

# Test backward compatibility (v1.2.0 client on v1.0.0 endpoints)
newman run backward_compat_collection.json --environment v1.json
```

---

## 📚 Real-World Example: Breaking Change

### Scenario: Authentication değişiyor (JWT → OAuth2)

Bu **MAJOR** bir değişikliktir çünkü mevcut clientlar çalışmayı durdurur.

#### Before (v1.x.x)

```
POST /api/v1/auth/login
Body: { "email": "...", "password": "..." }
Response: { "token": "eyJhbGc..." }

GET /api/v1/shifts
Authorization: Bearer eyJhbGc...
```

#### After (v2.0.0)

```
POST /api/v2/auth/oauth2/token
Body: {
  "grant_type": "password",
  "username": "...",
  "password": "...",
  "client_id": "..."
}
Response: {
  "access_token": "...",
  "refresh_token": "...",
  "expires_in": 3600
}

GET /api/v2/shifts
Authorization: Bearer <access_token>
```

#### Migration Strategy

1. **Parallel Run (6 months):**
   - v1 ve v2 aynı anda çalışır
   - v1'e deprecation warning eklenir
   - Clientlar yavaş yavaş v2'ye geçer

2. **Client Update Guide:**
   ```markdown
   # Migration Guide: v1 → v2 Authentication

   ## Step 1: Update login endpoint
   - Old: POST /api/v1/auth/login
   - New: POST /api/v2/auth/oauth2/token

   ## Step 2: Update request body
   - Add `grant_type: "password"`
   - Add `client_id` (get from admin panel)

   ## Step 3: Update token handling
   - Store both `access_token` and `refresh_token`
   - Implement refresh token flow

   ## Step 4: Test before deployment
   - Run Postman collection: migration_v1_to_v2.json
   ```

3. **Test Suite Update:**
   ```bash
   # Create migration test collection
   newman run migration_v1_to_v2_collection.json \
     --environment migration_env.json \
     --reporter html \
     --reporter-html-export migration_test_report.html
   ```

---

## 🎯 Best Practices

### 1. **Semantic Versioning Rules**
- ✅ Always increment MAJOR for breaking changes
- ✅ Increment MINOR for new features (backward compatible)
- ✅ Increment PATCH for bug fixes
- ✅ Document all changes in CHANGELOG.md

### 2. **API Versioning**
- ✅ Use URL-based versioning (/api/v1, /api/v2)
- ✅ Keep old versions running for 6+ months
- ✅ Add deprecation warnings 3 months before removal
- ✅ Provide migration guides

### 3. **Testing**
- ✅ Test new version with Postman/Newman
- ✅ Test backward compatibility
- ✅ Test migration path
- ✅ Update test collections for each version

### 4. **Documentation**
- ✅ Document breaking changes prominently
- ✅ Provide examples for each version
- ✅ Include migration guides
- ✅ Update Postman collections

---

## 📝 Summary

| Concept | VardiyaPro Implementation |
|---------|---------------------------|
| **Versioning Method** | URL-based (/api/v1, /api/v2) |
| **Current Version** | v1.1.0 (stable) |
| **Semver Format** | MAJOR.MINOR.PATCH |
| **Breaking Changes** | Require MAJOR version bump (v1 → v2) |
| **New Features** | Require MINOR version bump (v1.1 → v1.2) |
| **Bug Fixes** | Require PATCH version bump (v1.1.0 → v1.1.1) |
| **Deprecation Period** | 6 months |
| **Testing Tool** | Postman + Newman |

---

## ✅ Checklist (Hocanın İstekleri)

- [x] API sürümleme yapısı incelendi (/api/v1, /api/v2)
- [x] Semantic Versioning açıklandı (MAJOR.MINOR.PATCH)
- [x] Örnek senaryo yazıldı (users endpoint'ine yeni alan ekleme)
- [x] Test süreci değişiklikleri açıklandı
- [x] Migration stratejisi belirlendi
- [x] Postman/Newman test güncellemeleri dokümante edildi

---

**Hazırlayan:** Claude AI for VardiyaPro
**Tarih:** 2025-01-11
**Versiyon:** 1.0.0
