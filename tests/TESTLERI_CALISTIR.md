# 🎬 Playwright Testlerini Çalıştırma Rehberi

## ⚡ Hızlı Başlangıç (3 Adım)

### 1️⃣ Test Klasörüne Git

**Windows PowerShell veya CMD:**
```bash
cd C:\Users\[KullanıcıAdınız]\VardiyaPro\tests
```

**VEYA Docker/Linux:**
```bash
cd /home/user/VardiyaPro/tests
```

### 2️⃣ Playwright'ı Kur

```bash
npm install
npx playwright install chromium
```

**Beklenen çıktı:**
```
added 2 packages
✔ chromium v1.40 downloaded successfully
```

### 3️⃣ Testleri Çalıştır

```bash
npm test
```

**Beklenen çıktı:**
```
Running 29 tests using 1 worker

✓ auth.spec.js:15:3 › Successful login with admin credentials (5.2s)
✓ auth.spec.js:42:3 › Successful login with manager credentials (4.8s)
...
29 passed (2.1m)
```

---

## 📊 Test Sonuçlarını Görüntüleme

### HTML Raporu Aç

```bash
npm run test:report
```

Bu komut tarayıcınızda otomatik açar:
- ✅ Hangi testler geçti
- ❌ Hangi testler başarısız
- 🎥 Test videoları
- 📸 Hata ekran görüntüleri

### Videoları İzle

**Windows Explorer:**
```
C:\Users\[Kullanıcı]\VardiyaPro\tests\test-results\
```

Her test klasöründe `video.webm` dosyası var.

**Örnek:**
```
test-results\
├── auth-Successful-login-chromium\
│   └── video.webm
├── departments-Create-department-chromium\
│   └── video.webm
└── ...
```

VLC Player, Chrome veya herhangi bir video oynatıcı ile açabilirsiniz.

---

## 🎯 Farklı Test Çalıştırma Modları

### 1. Tarayıcıyı Görerek Çalıştır (Headed Mode)

```bash
npm run test:headed
```

Chrome penceresi açılır, testleri canlı izlersiniz.

### 2. Sadece Bir Test Dosyası Çalıştır

**Sadece Authentication testleri:**
```bash
npx playwright test e2e/specs/auth.spec.js
```

**Sadece Departments testleri:**
```bash
npx playwright test e2e/specs/departments.spec.js
```

**Sadece Reports testleri:**
```bash
npx playwright test e2e/specs/reports.spec.js
```

**Sadece Navigation testleri:**
```bash
npx playwright test e2e/specs/navigation.spec.js
```

### 3. Sadece Bir Test Çalıştır

```bash
npx playwright test e2e/specs/auth.spec.js --grep "Successful login with admin"
```

### 4. Debug Modu (Adım Adım İzle)

```bash
npm run test:debug
```

Playwright Inspector açılır, her adımı manuel ilerletebilirsiniz.

### 5. UI Mode (En Güzel Görünüm)

```bash
npm run test:ui
```

Interaktif test arayüzü açılır:
- Testleri seçebilirsiniz
- Adım adım çalıştırabilirsiniz
- Video ve ekran görüntülerini görebilirsiniz

---

## 🐛 Hata Aldıysanız

### Hata 1: "Cannot find module '@playwright/test'"

**Çözüm:**
```bash
cd tests
npm install
```

### Hata 2: "Target closed" veya "Browser not installed"

**Çözüm:**
```bash
npx playwright install chromium
```

### Hata 3: "connect ECONNREFUSED 127.0.0.1:3000"

**Çözüm:** Rails server çalışmıyor.

**Docker ile başlat:**
```bash
cd ..  # VardiyaPro klasörüne dön
docker compose up -d
```

**Kontrol et:**
```bash
curl http://127.0.0.1:3000/up
```

Yeşil ekran görürseniz → Server çalışıyor ✅

### Hata 4: Test başarısız oldu

1. **HTML raporuna bak:**
   ```bash
   npm run test:report
   ```

2. **Videoyu izle:**
   - `test-results/` klasöründeki failed test videosunu aç
   - Tam olarak nerede hata aldığını göreceksin

3. **Debug mode ile tekrar çalıştır:**
   ```bash
   npx playwright test e2e/specs/[başarısız-test].spec.js --debug
   ```

---

## 📹 Videoları Birleştirme (Tek Video Haline Getir)

### Yöntem 1: FFmpeg ile (En iyi yöntem)

**FFmpeg'i kur:**
- **Windows:** `choco install ffmpeg` (Chocolatey gerekli)
- **macOS:** `brew install ffmpeg`
- **Linux:** `sudo apt install ffmpeg`

**Video listesi oluştur:**
```bash
cd test-results
```

**Windows PowerShell:**
```powershell
Get-ChildItem -Recurse -Filter video.webm | ForEach-Object { "file '$($_.FullName)'" } | Out-File -Encoding utf8 videos.txt
```

**Linux/macOS:**
```bash
find . -name "video.webm" -exec echo "file '{}'" \; > videos.txt
```

**Birleştir:**
```bash
ffmpeg -f concat -safe 0 -i videos.txt -c copy ../all-tests-merged.webm
```

**Sonuç:** `VardiyaPro/all-tests-merged.webm` dosyası oluşur (tüm testler tek videoda)

### Yöntem 2: Manuel (Tarayıcı ile)

1. Tüm `video.webm` dosyalarını bir klasöre kopyala
2. [Online Video Joiner](https://www.kapwing.com/tools/join-video) gibi bir site kullan
3. Tüm videoları yükle ve birleştir
4. İndir

---

## 📊 Test İstatistikleri

Toplam test sayısı: **29 tests**

| Test Dosyası | Test Sayısı | Tahmini Süre |
|--------------|-------------|--------------|
| `auth.spec.js` | 6 | ~30 saniye |
| `navigation.spec.js` | 8 | ~40 saniye |
| `departments.spec.js` | 7 | ~35 saniye |
| `reports.spec.js` | 8 | ~25 saniye |
| **TOPLAM** | **29** | **~2 dakika** |

---

## ✅ Başarılı Test Çalışması Kontrolü

Test başarılı çalıştığında göreceğiniz çıktı:

```
Running 29 tests using 1 worker

  ✓  1 auth.spec.js:15:3 › Successful login with admin credentials (5.2s)
  ✓  2 auth.spec.js:42:3 › Successful login with manager credentials (4.8s)
  ✓  3 auth.spec.js:71:3 › Successful login with employee credentials (4.5s)
  ✓  4 auth.spec.js:92:3 › Logout successfully (6.1s)
  ✓  5 auth.spec.js:121:3 › Failed login with invalid credentials (3.2s)
  ✓  6 auth.spec.js:148:3 › JWT token persistence (5.8s)

  ✓  7 navigation.spec.js:19:3 › Navigate to all pages (15.3s)
  ✓  8 navigation.spec.js:52:3 › Browser back/forward buttons (8.7s)
  ... (21 more tests)

  29 passed (2m 8s)
```

**Yeşil tik (✓) = Başarılı**
**Kırmızı çarpı (✗) = Başarısız**

---

## 🎓 Ödev İçin Gerekli Belgeler

### 1. Test Raporu

```bash
npm run test:report
```

Tarayıcıda açılan raporu ekran görüntüsü alın.

### 2. Video Kayıtları

- `test-results/` klasöründeki tüm videolar
- Veya birleştirilmiş tek video

### 3. Test Kod Örnekleri

BDD formatında test örneği göstermek için:

**Dosya:** `e2e/specs/auth.spec.js:15-40`

```javascript
test('Scenario: Successful login with admin credentials', async ({ page }) => {
  // GIVEN I am on the login page
  await loginPage.verifyLoginPageVisible();

  // WHEN I enter valid admin credentials
  await test.step('I fill in the email field', async () => {
    await loginPage.fillCredentials('admin@vardiyapro.com', 'password123');
  });

  // AND I click the login button
  await test.step('I click the login button', async () => {
    await loginPage.clickLogin();
  });

  // THEN I should be redirected to the dashboard
  await test.step('I should see the dashboard', async () => {
    await loginPage.verifyLoginSuccess();
    await dashboardPage.verifyDashboardLoaded();
  });
});
```

---

## 💡 İpuçları

1. **Her zaman Rails server çalışıyor olsun** → `curl http://127.0.0.1:3000/up`
2. **Test başarısız olursa videoyu izle** → Tam nerede hata olduğunu gösterir
3. **İlk testte hatalar olabilir** → Normal, düzeltip tekrar çalıştır
4. **Testler yavaş mı?** → `playwright.config.js` içinde `slowMo: 500` satırını sil
5. **Paralel çalıştır?** → `playwright.config.js` içinde `workers: 4` yap

---

## 📞 Yardım

Sorun yaşarsanız:

1. ✅ README.md dosyasını oku
2. ✅ HTML raporuna bak (`npm run test:report`)
3. ✅ Videoları izle (`test-results/*/video.webm`)
4. ✅ Debug mode ile çalıştır (`npm run test:debug`)

---

**Testler Hazır! Başarılar! 🚀**

**Son Güncelleme:** 9 Kasım 2025
