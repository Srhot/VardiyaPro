# API Versioning Guide - VardiyaPro

## Table of Contents

- [Overview](#overview)
- [Semantic Versioning](#semantic-versioning)
- [API Versions](#api-versions)
- [Migration Guide](#migration-guide)
- [Breaking Changes](#breaking-changes)
- [Test Strategy](#test-strategy)

---

## Overview

VardiyaPro API uses **URI-based versioning** to maintain backward compatibility while introducing new features.

### Current Versions

| Version | Status | Base URL | Released |
|---------|--------|----------|----------|
| **v1** | ✅ Stable | `/api/v1/*` | 2025-01-01 |
| **v2** | ✅ Stable | `/api/v2/*` | 2025-01-08 |

### Version Strategy

- **v1**: Core MVP features, stable, maintained
- **v2**: Enhanced features, additional endpoints, performance improvements
- **Future (v3)**: Planned for Q2 2025 (WebSocket support, real-time notifications)

---

## Semantic Versioning

VardiyaPro follows **Semantic Versioning 2.0.0** (semver) for API versioning:

```
MAJOR.MINOR.PATCH
  │     │     │
  │     │     └── Bug fixes (backwards compatible)
  │     └──────── New features (backwards compatible)
  └────────────── Breaking changes (NOT backwards compatible)
```

### Examples

- `1.0.0` → Initial release
- `1.1.0` → Added new endpoint (backwards compatible)
- `1.1.1` → Bug fix (backwards compatible)
- `2.0.0` → Breaking change (NOT backwards compatible) → New API version!

### When to Bump Version

#### PATCH (1.0.0 → 1.0.1)
- ✅ Bug fixes
- ✅ Performance improvements
- ✅ Documentation updates
- ❌ No API changes

#### MINOR (1.0.0 → 1.1.0)
- ✅ New optional fields in response
- ✅ New query parameters (optional)
- ✅ New endpoints
- ❌ No breaking changes to existing endpoints

#### MAJOR (1.0.0 → 2.0.0)
- ⚠️ Removed fields from response
- ⚠️ Changed field types (string → integer)
- ⚠️ Required new parameters
- ⚠️ Renamed endpoints
- ⚠️ Changed authentication method

**When MAJOR changes → Create new API version (v2)**

---

## API Versions

### v1 - Core Features

**Base URL:** `http://your-domain.com/api/v1`

**Features:**
- ✅ Authentication (JWT)
- ✅ Users CRUD
- ✅ Departments management
- ✅ Shifts scheduling
- ✅ Assignments with overlap validation
- ✅ Notifications
- ✅ Reports (basic)
- ✅ Audit logs

**Example Endpoints:**
```
POST   /api/v1/auth/login
GET    /api/v1/users
GET    /api/v1/shifts
POST   /api/v1/assignments
GET    /api/v1/reports/employee/:id
```

**Response Format:**
```json
{
  "data": { ... },
  "meta": { ... }
}
```

---

### v2 - Enhanced Features

**Base URL:** `http://your-domain.com/api/v2`

**What's New:**
- ✅ Enhanced user profiles with statistics
- ✅ User performance metrics
- ✅ Detailed user statistics endpoint
- ✅ Department team metrics
- ✅ Shift capacity planning report
- ✅ API version header (`X-API-Version: v2`)

**New Endpoints:**
```
GET    /api/v2/users/:id/profile        # Enhanced profile
GET    /api/v2/users/:id/statistics     # Detailed stats
GET    /api/v2/departments/:id/team_metrics
GET    /api/v2/shifts/capacity_report
```

**Enhanced Response Format (v2):**
```json
{
  "data": {
    "user": { ... },
    "statistics": {
      "total_hours_this_month": 160.5,
      "attendance_rate": 95.2
    },
    "performance_metrics": { ... }
  },
  "api_version": "v2"
}
```

**Response Headers:**
```
X-API-Version: v2
```

---

## Migration Guide

### v1 → v2 Migration

#### Step 1: Test Compatibility

Before migrating, test v2 endpoints in parallel with v1:

```bash
# v1 request
curl http://localhost:3000/api/v1/users/1

# v2 request (enhanced)
curl http://localhost:3000/api/v2/users/1/profile
```

#### Step 2: Update Client Code

```javascript
// OLD (v1)
const response = await fetch('/api/v1/users/1');
const data = await response.json();
console.log(data.data.email);

// NEW (v2)
const response = await fetch('/api/v2/users/1/profile');
const data = await response.json();
console.log(data.data.user.email);
console.log(data.data.statistics.total_hours_this_month); // NEW!
```

#### Step 3: Gradual Migration

1. **Week 1-2:** Test v2 endpoints in development
2. **Week 3:** Deploy both v1 and v2 to staging
3. **Week 4:** Migrate 25% of users to v2
4. **Week 5-6:** Migrate remaining users
5. **Week 7+:** Deprecate v1 (after 6 months notice)

#### Backward Compatibility

✅ **v1 will be maintained for 6 months after v2 release**

Deprecation schedule:
- ✅ 2025-01-08: v2 released
- ⚠️ 2025-04-08: v1 deprecation notice
- ❌ 2025-07-08: v1 sunset (no longer supported)

---

## Breaking Changes

### What Counts as Breaking?

#### ❌ Breaking Changes (Requires new version)

1. **Removing fields:**
```json
// v1 response
{ "id": 1, "name": "John", "age": 30 }

// v2 response (BREAKING!)
{ "id": 1, "name": "John" }  // age removed!
```

2. **Changing field types:**
```json
// v1
{ "user_id": "123" }  // string

// v2 (BREAKING!)
{ "user_id": 123 }  // integer
```

3. **Required new parameters:**
```javascript
// v1
POST /api/v1/users { "email": "test@test.com" }

// v2 (BREAKING!)
POST /api/v2/users { "email": "test@test.com", "phone": "required!" }
```

#### ✅ Non-Breaking Changes (Same version OK)

1. **Adding optional fields:**
```json
// v1
{ "id": 1, "name": "John" }

// v1.1 (OK!)
{ "id": 1, "name": "John", "age": 30 }  // age is optional
```

2. **New endpoints:**
```
GET /api/v1/users/:id/new-stats  // OK, doesn't affect existing
```

3. **New optional query parameters:**
```
GET /api/v1/users?new_filter=value  // OK, optional
```

---

## Test Strategy

### Testing New API Version

When a new version is released, test scenarios must be updated:

#### Scenario: New Field Added to User Endpoint

**v1 → v2 Change:**
```diff
// v2 users endpoint now includes "total_hours_this_month"
{
  "id": 1,
  "email": "user@example.com",
+ "total_hours_this_month": 160.5
}
```

**Updated Test Process:**

##### 1. Update Postman Collection

**v1 Test (existing):**
```javascript
pm.test("User has email", function () {
    pm.expect(pm.response.json().data.email).to.exist;
});
```

**v2 Test (new):**
```javascript
pm.test("User has email", function () {
    pm.expect(pm.response.json().data.email).to.exist;
});

pm.test("User has total hours (v2)", function () {
    const data = pm.response.json().data;
    pm.expect(data).to.have.property('total_hours_this_month');
    pm.expect(data.total_hours_this_month).to.be.a('number');
});

pm.test("API version header is v2", function () {
    pm.expect(pm.response.headers.get('X-API-Version')).to.equal('v2');
});
```

##### 2. Update RSpec Tests

```ruby
# spec/requests/api/v2/users_spec.rb

RSpec.describe 'API v2 Users', type: :request do
  describe 'GET /api/v2/users/:id/profile' do
    it 'includes v2-specific fields' do
      user = create(:user)
      get "/api/v2/users/#{user.id}/profile",
          headers: auth_headers_for(admin)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      # v2-specific assertions
      expect(json['data']).to have_key('statistics')
      expect(json['data']['statistics']).to have_key('total_hours_this_month')
      expect(json['api_version']).to eq('v2')
    end
  end
end
```

##### 3. Parallel Testing Strategy

Run both versions in CI/CD:

```yaml
# .github/workflows/ci.yml
jobs:
  test-v1:
    runs-on: ubuntu-latest
    steps:
      - name: Test API v1
        run: npm run test:api:v1

  test-v2:
    runs-on: ubuntu-latest
    steps:
      - name: Test API v2
        run: npm run test:api:v2
```

##### 4. Regression Testing

Ensure v1 still works after v2 release:

```bash
# Run v1 tests
newman run postman/v1_tests.json

# Run v2 tests
newman run postman/v2_tests.json

# Both should pass!
```

---

## Example Scenarios

### Scenario 1: Adding Optional Filter

**Change:** Add `?active=true` filter to `/api/v1/users`

**Impact:** ✅ **Non-breaking**

**Reasoning:** Optional parameter, defaults to showing all users if not provided

**Action:** Update documentation, no version bump needed (minor version 1.1.0 → 1.2.0)

---

### Scenario 2: Changing Status Values

**Change:**
```diff
// v1: status values
- ["pending", "active", "inactive"]
+ ["draft", "published", "archived"]  // v2: renamed!
```

**Impact:** ❌ **BREAKING**

**Reasoning:** Existing clients expect old status values

**Action:** Create v2 API with new status values, keep v1 with old values

**Migration:**
```javascript
// v1 client (still works)
if (user.status === 'active') { ... }

// v2 client (new status)
if (user.status === 'published') { ... }
```

---

### Scenario 3: Required Field Added

**Change:**
```diff
// POST /api/v1/users
{
  "email": "user@example.com",
- // phone is optional
}

// POST /api/v2/users
{
  "email": "user@example.com",
+ "phone": "123-456-7890"  // now required!
}
```

**Impact:** ❌ **BREAKING**

**Reasoning:** Existing clients don't send `phone`, will fail validation

**Action:**
- v1: Keep `phone` optional
- v2: Make `phone` required
- Update Postman tests for both versions

**Test Update:**
```javascript
// v1 test (still passes)
pm.test("Can create user without phone", function () {
    // phone is optional
});

// v2 test (new requirement)
pm.test("Requires phone number", function () {
    // phone is required, test validation error if missing
});
```

---

## Version Support Policy

### Active Support

- **v1:** Supported until 2025-07-08
- **v2:** Current stable version
- **v3:** Planned for Q2 2025

### Deprecation Process

1. **Announcement:** 3 months before deprecation
2. **Warning Headers:** API returns `X-API-Deprecated: true`
3. **Sunset Date:** Published in documentation
4. **Grace Period:** 1 month after sunset, returns 410 Gone

---

## Best Practices

### For API Consumers

1. ✅ **Always specify version in URL:** `/api/v1/users`
2. ✅ **Monitor deprecation headers:** Check `X-API-Deprecated`
3. ✅ **Test new versions early:** Try v2 in development before production
4. ✅ **Have fallback logic:** Handle both old and new response formats
5. ✅ **Subscribe to changelog:** Stay informed about upcoming changes

### For API Developers

1. ✅ **Never break v1:** Keep existing versions stable
2. ✅ **Document all changes:** Maintain CHANGELOG.md
3. ✅ **Test both versions:** Run tests for v1 and v2 in parallel
4. ✅ **Use feature flags:** Gradual rollout of new features
5. ✅ **Communicate early:** Announce breaking changes 6 months ahead

---

## Changelog

### v2.0.0 (2025-01-08)

**Added:**
- Enhanced user profile endpoint (`/api/v2/users/:id/profile`)
- User statistics endpoint (`/api/v2/users/:id/statistics`)
- Performance metrics (attendance rate, average hours)
- Department team metrics endpoint
- Shift capacity planning report
- API version header (`X-API-Version`)

**Changed:**
- User response includes `total_hours_this_month` and `attendance_rate`
- Enhanced pagination metadata

**Deprecated:**
- None (v1 still fully supported)

### v1.0.0 (2025-01-01)

**Initial Release:**
- Authentication (JWT)
- Users CRUD
- Departments management
- Shifts scheduling
- Assignments with overlap validation
- Notifications system
- Reports (employee, department, overtime)
- Audit logging

---

## Support

Questions about API versioning?

- 📧 Email: api-support@vardiyapro.com
- 📚 Docs: https://docs.vardiyapro.com
- 💬 Slack: #api-support

---

**Last Updated:** 2025-01-08
**Version:** 2.0.0
