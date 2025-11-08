# VardiyaPro Postman Collection

Bu klasör VardiyaPro API'sini test etmek için Postman collection ve environment dosyalarını içerir.

## Dosyalar

- **VardiyaPro_API_Collection.json** - Tüm API endpoint'lerini içeren Postman collection
- **VardiyaPro_Environment_Dev.json** - Development environment değişkenleri

## Kurulum

### 1. Postman'i İndir

https://www.postman.com/downloads/ adresinden Postman'i indirin ve kurun.

### 2. Collection'ı Import Et

1. Postman'i açın
2. Sol üst köşedeki **Import** butonuna tıklayın
3. **VardiyaPro_API_Collection.json** dosyasını seçin
4. Import'a tıklayın

### 3. Environment'ı Import Et

1. Postman'de **Environments** sekmesine gidin
2. **Import** butonuna tıklayın
3. **VardiyaPro_Environment_Dev.json** dosyasını seçin
4. Import'a tıklayın

### 4. Environment'ı Aktif Et

1. Sağ üst köşedeki environment dropdown'ını açın
2. **VardiyaPro - Development** environment'ını seçin

## Kullanım

### Başlangıç Adımları

1. **Rails Server'ı Çalıştırın**
   ```bash
   bundle exec rails server
   # veya Docker ile:
   docker-compose up
   ```

2. **Login İsteği Gönderin**
   - Collection'da **Authentication > Login** isteğini açın
   - **Send** butonuna tıklayın
   - Token otomatik olarak environment variable'a kaydedilecek

3. **Diğer Endpoint'leri Test Edin**
   - Token artık environment'ta kayıtlı olduğu için authenticated endpoint'leri kullanabilirsiniz

### Test Kullanıcıları

Seed data ile oluşturulan test kullanıcıları:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@vardiyapro.com | password123 |
| Manager | manager@vardiyapro.com | password123 |
| Employee | employee1@vardiyapro.com | password123 |
| Employee | employee2@vardiyapro.com | password123 |

### Environment Variables

Collection otomatik olarak şu değişkenleri günceller:

- `token` - Login sonrası JWT token
- `user_id` - Login yapan kullanıcının ID'si
- `department_id` - İlk department'ın ID'si (List Departments'tan)
- `shift_id` - İlk shift'in ID'si (List Shifts'ten)
- `assignment_id` - İlk assignment'ın ID'si (List Assignments'tan)

## Collection Yapısı

### 1. Authentication
- **Login** - Admin/Manager/Employee olarak giriş
- Token otomatik olarak kaydedilir

### 2. Departments
- List Departments (search destekler: `?q=engineering`)
- Get Department
- Create Department (admin only)
- Update Department (admin only)

### 3. Shifts
- List Shifts
- Get Shift
- Create Shift (admin/manager)
- Update Shift (admin/manager)
- Delete Shift (admin only)
- **Filters:**
  - `?department_id=1` - Departmana göre
  - `?shift_type=morning` - Shift tipine göre
  - `?upcoming=true` - Gelecek shift'ler
  - `?available=true` - Boş slotu olan shift'ler
  - `?q=morning` - Arama

### 4. Assignments
- List Assignments
- Get Assignment
- Create Assignment
- Confirm Assignment
- Complete Assignment
- Cancel Assignment
- **Filters:**
  - `?employee_id=1` - Çalışana göre
  - `?status=confirmed` - Duruma göre

### 5. Users
- List Users (role-based access)
- Get User
- Create User (admin/hr only)
- Update User
- Update Password
- Activate/Deactivate User (admin/hr only)
- **Filters:**
  - `?q=john` - İsim/email arama
  - `?role=admin` - Role göre

### 6. Notifications
- List Notifications
- Unread Notifications (`?unread=true`)
- Mark as Read
- Mark All as Read

### 7. Reports
- Employee Report
- Department Report
- Overtime Report
- Summary Report (admin/hr only)

**Tüm raporlar date range destekler:**
```
?start_date=2025-01-01&end_date=2025-01-31
```

### 8. Audit Logs
- List Audit Logs (admin only)
- Filter by User
- Filter by Action
- Logs for Specific Record

## Test Senaryoları

### Senaryo 1: Yeni Shift Oluşturma ve Atama

1. **Login** (Admin olarak)
2. **List Departments** (department_id'yi al)
3. **Create Shift** (yeni shift oluştur)
4. **List Users** (employee seç)
5. **Create Assignment** (employee'yi shift'e ata)
6. **Confirm Assignment** (atamayı onayla)

### Senaryo 2: Overlap Validation Test (CRITICAL)

1. **Login** (Admin olarak)
2. **Create Shift** (08:00-16:00)
3. **Create Assignment** (Employee'yi ata)
4. **Create Shift** (12:00-20:00) - Overlapping
5. **Create Assignment** (Aynı employee'yi ata)
   - ❌ **HATA BEKLENİR:** "Employee is already assigned to an overlapping shift"

### Senaryo 3: Rapor Alma

1. **Login** (Admin/HR/Manager)
2. **Employee Report** (bir çalışanın raporu)
3. **Department Report** (departman raporu)
4. **Overtime Report** (fazla mesai raporu)

### Senaryo 4: Notification Sistemi

1. **Login** (Admin)
2. **Create Assignment** (bir employee'ye shift ata)
3. **Login** (O employee olarak)
4. **List Notifications** (yeni bildirim görünmeli)
5. **Mark as Read** (bildirimi oku)

## Pagination

List endpoint'leri pagination destekler:

```
?page=1&per_page=25
```

Response:
```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 5,
    "total_count": 120
  }
}
```

## Hata Kodları

| Status Code | Açıklama |
|------------|----------|
| 200 | OK - İşlem başarılı |
| 201 | Created - Kayıt oluşturuldu |
| 204 | No Content - Kayıt silindi |
| 400 | Bad Request - Geçersiz istek |
| 401 | Unauthorized - Token eksik/geçersiz |
| 403 | Forbidden - Yetki yok |
| 404 | Not Found - Kayıt bulunamadı |
| 422 | Unprocessable Entity - Validasyon hatası |
| 500 | Internal Server Error - Sunucu hatası |

## Authorization Rolleri

### Admin
- ✅ Tüm endpoint'lere erişim
- ✅ Kullanıcı oluşturma/düzenleme
- ✅ Shift oluşturma/silme
- ✅ Tüm raporları görüntüleme
- ✅ Audit log'ları görüntüleme

### HR (İnsan Kaynakları)
- ✅ Kullanıcı oluşturma/düzenleme
- ✅ Tüm kullanıcıları görüntüleme
- ✅ Tüm raporları görüntüleme
- ❌ Audit log'ları görüntüleme

### Manager
- ✅ Shift oluşturma/düzenleme
- ✅ Kendi departmanını görüntüleme
- ✅ Kendi departmanının raporları
- ❌ Tüm kullanıcıları görüntüleme

### Employee
- ✅ Kendi bilgilerini görüntüleme
- ✅ Kendi shift'lerini görüntüleme
- ✅ Kendi bildirimlerini görüntüleme
- ❌ Başkalarının verilerine erişim

## Önemli Notlar

1. **Token Geçerliliği:** JWT token'lar 24 saat geçerlidir
2. **Overlap Validation:** Bir çalışan aynı anda birden fazla shift'e atanamaz
3. **Shift Duration:** Shift'ler minimum 4, maksimum 12 saat olabilir
4. **Audit Logging:** User, Shift, Assignment değişiklikleri otomatik loglanır
5. **Notifications:** Shift atamaları otomatik bildirim oluşturur

## Sorun Giderme

### Token Hatası
```json
{
  "errors": ["Not Authenticated"]
}
```
**Çözüm:** Login isteğini tekrar gönderin ve token'ı güncelleyin.

### Forbidden Hatası
```json
{
  "errors": ["You are not authorized to perform this action"]
}
```
**Çözüm:** Doğru rol ile login olduğunuzdan emin olun (Admin/Manager/etc.)

### Validation Hatası
```json
{
  "errors": ["Email has already been taken"]
}
```
**Çözüm:** Request body'deki değerleri kontrol edin.

## İletişim

Sorularınız için: support@vardiyapro.com

---

**Son Güncelleme:** 2025-01-08
**Version:** 1.0.0
