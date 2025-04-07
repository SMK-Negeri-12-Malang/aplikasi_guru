class DataSiswa {
  static List<Map<String, dynamic>> getMockSiswa() {
    return [
      {
        'name': 'Ahmad Fauzan',
        'kelas': '7A',
        'level': 'SMP',
        'session': 'Sesi 1',
        'id': '1',
        'hafalan': {'surat': '', 'ayatAwal': '', 'ayatAkhir': '', 'baris': ''}
      },
      {
        'name': 'Muhammad Rizki',
        'kelas': '7A',
        'level': 'SMP',
        'session': 'Sesi 2',
        'id': '2',
      },
      {
        'name': 'Abdullah Zaki',
        'kelas': '8A',
        'level': 'SMP',
        'session': 'Sesi 1',
        'id': '3',
      },
      {
        'name': 'Umar Faruq',
        'kelas': '8A',
        'level': 'SMP',
        'session': 'Sesi 3',
        'id': '4',
      },
      {
        'name': 'Ali Imran',
        'kelas': '9A',
        'level': 'SMP',
        'session': 'Sesi 2',
        'id': '5',
      },
      {
        'name': 'Hassan Ahmad',
        'kelas': '10A',
        'level': 'SMK',
        'session': 'Sesi 1',
        'id': '6',
      },
      {
        'name': 'Ibrahim Yusuf',
        'kelas': '10A',
        'level': 'SMK',
        'session': 'Sesi 2',
        'id': '7',
      },
      {
        'name': 'Yahya Ismail',
        'kelas': '11A',
        'level': 'SMK',
        'session': 'Sesi 3',
        'id': '8',
      },
      {
        'name': 'Hamzah Abdul',
        'kelas': '11A',
        'level': 'SMK',
        'session': 'Sesi 1',
        'id': '9',
      },
      {
        'name': 'Muhammad Safwan',
        'kelas': '12A',
        'level': 'SMK',
        'session': 'Sesi 2',
        'id': '10',
      },
      {
        'name': 'Ahmad Ridwan',
        'kelas': '10A',
        'level': 'SMA',
        'session': 'Sesi 1',
        'id': '11',
      },
      {
        'name': 'Muhammad Hasan',
        'kelas': '10A',
        'level': 'SMA',
        'session': 'Sesi 2',
        'id': '12',
      },
      {
        'name': 'Zainul Abidin',
        'kelas': '11A',
        'level': 'SMA',
        'session': 'Sesi 1',
        'id': '13',
      },
      {
        'name': 'Abdul Rahman',
        'kelas': '11A',
        'level': 'SMA',
        'session': 'Sesi 3',
        'id': '14',
      },
      {
        'name': 'Fahmi Abdullah',
        'kelas': '12A',
        'level': 'SMA',
        'session': 'Sesi 2',
        'id': '15',
      },
    ]
        .map((student) => {
              ...student,
              'hafalan': student['hafalan'] ??
                  {'surat': '', 'ayatAwal': '', 'ayatAkhir': '', 'baris': ''}
            })
        .toList();
  }
}
