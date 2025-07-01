class DataSantri {
  static List<Map<String, dynamic>> getMockSantri() {
    return [
      {
        'id': 'S001',
        'nama': 'Ahmad Fauzi',
        'jalan': 'Jl. Merdeka No. 10',
        'rt_rw': '01/05',
        'kota': 'Malang',
        'telepon': '081234567890',
        'ayah': 'H. Abdullah',
        'telepon_ayah': '081298765432',
        'ibu': 'Ibu Siti',
        'telepon_ibu': '081212345678',
        'wali': 'Pak Umar',
        'telepon_wali': '085612345678',
        'nis': 'NIS202301',
        'ruang_kelas': '7A',
        'halaqoh': 'Halaqoh A',
        'tahfidz_terakhir': 'Al-Baqarah 2:50',
        'virtual_account': '1234567890',
        'va_uang_saku': '0987654321',
        'data_tahfidz': [
          {
            'tanggal': '2025-06-30',
            'sesi': 'Sesi 1',
            'surat': 'Al-Baqarah',
            'ayat_awal': 1,
            'ayat_akhir': 5,
            'jumlah_baris': 10,
            'nilai': 95,
            'ustadz': 'Ust. Rahmat',
            'status': 'Lulus'
          },
          {
            'tanggal': '2025-06-28',
            'sesi': 'Sesi 1',
            'surat': 'Al-Fatihah',
            'ayat_awal': 1,
            'ayat_akhir': 7,
            'jumlah_baris': 7,
            'nilai': 90,
            'ustadz': 'Ust. Rahmat',
            'status': 'Lulus'
          },
        ]
      },
      // Tambah data santri lainnya di sini
    ];
  }
}

class DataSiswa {
  static List<Map<String, dynamic>> getMockSiswa() {
    return [
      {
        'id': 1,
        'name': 'Ahmad Fauzi',
        'kelas': '7A',
        'room': 'Ruang 1',
        'halaqoh': 'Halaqoh 1',
        'penanggungJawab': 'Ustadz Ali',
        'jalan': 'Jl. Merpati No. 1',
        'rtrw': '001/002',
        'kota': 'Bandung',
        'telepon': '081234567890',
        'namaAyah': 'Bapak Fauzi',
        'teleponAyah': '081234567891',
        'namaIbu': 'Ibu Siti',
        'teleponIbu': '081234567892',
        'namaWali': 'Pak Wali',
        'teleponWali': '081234567893',
        'tahfidzTerakhir': 'Al-Baqarah: 10',
        'virtualAccount': '1234567890',
        'vaUangSaku': '0987654321',
        'dataTahfidz': [
          {
            'tanggal': '2024-06-01',
            'sesi': '1',
            'surat': 'Al-Baqarah',
            'ayatAwal': '1',
            'ayatAkhir': '10',
            'jumlahBaris': 10,
            'nilai': 'Mumtaz',
            'ustadz': 'Ustadz Ali',
            'status': 'Lulus',
          },
        ],
      },
      // ...tambahkan data siswa lain sesuai kebutuhan...
    ];
  }
}
