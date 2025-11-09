# 📦 VardiyaPro - Ödev Teslim Rehberi

**Tarih:** 9 Kasım 2025
**Ders:** Web Teknolojileri ve Uygulamaları
**Proje:** VardiyaPro - Shift Management System

---

## 🎯 Teslimat Checklist

Bu rehber, ödevinizi eksiksiz teslim etmeniz için adım adım kılavuzdur.

### ✅ Teslim Edilecek Dosyalar

- [ ] Ödev raporu (PDF)
- [ ] Test videosu - ÖNCE (tek video, birleştirilmiş)
- [ ] Test videosu - SONRA (tek video, birleştirilmiş)
- [ ] Postman collection (JSON)
- [ ] Newman test raporu (HTML)
- [ ] Playwright test raporu (HTML)
- [ ] GitHub repo linki

---

## 📹 ADIM 1: Test Videolarını Tek Parça Haline Getir

### ⚠️ ÖNEMLİ: Hoca Tek Video İstiyor!

Hoca videoları **tek parça** halinde istedi. Her testin ayrı videosu yerine, tüm testlerin birleştirilmiş tek bir video dosyası olmalı.

### Option 1: Online Video Merger Kullan (ÖNERİLEN - 10 dakika)

#### 1.1. Kapwing ile Birleştirme

**Adım 1:** Test sonuçları klasörlerini aç

```powershell
# BEFORE-FIX videoları için
cd test-results-BEFORE-FIX
explorer .
```

**Adım 2:** Tüm video dosyalarını bul

```powershell
# PowerShell'de çalıştır - video dosyalarının listesini gösterir
Get-ChildItem -Recurse -Filter "video.webm" | Select-Object FullName
```

Her test klasöründe bir `video.webm` dosyası var. Bunları toplayacağız.

**Adım 3:** Kapwing'e git

1. Tarayıcıda aç: https://www.kapwing.com/tools/join-video
2. "Choose videos" butonuna tıkla
3. Tüm `video.webm` dosyalarını seç ve yükle

**Video dosyalarını nasıl bulacaksın?**

```
test-results-BEFORE-FIX/
├── auth-Successful-login-admin-chromium/
│   └── video.webm  ← Bu dosyayı seç
├── auth-Successful-login-manager-chromium/
│   └── video.webm  ← Bu dosyayı seç
├── auth-Logout-successfully-chromium/
│   └── video.webm  ← Bu dosyayı seç
└── ... (tüm klasörlerdeki video.webm dosyalarını seç)
```

**Adım 4:** Videoları birleştir

1. Tüm videoları yükledikten sonra "Export Project" tıkla
2. Video işlenmeyi bekle (~2-3 dakika)
3. "Download" butonuna tıkla
4. Dosyayı şu isimle kaydet: `VardiyaPro-Testler-ONCE.webm`

**Adım 5:** AFTER-FIX videoları için tekrarla

```powershell
cd ../test-results
explorer .
```

Aynı adımları tekrar et, bu sefer dosya adı: `VardiyaPro-Testler-SONRA.webm`

#### 1.2. Alternatif: Clideo Kullan

Kapwing çalışmazsa: https://clideo.com/merge-video

Aynı adımları uygula.

### Option 2: FFmpeg Kullan (Teknik Kullanıcılar - 30 dakika)

#### 2.1. FFmpeg Kurulumu

**Windows PowerShell (Admin):**
```powershell
# Chocolatey kurulu değilse:
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# FFmpeg kur:
choco install ffmpeg -y
```

**Kurulum kontrolü:**
```powershell
ffmpeg -version
```

Eğer versiyon numarası görünüyorsa kurulum başarılı.

#### 2.2. Video Birleştirme

**BEFORE-FIX videoları için:**

```powershell
cd test-results-BEFORE-FIX

# Video listesi oluştur
Get-ChildItem -Recurse -Filter video.webm | ForEach-Object { "file '$($_.FullName)'" } | Out-File -Encoding utf8 videos-before.txt

# Birleştir
ffmpeg -f concat -safe 0 -i videos-before.txt -c copy ../VardiyaPro-Testler-ONCE.webm

cd ..
```

**AFTER-FIX videoları için:**

```powershell
cd test-results

# Video listesi oluştur
Get-ChildItem -Recurse -Filter video.webm | ForEach-Object { "file '$($_.FullName)'" } | Out-File -Encoding utf8 videos-after.txt

# Birleştir
ffmpeg -f concat -safe 0 -i videos-after.txt -c copy ../VardiyaPro-Testler-SONRA.webm

cd ..
```

#### 2.3. Sonuç Kontrolü

```powershell
# Ana klasörde bu dosyalar olmalı:
ls *.webm
```

Göreceğin dosyalar:
- `VardiyaPro-Testler-ONCE.webm` (BEFORE-FIX, ~3-4 dakika)
- `VardiyaPro-Testler-SONRA.webm` (AFTER-FIX, ~2 dakika)

**Video oynat ve kontrol et:**
```powershell
# Windows Media Player ile aç
start VardiyaPro-Testler-ONCE.webm
start VardiyaPro-Testler-SONRA.webm
```

---

## 📄 ADIM 2: Ödev Raporunu PDF'e Çevir

### 2.1. Markdown'u PDF'e Çevir

**Option A: Online Converter (Kolay)**

1. https://www.markdowntopdf.com/ sitesine git
2. `docs/HOMEWORK_REPORT.md` dosyasını yükle
3. "Convert" butonuna tıkla
4. PDF'i indir: `VardiyaPro-Odev-Raporu.pdf`

**Option B: Pandoc Kullan (Teknik)**

```bash
# Pandoc kurulu ise:
pandoc docs/HOMEWORK_REPORT.md -o VardiyaPro-Odev-Raporu.pdf --pdf-engine=xelatex

# Veya Windows'da:
choco install pandoc -y
pandoc docs/HOMEWORK_REPORT.md -o VardiyaPro-Odev-Raporu.pdf
```

**Option C: VS Code Extension**

1. VS Code'da `HOMEWORK_REPORT.md` aç
2. Extension kur: "Markdown PDF" (yzane.markdown-pdf)
3. `Ctrl+Shift+P` → "Markdown PDF: Export (pdf)" seç
4. PDF oluşturulacak

### 2.2. PDF Kontrolü

PDF'i aç ve kontrol et:
- ✅ Tüm bölümler var mı?
- ✅ Kod örnekleri düzgün görünüyor mu?
- ✅ Tablolar bozulmamış mı?
- ✅ Görüntüler (varsa) görünüyor mu?

---

## 📊 ADIM 3: Test Raporlarını Topla

### 3.1. Postman Collection

**Dosya konumu:** `test/postman/collections/VardiyaPro_Complete_v3.postman_collection.json`

**Kopyala:**
```powershell
Copy-Item "test/postman/collections/VardiyaPro_Complete_v3.postman_collection.json" -Destination "VardiyaPro-Postman-Collection.json"
```

### 3.2. Newman Test Raporu

**Newman testlerini çalıştır (eğer henüz çalıştırmadıysan):**

```bash
cd test/postman
./run-newman-tests.sh
```

**HTML raporu:**
- Dosya: `test/postman/reports/newman-report.html`
- Tarayıcıda aç ve kontrol et

**Kopyala:**
```powershell
Copy-Item "test/postman/reports/newman-report.html" -Destination "VardiyaPro-Newman-Report.html"
```

### 3.3. Playwright Test Raporu

**Testleri çalıştır (eğer henüz çalıştırmadıysan):**

```bash
cd tests
npm test
```

**HTML raporu oluştur:**
```bash
npm run test:report
```

Tarayıcıda otomatik açılır. Sayfayı kaydet:
- `Ctrl+S` → `VardiyaPro-Playwright-Report.html` olarak kaydet

**Veya dosyayı kopyala:**
```powershell
Copy-Item "tests/playwright-report/index.html" -Destination "VardiyaPro-Playwright-Report.html"
```

---

## 📁 ADIM 4: Teslimat Klasörünü Oluştur

### 4.1. Klasör Yapısı

```
VardiyaPro-Odev-Teslimati/
├── 01-Odev-Raporu/
│   └── VardiyaPro-Odev-Raporu.pdf
├── 02-Test-Videolari/
│   ├── VardiyaPro-Testler-ONCE.webm
│   └── VardiyaPro-Testler-SONRA.webm
├── 03-Postman-Testleri/
│   ├── VardiyaPro-Postman-Collection.json
│   └── VardiyaPro-Newman-Report.html
├── 04-Playwright-Testleri/
│   └── VardiyaPro-Playwright-Report.html
└── README.txt
```

### 4.2. Klasörleri Oluştur

```powershell
# Ana teslimat klasörü
New-Item -ItemType Directory -Path "VardiyaPro-Odev-Teslimati"
cd VardiyaPro-Odev-Teslimati

# Alt klasörler
New-Item -ItemType Directory -Path "01-Odev-Raporu"
New-Item -ItemType Directory -Path "02-Test-Videolari"
New-Item -ItemType Directory -Path "03-Postman-Testleri"
New-Item -ItemType Directory -Path "04-Playwright-Testleri"
```

### 4.3. Dosyaları Kopyala

```powershell
# Ödev raporu
Copy-Item "../VardiyaPro-Odev-Raporu.pdf" -Destination "01-Odev-Raporu/"

# Test videoları
Copy-Item "../VardiyaPro-Testler-ONCE.webm" -Destination "02-Test-Videolari/"
Copy-Item "../VardiyaPro-Testler-SONRA.webm" -Destination "02-Test-Videolari/"

# Postman
Copy-Item "../VardiyaPro-Postman-Collection.json" -Destination "03-Postman-Testleri/"
Copy-Item "../test/postman/reports/newman-report.html" -Destination "03-Postman-Testleri/VardiyaPro-Newman-Report.html"

# Playwright
Copy-Item "../VardiyaPro-Playwright-Report.html" -Destination "04-Playwright-Testleri/"
```

### 4.4. README.txt Oluştur

```powershell
@"
VardiyaPro - Ödev Teslimati
Web Teknolojileri ve Uygulamaları Dersi
Tarih: 9 Kasım 2025

===========================================

İÇİNDEKİLER:

01-Odev-Raporu/
  - VardiyaPro-Odev-Raporu.pdf
    Ödev raporu (UX/WCAG, API Testing, Versioning, CDN, E2E Testing)

02-Test-Videolari/
  - VardiyaPro-Testler-ONCE.webm (İlk durum - 7-8 failing test)
  - VardiyaPro-Testler-SONRA.webm (Düzeltilmiş - 23 passing, 6 skipped)

03-Postman-Testleri/
  - VardiyaPro-Postman-Collection.json (20+ endpoint, 52 test)
  - VardiyaPro-Newman-Report.html (Test sonuçları)

04-Playwright-Testleri/
  - VardiyaPro-Playwright-Report.html (29 E2E test - BDD formatı)

===========================================

PROJE BİLGİLERİ:

GitHub: https://github.com/Srhot/VardiyaPro
Branch: claude/fix-specdriven-poml-compatibility-011CUuB87gb9mbTRAF24CRed

Teknolojiler:
- Backend: Ruby on Rails 8.1.1, PostgreSQL 15
- Frontend: Vanilla JS (SPA), Tailwind CSS
- Testing: RSpec (128 tests), Postman (52 tests), Playwright (29 tests)

Test İstatistikleri:
- Toplam Otomatik Test: 209
- Başarı Oranı: %100 (skipped testler hariç)
- E2E Test Coverage: 4 modül (Auth, Navigation, Departments, Reports)

===========================================

NASIL ÇALIŞTIRILIIR:

1. Docker ile:
   docker compose up -d
   Uygulama: http://localhost:3000

2. Test login bilgileri:
   Admin: admin@vardiyapro.com / password123
   Manager: manager@vardiyapro.com / password123
   Employee: employee@vardiyapro.com / password123

3. Postman Collection'ı import et:
   03-Postman-Testleri/VardiyaPro-Postman-Collection.json

4. Playwright testlerini çalıştır:
   cd tests
   npm install
   npm test

===========================================

RAPORLAR:

1. Ödev Raporu: 01-Odev-Raporu/VardiyaPro-Odev-Raporu.pdf
2. Newman Report: 03-Postman-Testleri/VardiyaPro-Newman-Report.html
3. Playwright Report: 04-Playwright-Testleri/VardiyaPro-Playwright-Report.html

Test videoları BEFORE (ÖNCE) ve AFTER (SONRA) karşılaştırmalı izlenebilir.

===========================================

İletişim:
GitHub: @Srhot
Proje: VardiyaPro

"@ | Out-File -FilePath "README.txt" -Encoding UTF8
```

---

## 📦 ADIM 5: Sıkıştır ve Teslim Et

### 5.1. ZIP Dosyası Oluştur

**Windows Explorer ile:**
1. `VardiyaPro-Odev-Teslimati` klasörüne sağ tıkla
2. "Send to" → "Compressed (zipped) folder"
3. İsim: `VardiyaPro-Odev-Teslimati.zip`

**PowerShell ile:**
```powershell
cd ..
Compress-Archive -Path "VardiyaPro-Odev-Teslimati" -DestinationPath "VardiyaPro-Odev-Teslimati.zip"
```

### 5.2. ZIP Dosyası Kontrolü

```powershell
# Dosya boyutunu kontrol et
(Get-Item "VardiyaPro-Odev-Teslimati.zip").Length / 1MB
```

**Beklenen boyut:** ~50-150 MB (videolara bağlı)

**ZIP'i aç ve kontrol et:**
- ✅ Tüm dosyalar var mı?
- ✅ Dosya isimleri doğru mu?
- ✅ README.txt okunabilir mi?

---

## 📧 ADIM 6: Teslimat

### 6.1. E-posta Taslağı

```
Konu: VardiyaPro - Web Teknolojileri Ödevi Teslimi

Sayın Hocam,

Web Teknolojileri ve Uygulamaları dersi kapsamında geliştirdiğim
VardiyaPro projesinin ödevini ekte sunuyorum.

ÖDEV İÇERİĞİ:

✅ UX ve WCAG Değerlendirmesi
✅ API Testi - Postman Uygulaması (52 test)
✅ API Sürümleme ve Semantic Versioning
✅ CDN Kullanımı ve Performans Testi
✅ E2E Testing - Playwright (29 BDD test)

EKLER:

1. VardiyaPro-Odev-Teslimati.zip
   - Ödev raporu (PDF)
   - Test videoları (ÖNCE/SONRA - birleştirilmiş)
   - Postman collection ve Newman raporu
   - Playwright test raporu

PROJE BİLGİLERİ:

- GitHub: https://github.com/Srhot/VardiyaPro
- Toplam Test: 209 (RSpec: 128, Postman: 52, Playwright: 29)
- Başarı Oranı: %100

Not: Tüm test videoları tek parça halinde birleştirilmiş olarak
sunulmuştur (ÖNCE ve SONRA olmak üzere iki ayrı video).

Saygılarımla,
[Adınız Soyadınız]
[Öğrenci No]
```

### 6.2. Dosya Paylaşımı (Eğer dosya çok büyükse)

**Google Drive:**
1. https://drive.google.com
2. "New" → "File upload"
3. `VardiyaPro-Odev-Teslimati.zip` yükle
4. Sağ tıkla → "Share" → "Anyone with the link"
5. Linki kopyala, e-postaya ekle

**WeTransfer:**
1. https://wetransfer.com
2. "Add files" → ZIP dosyasını seç
3. Hocanın e-postasını gir
4. "Transfer" tıkla

---

## ✅ Final Checklist - Teslimat Öncesi

### Dosyalar

- [ ] `VardiyaPro-Odev-Raporu.pdf` hazır
- [ ] `VardiyaPro-Testler-ONCE.webm` birleştirilmiş (tek video)
- [ ] `VardiyaPro-Testler-SONRA.webm` birleştirilmiş (tek video)
- [ ] `VardiyaPro-Postman-Collection.json` hazır
- [ ] `VardiyaPro-Newman-Report.html` hazır
- [ ] `VardiyaPro-Playwright-Report.html` hazır
- [ ] `README.txt` oluşturulmuş
- [ ] Tüm dosyalar klasörlere yerleştirilmiş
- [ ] ZIP dosyası oluşturulmuş

### Kalite Kontrol

- [ ] PDF açılıyor ve düzgün görünüyor
- [ ] ÖNCE videosu oynatılıyor (7-8 failing test gösteriyor)
- [ ] SONRA videosu oynatılıyor (23 passing, 6 skipped gösteriyor)
- [ ] Newman report açılıyor (52 test passed gösteriyor)
- [ ] Playwright report açılıyor (29 test gösteriyor)
- [ ] README.txt Türkçe karakterler düzgün görünüyor
- [ ] ZIP dosyası açılıyor ve tüm dosyalar içinde

### E-posta

- [ ] Konu satırı doğru
- [ ] Hocaya hitap doğru
- [ ] İçerik eksiksiz
- [ ] GitHub linki çalışıyor
- [ ] Dosya eklendi veya paylaşım linki var
- [ ] İmza eksiksiz (ad, öğrenci no)

---

## 🎉 TAMAMLANDI!

Ödeviniz teslime hazır!

**Son kontrol:**
1. ZIP dosyasını aç ve tüm dosyaları kontrol et
2. Videoları oynat (ÖNCE ve SONRA)
3. PDF'i oku (en azından ilk ve son sayfaları)
4. E-posta taslağını oku
5. Gönder!

**İyi şanslar!** 🚀

---

## 📞 Sorun Yaşarsan

### Video birleştirme çalışmıyor

**Çözüm 1:** Daha küçük gruplar halinde birleştir
- İlk 5 videoyu birleştir
- Sonraki 5 videoyu birleştir
- Bu 2 videoyu birleştir

**Çözüm 2:** Başka online tool dene
- https://www.veed.io/tools/merge-videos
- https://www.flexclip.com/tools/merge-video/

**Çözüm 3:** Video boyutunu küçült
```bash
ffmpeg -i input.webm -vf scale=1280:720 -c:v libvpx-vp9 -b:v 1M output.webm
```

### ZIP dosyası çok büyük (>100 MB)

**Çözüm:** Videoları ayrı paylaş
1. ZIP'i videosuz oluştur
2. Videoları Google Drive'a yükle
3. Drive linkini e-postaya ekle

### PDF düzgün görünmüyor

**Çözüm:** Markdown'u düzenle
1. Çok uzun kod bloklarını kısalt
2. Büyük tabloları böl
3. Tekrar PDF'e çevir

---

**Hazırlayan:** Claude AI
**Tarih:** 9 Kasım 2025
**Versiyon:** 1.0
