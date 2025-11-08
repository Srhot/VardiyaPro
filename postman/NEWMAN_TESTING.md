# Newman CLI - API Test Otomasyonu Rehberi

Newman, Postman collection'larını komut satırından çalıştırmak için resmi CLI aracıdır.

## Kurulum

### 1. Node.js Kurulumu (Gerekli)

```bash
# Node.js versiyonunu kontrol et
node --version
npm --version

# Eğer yüklü değilse: https://nodejs.org/
```

### 2. Newman Kurulumu

```bash
# Proje bağımlılıklarını yükle
npm install

# Veya Newman'i global olarak kur
npm install -g newman
npm install -g newman-reporter-html
npm install -g newman-reporter-htmlextra
```

## Test Çalıştırma

### Basit Test

```bash
# Collection'ı çalıştır
npm run test:api

# Veya doğrudan newman ile
newman run postman/VardiyaPro_API_Collection_v2.json \
  -e postman/VardiyaPro_Environment_Dev.json
```

### HTML Raporu Oluştur

```bash
# HTML raporu ile çalıştır
npm run test:api:html

# Rapor: postman/reports/test-report.html
```

### JSON Raporu Oluştur

```bash
# JSON raporu ile çalıştır
npm run test:api:json

# Rapor: postman/reports/test-report.json
```

### Tüm Raporları Oluştur

```bash
# HTML + JSON + CLI raporları
npm run test:api:all
```

### Detaylı (Verbose) Çıktı

```bash
# Her isteğin detaylarını göster
npm run test:api:verbose
```

## Test Çıktısı Örneği

```
┌─────────────────────────┬────────────────────┬───────────────────┐
│                         │           executed │            failed │
├─────────────────────────┼────────────────────┼───────────────────┤
│              iterations │                  1 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│                requests │                 15 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│            test-scripts │                 30 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│      prerequest-scripts │                 15 │                 0 │
├─────────────────────────┼────────────────────┼───────────────────┤
│              assertions │                 85 │                 0 │
├─────────────────────────┴────────────────────┴───────────────────┤
│ total run duration: 3.5s                                         │
├──────────────────────────────────────────────────────────────────┤
│ total data received: 15.2kB (approx)                            │
├──────────────────────────────────────────────────────────────────┤
│ average response time: 234ms [min: 45ms, max: 892ms, s.d.: 156ms]│
└──────────────────────────────────────────────────────────────────┘
```

## Pre-Request & Post-Response Scripts

Collection'daki her endpoint için:

### ✅ Pre-Request Script
```javascript
// Expected Response tanımlanır
pm.environment.set('savedResponseBody', `{
  "expected": "response structure"
}`);
```

### ✅ Post-Response Script (Test)
```javascript
// Actual response kontrolü
pm.test('Status code is 200', function () {
    pm.response.to.have.status(200);
});

pm.test('Response has required fields', function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('data');
});

// Expected vs Actual karşılaştırma
pm.test('Actual matches expected structure', function () {
    const actual = pm.response.json();
    // Validation logic...
});
```

## Test Senaryoları

### 1. Authentication Tests
- ✅ Login başarılı (200)
- ✅ Token format validation (JWT)
- ✅ Invalid credentials (401)
- ✅ Token ve user_id otomatik kaydedilir

### 2. Departments Tests
- ✅ List departments (200)
- ✅ Create department (201)
- ✅ Pagination metadata kontrolü
- ✅ Department name titleized mi?

### 3. Shifts Tests
- ✅ List shifts with pagination
- ✅ **CRITICAL:** Duration validation (min 4h, max 12h)
- ✅ Shift type validation
- ✅ Required fields kontrolü

### 4. Assignments Tests
- ✅ **CRITICAL:** Overlap validation testi
- ✅ Double-booking prevention
- ✅ Overfill validation

### 5. Reports Tests
- ✅ Employee report with statistics
- ✅ Total hours calculation
- ✅ Date range filtering

## Gelişmiş Kullanım

### Spesifik Klasör Çalıştır

```bash
newman run postman/VardiyaPro_API_Collection_v2.json \
  -e postman/VardiyaPro_Environment_Dev.json \
  --folder "Authentication"
```

### Iteration Count (Çoklu Çalıştırma)

```bash
newman run postman/VardiyaPro_API_Collection_v2.json \
  -e postman/VardiyaPro_Environment_Dev.json \
  -n 5  # 5 kez çalıştır
```

### Delay Ekle (Rate Limiting)

```bash
newman run postman/VardiyaPro_API_Collection_v2.json \
  -e postman/VardiyaPro_Environment_Dev.json \
  --delay-request 1000  # Her istek arası 1 saniye bekle
```

### Timeout Ayarla

```bash
newman run postman/VardiyaPro_API_Collection_v2.json \
  -e postman/VardiyaPro_Environment_Dev.json \
  --timeout-request 10000  # 10 saniye timeout
```

### Environment Variables Override

```bash
newman run postman/VardiyaPro_API_Collection_v2.json \
  -e postman/VardiyaPro_Environment_Dev.json \
  --env-var "base_url=http://production-server.com/api/v1"
```

## HTML Raporu Detayları

HTML raporu şunları içerir:

- ✅ Request/Response detayları
- ✅ Test sonuçları (passed/failed)
- ✅ Assertion sonuçları
- ✅ Response time grafikleri
- ✅ Pre-request script çıktıları
- ✅ Console log'lar
- ✅ Error stack traces (varsa)

**Rapor Konumu:** `postman/reports/test-report.html`

Tarayıcıda açmak için:
```bash
# Windows
start postman/reports/test-report.html

# Linux/Mac
open postman/reports/test-report.html
```

## JSON Raporu Kullanımı

JSON raporu CI/CD pipeline'larında kullanılabilir:

```javascript
{
  "collection": {
    "info": { "name": "VardiyaPro API" }
  },
  "run": {
    "stats": {
      "requests": { "total": 15, "failed": 0 },
      "assertions": { "total": 85, "failed": 0 }
    },
    "failures": [],
    "executions": [...]
  }
}
```

## CI/CD Entegrasyonu

### GitHub Actions

```yaml
- name: Run API Tests
  run: |
    npm install
    npm run test:api:all

- name: Upload Test Report
  uses: actions/upload-artifact@v4
  with:
    name: newman-report
    path: postman/reports/
```

### Exit Codes

Newman exit code'ları:
- `0` - Tüm testler başarılı
- `1` - Bir veya daha fazla test başarısız
- `2` - Newman hatası (collection bulunamadı, vb.)

Kullanımı:
```bash
npm run test:api
if [ $? -eq 0 ]; then
  echo "✓ All tests passed!"
else
  echo "✗ Tests failed!"
  exit 1
fi
```

## Troubleshooting

### Hata: "Collection not found"
```bash
# Path'i kontrol et
ls -la postman/

# Tam path ile çalıştır
newman run "$(pwd)/postman/VardiyaPro_API_Collection_v2.json"
```

### Hata: "ECONNREFUSED"
```bash
# Rails server çalışıyor mu?
curl http://127.0.0.1:3000/up

# Server'ı başlat
bundle exec rails server
```

### Hata: "newman: command not found"
```bash
# Newman'i kur
npm install -g newman

# Veya npx ile çalıştır
npx newman run postman/VardiyaPro_API_Collection_v2.json
```

## Best Practices

1. **Pre-Request Always Define Expected**
   - Her request için expected response tanımla
   - Validation'da kullan

2. **Post-Response Multiple Assertions**
   - Status code
   - Response structure
   - Field validations
   - Expected vs Actual comparison

3. **Use Variables**
   - Hard-coded değerler yerine variables kullan
   - Token'ları otomatik kaydet
   - ID'leri chain'le

4. **Test Names Descriptive**
   - "Test 1" değil, "Status code is 200" kullan
   - Anlaşılır hata mesajları

5. **Critical Tests Separately**
   - Overlap validation gibi kritik testler ayrı request olsun
   - Negative scenario'ları test et

## Raporlama

### Test Summary
```bash
# Son test sonuçlarını göster
npm run test:api | grep -A 10 "┌─────────────────────────┬"
```

### Failed Tests Only
```bash
# Sadece başarısız testleri göster
npm run test:api 2>&1 | grep "✗"
```

### Performance Metrics
```bash
# Response time istatistikleri
npm run test:api | grep "average response time"
```

## Örnek Tam Workflow

```bash
# 1. Dependency'leri kur
npm install

# 2. Rails server'ı başlat (başka terminal)
bundle exec rails server

# 3. Seed data'yı yükle (ilk kez)
bundle exec rails db:seed

# 4. Testleri çalıştır
npm run test:api:all

# 5. HTML raporunu aç
start postman/reports/test-report.html

# 6. CI/CD için JSON'u kontrol et
cat postman/reports/test-report.json | jq '.run.stats'
```

## Sonuç

Newman ile:
- ✅ Otomatik API testleri
- ✅ Pre/Post request validation
- ✅ HTML/JSON raporlar
- ✅ CI/CD entegrasyonu
- ✅ Regression testing
- ✅ Performance monitoring

**Hazır!** 🚀

---

**Son Güncelleme:** 2025-01-08
**Version:** 2.0.0
