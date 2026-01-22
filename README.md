# Jollaly – Aplikasi Catatan Digital (Flutter)

Jollaly adalah aplikasi catatan digital dengan autentikasi, manajemen catatan (buat, lihat, edit, hapus), favorit, arsip, pencarian, dark mode, dan dukungan multi-bahasa (Indonesia/Inggris). Aplikasi ini dibangun menggunakan Flutter dan berkomunikasi dengan backend RESTful API berbasis Node.js (Express + Prisma + PostgreSQL).

## Fitur Utama

- Autentikasi pengguna: Register, Login, Logout
- Manajemen catatan:
  - Daftar catatan dalam grid 2 kolom dengan judul, tanggal, dan cuplikan konten
  - Buat catatan baru
  - Detail catatan dan edit pada halaman yang sama
  - Hapus catatan (dari detail maupun pemilihan banyak)
- Favorit:
  - Tandai/lepaskan favorit dari kartu catatan
  - Filter daftar untuk menampilkan hanya favorit
- Arsip:
  - Arsipkan/batalkan arsip catatan
  - Catatan yang diarsip tidak tampil di daftar utama (kecuali filter arsip aktif)
- Pencarian langsung (live search) berdasarkan judul
- Seleksi banyak catatan via long press pada item dan aksi massal (arsipkan/batalkan arsip, hapus)
- Dark Mode: seluruh layar mendukung tema gelap
- Multi-bahasa: Indonesia dan Inggris, dapat diubah dari bar fitur
- Bar fitur global: tombol ubah bahasa dan toggle dark mode tersedia di Home, Login, Register, Create Note, dan Detail Note

## Teknologi yang Digunakan

- Flutter 3 (Dart SDK ^3.9.2)
- State management: Provider
- HTTP: package http
- Penyimpanan lokal: shared_preferences (token JWT, sesi)
- Fonts: Google Fonts (Nunito Sans)
- Internationalization: flutter_localizations + kontrol bahasa manual (ID/EN)
- Date formatting: intl
- Backend: Node.js + Express + Prisma (PostgreSQL) dengan JWT auth

## Struktur Proyek (Ringkas)

- lib/
  - main.dart: inisialisasi app, tema, localizations, routing, AuthGate
  - models/note.dart: model Note (id, title, content, userId, createdAt, updatedAt, isFavorite, isArchived)
  - services/
    - auth_service.dart: login, register, logout, simpan/muat sesi (JWT)
    - note_service.dart: CRUD catatan, filter, toggle favorit/arsip
  - providers/
    - auth_provider.dart: state autentikasi
    - notes_provider.dart: state daftar catatan, filter, seleksi, operasi massal
    - settings_provider.dart: theme mode (light/dark) dan locale (id/en)
  - screens/
    - login_screen.dart: UI login
    - register_screen.dart: UI register
    - home_screen.dart: daftar catatan, pencarian, filter, seleksi, FAB tambah
    - create_note_screen.dart: buat catatan
    - note_detail_screen.dart: lihat dan edit catatan, hapus
  - assets/
    - illustration.png: ilustrasi pada layar autentikasi

## Persiapan Backend

Pastikan backend Jollaly API berjalan pada http://localhost:3000 (dev). Dokumentasi ringkas:

- Base URL: http://localhost:3000
- Prefix API: /api
- Auth: JWT dengan header Authorization: Bearer <jwt>
- Skema Note menambahkan isFavorite (boolean) dan isArchived (boolean)
- Filter:
  - GET /api/notes?isFavorite=true|false&isArchived=true|false

Backend repositori dan pengaturan env tidak dibahas di sini, namun garis besar:

- Jalankan migrasi Prisma: npx prisma migrate dev --name init
- Jalankan server: npm run dev

## Konfigurasi Aplikasi Mobile

- Base URL otomatis berdasarkan platform:
  - Android emulator: http://10.0.2.2:3000
  - Web/Desktop: http://localhost:3000
- Jika menggunakan device fisik, ubah base URL di AuthService.baseUrl ke IP lokal mesin pengembang

## Instalasi dan Menjalankan

1. Pastikan Flutter SDK terpasang dan environment sudah siap
2. Install dependencies

- flutter pub get

3. Jalankan aplikasi

- flutter run

4. Pilih device (Android emulator/iOS simulator/web/desktop)

## Alur Penggunaan

- Register: masukkan Nama, Email, Password (≥ 6)
- Login: masukkan Email dan Password
- Setelah login, diarahkan ke Home (daftar catatan)
- Tambah: tekan tombol + (FAB), isi Judul/Konten, Simpan
- Detail/Edit: tap catatan, ubah judul/konten, simpan
- Favorit: tekan ikon bintang pada kartu
- Arsip: gunakan filter Arsip atau seleksi item dengan long press untuk arsip massal
- Pencarian: ketik judul pada kolom pencarian (live)
- Bahasa dan Mode: gunakan bar fitur (ikon globe dan mode terang/gelap)
- Logout: dari AppBar Home

## Detail Implementasi

- Autentikasi
  - Register: POST /api/auth/register
  - Login: POST /api/auth/login, menyimpan JWT di SharedPreferences
  - Logout: POST /api/auth/logout dan hapus sesi lokal
- Catatan
  - Daftar: GET /api/notes dengan opsi filter isFavorite/isArchived
  - Detail: GET /api/notes/:id
  - Buat: POST /api/notes dengan title dan content
  - Edit: PUT /api/notes/:id (title/content/isFavorite/isArchived)
  - Hapus: DELETE /api/notes/:id
- Header Authorization
  - Semua endpoint notes menggunakan Authorization: Bearer <token>

## Tema dan Font

- Warna utama: biru (#0A73FF)
- Font global: Nunito Sans (Google Fonts)
- Dark mode: UI menyesuaikan, termasuk warna kartu (abu-abu gelap), teks header putih

## Internationalization

- supportedLocales: id, en
- localizationsDelegates: GlobalMaterialLocalizations, GlobalWidgetsLocalizations, GlobalCupertinoLocalizations
- Pengaturan bahasa melalui SettingsProvider.setLocale dan bar fitur

## Catatan Pengembangan

- Linting: flutter_lints
- Struktur tema di main.dart: lightTheme, darkTheme, themeMode dari SettingsProvider
- Penyimpanan sesi: shared_preferences
- Perhatikan CORS dan konfigurasi cookie secure pada backend untuk produksi

## Troubleshooting

- flutter_localizations error: pastikan menambahkan flutter_localizations (sdk) dan versi intl kompatibel (0.20.2)
- Koneksi Android emulator ke localhost: gunakan 10.0.2.2:3000
- Token tidak terkirim: pastikan Authorization Bearer ditambahkan oleh NoteService
- Asset tidak muncul: pastikan lib/assets/illustration.png terdaftar di pubspec.yaml dan lakukan hot restart

### Kontribusi Anggota Kelompok

1. 5230411264 Maulana Rizal A
2. 5230411265 Agung Rizky 
3. 5230411271 Moh. Su'aidi
4. 5230411318 Fahmi Abdurrahman

## Lisensi

Proyek ini untuk pembelajaran/prototyping.
