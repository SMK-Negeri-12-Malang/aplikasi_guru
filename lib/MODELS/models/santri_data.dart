class Santri {
  final int id;
  final String name;
  final Map<String, double> progressByYear;
  final Map<String, String> lastUpdateByYear;
  
  Santri({
    required this.id, 
    required this.name,
    required this.progressByYear,
    required this.lastUpdateByYear,
  });

  bool? get isPresent => null;

  get kehadiran => null;

  get hafalan => null;
  
}

class SantriDataProvider {
  static final List<Santri> allSantri = [
    Santri(
      id: 1, 
      name: "Ahmad Rizky Nugraha",
      progressByYear: {
        '2022-2023': 0.92, '2023-2024': 0.88, '2024-2025': 0.78, '2025-2026': 0.45, '2026-2027': 0.25
      },
      lastUpdateByYear: {
        '2022-2023': '15/05/2023', '2023-2024': '22/05/2024', '2024-2025': '10/06/2025', '2025-2026': '05/04/2026', '2026-2027': '18/03/2027'
      }
    ),
    Santri(
      id: 2, 
      name: "Budi Santoso",
      progressByYear: {
        '2022-2023': 0.90, '2023-2024': 0.85, '2024-2025': 0.76, '2025-2026': 0.42, '2026-2027': 0.22
      },
      lastUpdateByYear: {
        '2022-2023': '14/05/2023', '2023-2024': '20/05/2024', '2024-2025': '11/06/2025', '2025-2026': '06/04/2026', '2026-2027': '19/03/2027'
      }
    ),
    Santri(
      id: 3, 
      name: "Citra Dewi Cahyani",
      progressByYear: {
        '2022-2023': 0.94, '2023-2024': 0.89, '2024-2025': 0.79, '2025-2026': 0.47, '2026-2027': 0.27
      },
      lastUpdateByYear: {
        '2022-2023': '16/05/2023', '2023-2024': '23/05/2024', '2024-2025': '12/06/2025', '2025-2026': '07/04/2026', '2026-2027': '20/03/2027'
      }
    ),
    Santri(
      id: 4, 
      name: "Dian Purnama Sari",
      progressByYear: {
        '2022-2023': 0.88, '2023-2024': 0.83, '2024-2025': 0.74, '2025-2026': 0.40, '2026-2027': 0.20
      },
      lastUpdateByYear: {
        '2022-2023': '17/05/2023', '2023-2024': '24/05/2024', '2024-2025': '13/06/2025', '2025-2026': '08/04/2026', '2026-2027': '21/03/2027'
      }
    ),
    Santri(
      id: 5, 
      name: "Eko Prabowo",
      progressByYear: {
        '2022-2023': 0.89, '2023-2024': 0.82, '2024-2025': 0.73, '2025-2026': 0.38, '2026-2027': 0.18
      },
      lastUpdateByYear: {
        '2022-2023': '18/05/2023', '2023-2024': '25/05/2024', '2024-2025': '14/06/2025', '2025-2026': '09/04/2026', '2026-2027': '22/03/2027'
      }
    ),
    Santri(
      id: 6, 
      name: "Fitriani Rahayu",
      progressByYear: {
        '2022-2023': 0.91, '2023-2024': 0.86, '2024-2025': 0.77, '2025-2026': 0.44, '2026-2027': 0.24
      },
      lastUpdateByYear: {
        '2022-2023': '19/05/2023', '2023-2024': '26/05/2024', '2024-2025': '15/06/2025', '2025-2026': '10/04/2026', '2026-2027': '23/03/2027'
      }
    ),
    Santri(
      id: 7, 
      name: "Gunawan Wibisono",
      progressByYear: {
        '2022-2023': 0.86, '2023-2024': 0.81, '2024-2025': 0.71, '2025-2026': 0.36, '2026-2027': 0.16
      },
      lastUpdateByYear: {
        '2022-2023': '20/05/2023', '2023-2024': '27/05/2024', '2024-2025': '16/06/2025', '2025-2026': '11/04/2026', '2026-2027': '24/03/2027'
      }
    ),
    Santri(
      id: 8, 
      name: "Hani Pertiwi",
      progressByYear: {
        '2022-2023': 0.93, '2023-2024': 0.87, '2024-2025': 0.75, '2025-2026': 0.43, '2026-2027': 0.23
      },
      lastUpdateByYear: {
        '2022-2023': '21/05/2023', '2023-2024': '28/05/2024', '2024-2025': '17/06/2025', '2025-2026': '12/04/2026', '2026-2027': '25/03/2027'
      }
    ),
    Santri(
      id: 9, 
      name: "Irfan Hakim",
      progressByYear: {
        '2022-2023': 0.95, '2023-2024': 0.90, '2024-2025': 0.80, '2025-2026': 0.48, '2026-2027': 0.28
      },
      lastUpdateByYear: {
        '2022-2023': '22/05/2023', '2023-2024': '29/05/2024', '2024-2025': '18/06/2025', '2025-2026': '13/04/2026', '2026-2027': '26/03/2027'
      }
    ),
    Santri(
      id: 10, 
      name: "Jihan Aulia",
      progressByYear: {
        '2022-2023': 0.87, '2023-2024': 0.84, '2024-2025': 0.72, '2025-2026': 0.39, '2026-2027': 0.19
      },
      lastUpdateByYear: {
        '2022-2023': '23/05/2023', '2023-2024': '30/05/2024', '2024-2025': '19/06/2025', '2025-2026': '14/04/2026', '2026-2027': '27/03/2027'
      }
    ),
    Santri(
      id: 11, 
      name: "Kurnia Rahman",
      progressByYear: {
        '2022-2023': 0.83, '2023-2024': 0.78, '2024-2025': 0.69, '2025-2026': 0.35, '2026-2027': 0.15
      },
      lastUpdateByYear: {
        '2022-2023': '24/05/2023', '2023-2024': '31/05/2024', '2024-2025': '20/06/2025', '2025-2026': '15/04/2026', '2026-2027': '28/03/2027'
      }
    ),
    Santri(
      id: 12, 
      name: "Laras Setyawati",
      progressByYear: {
        '2022-2023': 0.94, '2023-2024': 0.89, '2024-2025': 0.79, '2025-2026': 0.46, '2026-2027': 0.26
      },
      lastUpdateByYear: {
        '2022-2023': '25/05/2023', '2023-2024': '01/06/2024', '2024-2025': '21/06/2025', '2025-2026': '16/04/2026', '2026-2027': '29/03/2027'
      }
    ),
    Santri(
      id: 13, 
      name: "Muhammad Iqbal",
      progressByYear: {
        '2022-2023': 0.90, '2023-2024': 0.85, '2024-2025': 0.75, '2025-2026': 0.42, '2026-2027': 0.22
      },
      lastUpdateByYear: {
        '2022-2023': '26/05/2023', '2023-2024': '02/06/2024', '2024-2025': '22/06/2025', '2025-2026': '17/04/2026', '2026-2027': '30/03/2027'
      }
    ),
    Santri(
      id: 14, 
      name: "Nadia Putri",
      progressByYear: {
        '2022-2023': 0.92, '2023-2024': 0.87, '2024-2025': 0.77, '2025-2026': 0.44, '2026-2027': 0.24
      },
      lastUpdateByYear: {
        '2022-2023': '27/05/2023', '2023-2024': '03/06/2024', '2024-2025': '23/06/2025', '2025-2026': '18/04/2026', '2026-2027': '31/03/2027'
      }
    ),
    Santri(
      id: 15, 
      name: "Oscar Pranata",
      progressByYear: {
        '2022-2023': 0.85, '2023-2024': 0.80, '2024-2025': 0.70, '2025-2026': 0.37, '2026-2027': 0.17
      },
      lastUpdateByYear: {
        '2022-2023': '28/05/2023', '2023-2024': '04/06/2024', '2024-2025': '24/06/2025', '2025-2026': '19/04/2026', '2026-2027': '01/04/2027'
      }
    ),
    Santri(
      id: 16, 
      name: "Putri Anggraini",
      progressByYear: {
        '2022-2023': 0.93, '2023-2024': 0.88, '2024-2025': 0.78, '2025-2026': 0.45, '2026-2027': 0.25
      },
      lastUpdateByYear: {
        '2022-2023': '29/05/2023', '2023-2024': '05/06/2024', '2024-2025': '25/06/2025', '2025-2026': '20/04/2026', '2026-2027': '02/04/2027'
      }
    ),
    Santri(
      id: 17, 
      name: "Qori Mahmudah",
      progressByYear: {
        '2022-2023': 0.89, '2023-2024': 0.84, '2024-2025': 0.74, '2025-2026': 0.41, '2026-2027': 0.21
      },
      lastUpdateByYear: {
        '2022-2023': '30/05/2023', '2023-2024': '06/06/2024', '2024-2025': '26/06/2025', '2025-2026': '21/04/2026', '2026-2027': '03/04/2027'
      }
    ),
    Santri(
      id: 18, 
      name: "Ridwan Fauzi",
      progressByYear: {
        '2022-2023': 0.87, '2023-2024': 0.82, '2024-2025': 0.72, '2025-2026': 0.39, '2026-2027': 0.19
      },
      lastUpdateByYear: {
        '2022-2023': '31/05/2023', '2023-2024': '07/06/2024', '2024-2025': '27/06/2025', '2025-2026': '22/04/2026', '2026-2027': '04/04/2027'
      }
    ),
    Santri(
      id: 19, 
      name: "Sinta Dewi",
      progressByYear: {
        '2022-2023': 0.96, '2023-2024': 0.91, '2024-2025': 0.81, '2025-2026': 0.49, '2026-2027': 0.29
      },
      lastUpdateByYear: {
        '2022-2023': '01/06/2023', '2023-2024': '08/06/2024', '2024-2025': '28/06/2025', '2025-2026': '23/04/2026', '2026-2027': '05/04/2027'
      }
    ),
    Santri(
      id: 20, 
      name: "Taufik Hidayat",
      progressByYear: {
        '2022-2023': 0.84, '2023-2024': 0.79, '2024-2025': 0.69, '2025-2026': 0.36, '2026-2027': 0.16
      },
      lastUpdateByYear: {
        '2022-2023': '02/06/2023', '2023-2024': '09/06/2024', '2024-2025': '29/06/2025', '2025-2026': '24/04/2026', '2026-2027': '06/04/2027'
      }
    ),
    Santri(
      id: 21, 
      name: "Utami Wijayanti",
      progressByYear: {
        '2022-2023': 0.91, '2023-2024': 0.86, '2024-2025': 0.76, '2025-2026': 0.43, '2026-2027': 0.23
      },
      lastUpdateByYear: {
        '2022-2023': '03/06/2023', '2023-2024': '10/06/2024', '2024-2025': '30/06/2025', '2025-2026': '25/04/2026', '2026-2027': '07/04/2027'
      }
    ),
    Santri(
      id: 22, 
      name: "Vina Rosalina",
      progressByYear: {
        '2022-2023': 0.88, '2023-2024': 0.83, '2024-2025': 0.73, '2025-2026': 0.40, '2026-2027': 0.20
      },
      lastUpdateByYear: {
        '2022-2023': '04/06/2023', '2023-2024': '11/06/2024', '2024-2025': '01/07/2025', '2025-2026': '26/04/2026', '2026-2027': '08/04/2027'
      }
    ),
    Santri(
      id: 23, 
      name: "Wahyu Purnomo",
      progressByYear: {
        '2022-2023': 0.94, '2023-2024': 0.89, '2024-2025': 0.79, '2025-2026': 0.46, '2026-2027': 0.26
      },
      lastUpdateByYear: {
        '2022-2023': '05/06/2023', '2023-2024': '12/06/2024', '2024-2025': '02/07/2025', '2025-2026': '27/04/2026', '2026-2027': '09/04/2027'
      }
    ),
    Santri(
      id: 24, 
      name: "Xena Paramita",
      progressByYear: {
        '2022-2023': 0.90, '2023-2024': 0.85, '2024-2025': 0.75, '2025-2026': 0.42, '2026-2027': 0.22
      },
      lastUpdateByYear: {
        '2022-2023': '06/06/2023', '2023-2024': '13/06/2024', '2024-2025': '03/07/2025', '2025-2026': '28/04/2026', '2026-2027': '10/04/2027'
      }
    ),
    Santri(
      id: 25, 
      name: "Yusuf Maulana",
      progressByYear: {
        '2022-2023': 0.86, '2023-2024': 0.81, '2024-2025': 0.71, '2025-2026': 0.38, '2026-2027': 0.18
      },
      lastUpdateByYear: {
        '2022-2023': '07/06/2023', '2023-2024': '14/06/2024', '2024-2025': '04/07/2025', '2025-2026': '29/04/2026', '2026-2027': '11/04/2027'
      }
    ),
    Santri(
      id: 26, 
      name: "Zahra Puspita",
      progressByYear: {
        '2022-2023': 0.92, '2023-2024': 0.87, '2024-2025': 0.77, '2025-2026': 0.44, '2026-2027': 0.24
      },
      lastUpdateByYear: {
        '2022-2023': '08/06/2023', '2023-2024': '15/06/2024', '2024-2025': '05/07/2025', '2025-2026': '30/04/2026', '2026-2027': '12/04/2027'
      }
    ),
    Santri(
      id: 27, 
      name: "Anggoro Prasetyo",
      progressByYear: {
        '2022-2023': 0.89, '2023-2024': 0.84, '2024-2025': 0.74, '2025-2026': 0.41, '2026-2027': 0.21
      },
      lastUpdateByYear: {
        '2022-2023': '09/06/2023', '2023-2024': '16/06/2024', '2024-2025': '06/07/2025', '2025-2026': '01/05/2026', '2026-2027': '13/04/2027'
      }
    ),
    Santri(
      id: 28, 
      name: "Bayu Darmawan",
      progressByYear: {
        '2022-2023': 0.87, '2023-2024': 0.82, '2024-2025': 0.72, '2025-2026': 0.39, '2026-2027': 0.19
      },
      lastUpdateByYear: {
        '2022-2023': '10/06/2023', '2023-2024': '17/06/2024', '2024-2025': '07/07/2025', '2025-2026': '02/05/2026', '2026-2027': '14/04/2027'
      }
    ),
    Santri(
      id: 29, 
      name: "Candra Wijaya",
      progressByYear: {
        '2022-2023': 0.93, '2023-2024': 0.88, '2024-2025': 0.78, '2025-2026': 0.45, '2026-2027': 0.25
      },
      lastUpdateByYear: {
        '2022-2023': '11/06/2023', '2023-2024': '18/06/2024', '2024-2025': '08/07/2025', '2025-2026': '03/05/2026', '2026-2027': '15/04/2027'
      }
    ),
    Santri(
      id: 30, 
      name: "Dina Fitriani",
      progressByYear: {
        '2022-2023': 0.91, '2023-2024': 0.86, '2024-2025': 0.76, '2025-2026': 0.43, '2026-2027': 0.23
      },
      lastUpdateByYear: {
        '2022-2023': '12/06/2023', '2023-2024': '19/06/2024', '2024-2025': '09/07/2025', '2025-2026': '04/05/2026', '2026-2027': '16/04/2027'
      }
    ),
  ];
  
  static List<Santri> getSantriForYear(String academicYear) {
    return allSantri;
  }
  
  static double getAverageProgress(String academicYear, String category) {
    if (category == 'Hafalan') {
      double total = 0;
      for (var santri in allSantri) {
        total += santri.progressByYear[academicYear] ?? 0;
      }
      return total / allSantri.length;
    } else {
      // Simulate different progress values for Kehadiran
      double total = 0;
      for (var santri in allSantri) {
        // Adjust values to create variety between Hafalan and Kehadiran
        double hafalanProgress = santri.progressByYear[academicYear] ?? 0;
        double kehadiranProgress = hafalanProgress * 0.9 + 0.1; // Different but related value
        if (kehadiranProgress > 1) kehadiranProgress = 1;
        total += kehadiranProgress;
      }
      return total / allSantri.length;
    }
  }
}
