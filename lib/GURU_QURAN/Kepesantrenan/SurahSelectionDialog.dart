import 'package:flutter/material.dart';

class SurahSelectionDialog extends StatefulWidget {
  final Function(String) onSelect;

  const SurahSelectionDialog({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<SurahSelectionDialog> createState() => _SurahSelectionDialogState();
}

class _SurahSelectionDialogState extends State<SurahSelectionDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showAll = false;
  late TabController _tabController;
  
  // List data of surahs organized by juz
  final List<Map<String, dynamic>> _juzData = [
    {
      'juzNumber': 1,
      'surahs': [
        {'number': 1, 'name': 'Al-Fatihah', 'meaning': 'Pembukaan', 'ayahRange': '1-7'},
        {'number': 2, 'name': 'Al-Baqarah', 'meaning': 'Sapi Betina', 'ayahRange': '1-141'},
      ]
    },
    {
      'juzNumber': 2,
      'surahs': [
        {'number': 2, 'name': 'Al-Baqarah', 'meaning': 'Sapi Betina', 'ayahRange': '142-252'},
      ]
    },
    {
      'juzNumber': 3,
      'surahs': [
        {'number': 2, 'name': 'Al-Baqarah', 'meaning': 'Sapi Betina', 'ayahRange': '253-286'},
        {'number': 3, 'name': 'Ali \'Imran', 'meaning': 'Keluarga Imran', 'ayahRange': '1-92'},
      ]
    },
    {
      'juzNumber': 4,
      'surahs': [
        {'number': 3, 'name': 'Ali \'Imran', 'meaning': 'Keluarga Imran', 'ayahRange': '93-200'},
        {'number': 4, 'name': 'An-Nisa', 'meaning': 'Wanita', 'ayahRange': '1-23'},
      ]
    },
    {
      'juzNumber': 5,
      'surahs': [
        {'number': 4, 'name': 'An-Nisa', 'meaning': 'Wanita', 'ayahRange': '24-147'},
      ]
    },
    {
      'juzNumber': 6,
      'surahs': [
        {'number': 4, 'name': 'An-Nisa', 'meaning': 'Wanita', 'ayahRange': '148-176'},
        {'number': 5, 'name': 'Al-Ma\'idah', 'meaning': 'Hidangan', 'ayahRange': '1-81'},
      ]
    },
    {
      'juzNumber': 7,
      'surahs': [
        {'number': 5, 'name': 'Al-Ma\'idah', 'meaning': 'Hidangan', 'ayahRange': '82-120'},
        {'number': 6, 'name': 'Al-An\'am', 'meaning': 'Binatang Ternak', 'ayahRange': '1-110'},
      ]
    },
    {
      'juzNumber': 8,
      'surahs': [
        {'number': 6, 'name': 'Al-An\'am', 'meaning': 'Binatang Ternak', 'ayahRange': '111-165'},
        {'number': 7, 'name': 'Al-A\'raf', 'meaning': 'Tempat Tertinggi', 'ayahRange': '1-87'},
      ]
    },
    {
      'juzNumber': 9,
      'surahs': [
        {'number': 7, 'name': 'Al-A\'raf', 'meaning': 'Tempat Tertinggi', 'ayahRange': '88-206'},
        {'number': 8, 'name': 'Al-Anfal', 'meaning': 'Rampasan Perang', 'ayahRange': '1-40'},
      ]
    },
    {
      'juzNumber': 10,
      'surahs': [
        {'number': 8, 'name': 'Al-Anfal', 'meaning': 'Rampasan Perang', 'ayahRange': '41-75'},
        {'number': 9, 'name': 'At-Taubah', 'meaning': 'Pengampunan', 'ayahRange': '1-92'},
      ]
    },
    {
      'juzNumber': 11,
      'surahs': [
        {'number': 9, 'name': 'At-Taubah', 'meaning': 'Pengampunan', 'ayahRange': '93-129'},
        {'number': 10, 'name': 'Yunus', 'meaning': 'Yunus', 'ayahRange': '1-109'},
        {'number': 11, 'name': 'Hud', 'meaning': 'Hud', 'ayahRange': '1-5'},
      ]
    },
    {
      'juzNumber': 12,
      'surahs': [
        {'number': 11, 'name': 'Hud', 'meaning': 'Hud', 'ayahRange': '6-123'},
        {'number': 12, 'name': 'Yusuf', 'meaning': 'Yusuf', 'ayahRange': '1-52'},
      ]
    },
    {
      'juzNumber': 13,
      'surahs': [
        {'number': 12, 'name': 'Yusuf', 'meaning': 'Yusuf', 'ayahRange': '53-111'},
        {'number': 13, 'name': 'Ar-Ra\'d', 'meaning': 'Guruh', 'ayahRange': '1-43'},
        {'number': 14, 'name': 'Ibrahim', 'meaning': 'Ibrahim', 'ayahRange': '1-52'},
      ]
    },
    {
      'juzNumber': 14,
      'surahs': [
        {'number': 15, 'name': 'Al-Hijr', 'meaning': 'Hijr', 'ayahRange': '1-99'},
        {'number': 16, 'name': 'An-Nahl', 'meaning': 'Lebah', 'ayahRange': '1-128'},
      ]
    },
    {
      'juzNumber': 15,
      'surahs': [
        {'number': 17, 'name': 'Al-Isra\'', 'meaning': 'Perjalanan Malam', 'ayahRange': '1-111'},
        {'number': 18, 'name': 'Al-Kahf', 'meaning': 'Gua', 'ayahRange': '1-74'},
      ]
    },
    {
      'juzNumber': 16,
      'surahs': [
        {'number': 18, 'name': 'Al-Kahf', 'meaning': 'Gua', 'ayahRange': '75-110'},
        {'number': 19, 'name': 'Maryam', 'meaning': 'Maryam', 'ayahRange': '1-98'},
        {'number': 20, 'name': 'Ta Ha', 'meaning': 'Ta Ha', 'ayahRange': '1-135'},
      ]
    },
    {
      'juzNumber': 17,
      'surahs': [
        {'number': 21, 'name': 'Al-Anbiya', 'meaning': 'Para Nabi', 'ayahRange': '1-112'},
        {'number': 22, 'name': 'Al-Hajj', 'meaning': 'Haji', 'ayahRange': '1-78'},
      ]
    },
    {
      'juzNumber': 18,
      'surahs': [
        {'number': 23, 'name': 'Al-Mu\'minun', 'meaning': 'Orang-orang Mukmin', 'ayahRange': '1-118'},
        {'number': 24, 'name': 'An-Nur', 'meaning': 'Cahaya', 'ayahRange': '1-64'},
        {'number': 25, 'name': 'Al-Furqan', 'meaning': 'Pembeda', 'ayahRange': '1-20'},
      ]
    },
    {
      'juzNumber': 19,
      'surahs': [
        {'number': 25, 'name': 'Al-Furqan', 'meaning': 'Pembeda', 'ayahRange': '21-77'},
        {'number': 26, 'name': 'Asy-Syu\'ara', 'meaning': 'Para Penyair', 'ayahRange': '1-227'},
        {'number': 27, 'name': 'An-Naml', 'meaning': 'Semut', 'ayahRange': '1-55'},
      ]
    },
    {
      'juzNumber': 20,
      'surahs': [
        {'number': 27, 'name': 'An-Naml', 'meaning': 'Semut', 'ayahRange': '56-93'},
        {'number': 28, 'name': 'Al-Qasas', 'meaning': 'Kisah-kisah', 'ayahRange': '1-88'},
        {'number': 29, 'name': 'Al-\'Ankabut', 'meaning': 'Laba-laba', 'ayahRange': '1-45'},
      ]
    },
    {
      'juzNumber': 21,
      'surahs': [
        {'number': 29, 'name': 'Al-\'Ankabut', 'meaning': 'Laba-laba', 'ayahRange': '46-69'},
        {'number': 30, 'name': 'Ar-Rum', 'meaning': 'Bangsa Romawi', 'ayahRange': '1-60'},
        {'number': 31, 'name': 'Luqman', 'meaning': 'Luqman', 'ayahRange': '1-34'},
        {'number': 32, 'name': 'As-Sajdah', 'meaning': 'Sujud', 'ayahRange': '1-30'},
        {'number': 33, 'name': 'Al-Ahzab', 'meaning': 'Golongan-golongan yang Bersekutu', 'ayahRange': '1-30'},
      ]
    },
    {
      'juzNumber': 22,
      'surahs': [
        {'number': 33, 'name': 'Al-Ahzab', 'meaning': 'Golongan-golongan yang Bersekutu', 'ayahRange': '31-73'},
        {'number': 34, 'name': 'Saba\'', 'meaning': 'Saba\'', 'ayahRange': '1-54'},
        {'number': 35, 'name': 'Fatir', 'meaning': 'Pencipta', 'ayahRange': '1-45'},
        {'number': 36, 'name': 'Ya Sin', 'meaning': 'Ya Sin', 'ayahRange': '1-27'},
      ]
    },
    {
      'juzNumber': 23,
      'surahs': [
        {'number': 36, 'name': 'Ya Sin', 'meaning': 'Ya Sin', 'ayahRange': '28-83'},
        {'number': 37, 'name': 'As-Saffat', 'meaning': 'Barisan-barisan', 'ayahRange': '1-182'},
        {'number': 38, 'name': 'Sad', 'meaning': 'Sad', 'ayahRange': '1-88'},
        {'number': 39, 'name': 'Az-Zumar', 'meaning': 'Rombongan-rombongan', 'ayahRange': '1-31'},
      ]
    },
    {
      'juzNumber': 24,
      'surahs': [
        {'number': 39, 'name': 'Az-Zumar', 'meaning': 'Rombongan-rombongan', 'ayahRange': '32-75'},
        {'number': 40, 'name': 'Gafir', 'meaning': 'Yang Mengampuni', 'ayahRange': '1-85'},
        {'number': 41, 'name': 'Fussilat', 'meaning': 'Yang Dijelaskan', 'ayahRange': '1-46'},
      ]
    },
    {
      'juzNumber': 25,
      'surahs': [
        {'number': 41, 'name': 'Fussilat', 'meaning': 'Yang Dijelaskan', 'ayahRange': '47-54'},
        {'number': 42, 'name': 'Asy-Syura', 'meaning': 'Musyawarah', 'ayahRange': '1-53'},
        {'number': 43, 'name': 'Az-Zukhruf', 'meaning': 'Perhiasan', 'ayahRange': '1-89'},
        {'number': 44, 'name': 'Ad-Dukhan', 'meaning': 'Kabut', 'ayahRange': '1-59'},
        {'number': 45, 'name': 'Al-Jasiyah', 'meaning': 'Yang Berlutut', 'ayahRange': '1-37'},
      ]
    },
    {
      'juzNumber': 26,
      'surahs': [
        {'number': 46, 'name': 'Al-Ahqaf', 'meaning': 'Bukit-bukit Pasir', 'ayahRange': '1-35'},
        {'number': 47, 'name': 'Muhammad', 'meaning': 'Muhammad', 'ayahRange': '1-38'},
        {'number': 48, 'name': 'Al-Fath', 'meaning': 'Kemenangan', 'ayahRange': '1-29'},
        {'number': 49, 'name': 'Al-Hujurat', 'meaning': 'Kamar-kamar', 'ayahRange': '1-18'},
        {'number': 50, 'name': 'Qaf', 'meaning': 'Qaf', 'ayahRange': '1-45'},
        {'number': 51, 'name': 'Az-Zariyat', 'meaning': 'Angin yang Menerbangkan', 'ayahRange': '1-30'},
      ]
    },
    {
      'juzNumber': 27,
      'surahs': [
        {'number': 51, 'name': 'Az-Zariyat', 'meaning': 'Angin yang Menerbangkan', 'ayahRange': '31-60'},
        {'number': 52, 'name': 'At-Tur', 'meaning': 'Bukit', 'ayahRange': '1-49'},
        {'number': 53, 'name': 'An-Najm', 'meaning': 'Bintang', 'ayahRange': '1-62'},
        {'number': 54, 'name': 'Al-Qamar', 'meaning': 'Bulan', 'ayahRange': '1-55'},
        {'number': 55, 'name': 'Ar-Rahman', 'meaning': 'Yang Maha Pemurah', 'ayahRange': '1-78'},
        {'number': 56, 'name': 'Al-Waqi\'ah', 'meaning': 'Hari Kiamat', 'ayahRange': '1-96'},
        {'number': 57, 'name': 'Al-Hadid', 'meaning': 'Besi', 'ayahRange': '1-29'},
      ]
    },
    {
      'juzNumber': 28,
      'surahs': [
        {'number': 58, 'name': 'Al-Mujadilah', 'meaning': 'Wanita yang Mengajukan Gugatan', 'ayahRange': '1-22'},
        {'number': 59, 'name': 'Al-Hasyr', 'meaning': 'Pengusiran', 'ayahRange': '1-24'},
        {'number': 60, 'name': 'Al-Mumtahanah', 'meaning': 'Wanita yang Diuji', 'ayahRange': '1-13'},
        {'number': 61, 'name': 'As-Saff', 'meaning': 'Barisan', 'ayahRange': '1-14'},
        {'number': 62, 'name': 'Al-Jumu\'ah', 'meaning': 'Hari Jumat', 'ayahRange': '1-11'},
        {'number': 63, 'name': 'Al-Munafiqun', 'meaning': 'Orang-orang Munafik', 'ayahRange': '1-11'},
        {'number': 64, 'name': 'At-Tagabun', 'meaning': 'Hari Dinampakkan Kesalahan-kesalahan', 'ayahRange': '1-18'},
        {'number': 65, 'name': 'At-Talaq', 'meaning': 'Talak', 'ayahRange': '1-12'},
        {'number': 66, 'name': 'At-Tahrim', 'meaning': 'Mengharamkan', 'ayahRange': '1-12'},
      ]
    },
    {
      'juzNumber': 29,
      'surahs': [
        {'number': 67, 'name': 'Al-Mulk', 'meaning': 'Kerajaan', 'ayahRange': '1-30'},
        {'number': 68, 'name': 'Al-Qalam', 'meaning': 'Pena', 'ayahRange': '1-52'},
        {'number': 69, 'name': 'Al-Haqqah', 'meaning': 'Hari Kiamat', 'ayahRange': '1-52'},
        {'number': 70, 'name': 'Al-Ma\'arij', 'meaning': 'Tempat Naik', 'ayahRange': '1-44'},
        {'number': 71, 'name': 'Nuh', 'meaning': 'Nuh', 'ayahRange': '1-28'},
        {'number': 72, 'name': 'Al-Jinn', 'meaning': 'Jin', 'ayahRange': '1-28'},
        {'number': 73, 'name': 'Al-Muzzammil', 'meaning': 'Orang yang Berselimut', 'ayahRange': '1-20'},
        {'number': 74, 'name': 'Al-Muddassir', 'meaning': 'Orang yang Berkemul', 'ayahRange': '1-56'},
        {'number': 75, 'name': 'Al-Qiyamah', 'meaning': 'Hari Kiamat', 'ayahRange': '1-40'},
        {'number': 76, 'name': 'Al-Insan', 'meaning': 'Manusia', 'ayahRange': '1-31'},
        {'number': 77, 'name': 'Al-Mursalat', 'meaning': 'Malaikat-malaikat Yang Diutus', 'ayahRange': '1-50'},
      ]
    },
    {
      'juzNumber': 30,
      'surahs': [
        {'number': 78, 'name': 'An-Naba', 'meaning': 'Berita Besar', 'ayahRange': '1-40'},
        {'number': 79, 'name': 'An-Nazi\'at', 'meaning': 'Malaikat-malaikat Yang Mencabut', 'ayahRange': '1-46'},
        {'number': 80, 'name': '\'Abasa', 'meaning': 'Ia Bermuka Masam', 'ayahRange': '1-42'},
        {'number': 81, 'name': 'At-Takwir', 'meaning': 'Menggulung', 'ayahRange': '1-29'},
        {'number': 82, 'name': 'Al-Infitar', 'meaning': 'Terbelah', 'ayahRange': '1-19'},
        {'number': 83, 'name': 'Al-Mutaffifin', 'meaning': 'Orang-orang yang Curang', 'ayahRange': '1-36'},
        {'number': 84, 'name': 'Al-Insyiqaq', 'meaning': 'Terbelah', 'ayahRange': '1-25'},
        {'number': 85, 'name': 'Al-Buruj', 'meaning': 'Gugusan Bintang', 'ayahRange': '1-22'},
        {'number': 86, 'name': 'At-Tariq', 'meaning': 'Yang Datang di Malam Hari', 'ayahRange': '1-17'},
        {'number': 87, 'name': 'Al-A\'la', 'meaning': 'Yang Paling Tinggi', 'ayahRange': '1-19'},
        {'number': 88, 'name': 'Al-Gasyiyah', 'meaning': 'Hari Pembalasan', 'ayahRange': '1-26'},
        {'number': 89, 'name': 'Al-Fajr', 'meaning': 'Fajar', 'ayahRange': '1-30'},
        {'number': 90, 'name': 'Al-Balad', 'meaning': 'Negeri', 'ayahRange': '1-20'},
        {'number': 91, 'name': 'Asy-Syams', 'meaning': 'Matahari', 'ayahRange': '1-15'},
        {'number': 92, 'name': 'Al-Lail', 'meaning': 'Malam', 'ayahRange': '1-21'},
        {'number': 93, 'name': 'Ad-Duha', 'meaning': 'Waktu Duha', 'ayahRange': '1-11'},
        {'number': 94, 'name': 'Asy-Syarh', 'meaning': 'Melapangkan', 'ayahRange': '1-8'},
        {'number': 95, 'name': 'At-Tin', 'meaning': 'Buah Tin', 'ayahRange': '1-8'},
        {'number': 96, 'name': 'Al-\'Alaq', 'meaning': 'Segumpal Darah', 'ayahRange': '1-19'},
        {'number': 97, 'name': 'Al-Qadr', 'meaning': 'Kemuliaan', 'ayahRange': '1-5'},
        {'number': 98, 'name': 'Al-Bayyinah', 'meaning': 'Pembuktian', 'ayahRange': '1-8'},
        {'number': 99, 'name': 'Az-Zalzalah', 'meaning': 'Kegoncangan', 'ayahRange': '1-8'},
        {'number': 100, 'name': 'Al-\'Adiyat', 'meaning': 'Kuda Perang yang Berlari Kencang', 'ayahRange': '1-11'},
        {'number': 101, 'name': 'Al-Qari\'ah', 'meaning': 'Hari Kiamat', 'ayahRange': '1-11'},
        {'number': 102, 'name': 'At-Takasur', 'meaning': 'Bermegah-megahan', 'ayahRange': '1-8'},
        {'number': 103, 'name': 'Al-\'Asr', 'meaning': 'Masa', 'ayahRange': '1-3'},
        {'number': 104, 'name': 'Al-Humazah', 'meaning': 'Pengumpat', 'ayahRange': '1-9'},
        {'number': 105, 'name': 'Al-Fil', 'meaning': 'Gajah', 'ayahRange': '1-5'},
        {'number': 106, 'name': 'Quraisy', 'meaning': 'Suku Quraisy', 'ayahRange': '1-4'},
        {'number': 107, 'name': 'Al-Ma\'un', 'meaning': 'Barang-barang yang Berguna', 'ayahRange': '1-7'},
        {'number': 108, 'name': 'Al-Kausar', 'meaning': 'Nikmat yang Berlimpah', 'ayahRange': '1-3'},
        {'number': 109, 'name': 'Al-Kafirun', 'meaning': 'Orang-orang Kafir', 'ayahRange': '1-6'},
        {'number': 110, 'name': 'An-Nasr', 'meaning': 'Pertolongan', 'ayahRange': '1-3'},
        {'number': 111, 'name': 'Al-Lahab', 'meaning': 'Gejolak Api', 'ayahRange': '1-5'},
        {'number': 112, 'name': 'Al-Ikhlas', 'meaning': 'Keikhlasan', 'ayahRange': '1-4'},
        {'number': 113, 'name': 'Al-Falaq', 'meaning': 'Waktu Subuh', 'ayahRange': '1-5'},
        {'number': 114, 'name': 'An-Nas', 'meaning': 'Manusia', 'ayahRange': '1-6'},
      ]
    },
  ];

  // List of popular surahs to show initially
  final List<Map<String, dynamic>> _popularSurahs = [
    {'number': 1, 'name': 'Al-Fatihah', 'meaning': 'Pembukaan'},
    {'number': 2, 'name': 'Al-Baqarah', 'meaning': 'Sapi Betina'},
    {'number': 36, 'name': 'Ya Sin', 'meaning': 'Ya Sin'},
    {'number': 55, 'name': 'Ar-Rahman', 'meaning': 'Yang Maha Pemurah'},
    {'number': 56, 'name': 'Al-Waqi\'ah', 'meaning': 'Hari Kiamat'},
    {'number': 67, 'name': 'Al-Mulk', 'meaning': 'Kerajaan'},
    {'number': 112, 'name': 'Al-Ikhlas', 'meaning': 'Keikhlasan'},
    {'number': 113, 'name': 'Al-Falaq', 'meaning': 'Waktu Subuh'},
    {'number': 114, 'name': 'An-Nas', 'meaning': 'Manusia'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredSurahs() {
    if (_searchQuery.isEmpty) {
      return _popularSurahs;
    }
    
    // Search through all surahs across all juz
    List<Map<String, dynamic>> allSurahs = [];
    for (var juz in _juzData) {
      for (var surah in juz['surahs']) {
        // Check if this surah is already in the list (avoid duplicates)
        if (!allSurahs.any((s) => s['number'] == surah['number'])) {
          allSurahs.add(surah);
        }
      }
    }
    
    return allSurahs.where((surah) {
      final name = surah['name'].toString().toLowerCase();
      final number = surah['number'].toString();
      final meaning = surah['meaning'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || 
             number.contains(query) || 
             meaning.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF1D2842);
    final filteredSurahs = _getFilteredSurahs();
    final Size size = MediaQuery.of(context).size;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Surat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama surat atau nomor',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: primaryColor,
              tabs: const [
                Tab(text: 'Surat Populer'),
                Tab(text: 'Berdasarkan Juz'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Popular Surahs Tab
                  _searchQuery.isEmpty 
                    ? _buildPopularSurahsGrid()
                    : _buildSearchResults(filteredSurahs),
                  
                  // Juz Tab
                  _searchQuery.isEmpty 
                    ? _buildJuzList()
                    : _buildSearchResults(filteredSurahs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSurahsGrid() {
    final Color primaryColor = const Color(0xFF1D2842);
    
    return GridView.builder(
      padding: const EdgeInsets.only(top: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _popularSurahs.length,
      itemBuilder: (context, index) {
        final surah = _popularSurahs[index];
        
        return InkWell(
          onTap: () {
            widget.onSelect('${surah['number']}. ${surah['name']}');
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      surah['number'].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  surah['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  surah['meaning'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: _juzData.length,
      itemBuilder: (context, index) {
        final juz = _juzData[index];
        final juzNumber = juz['juzNumber'];
        final surahs = juz['surahs'] as List<Map<String, dynamic>>;
        
        return ExpansionTile(
          title: Text(
            'Juz $juzNumber',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Surat: ${surahs.map((s) => s['name']).join(', ')}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          children: surahs.map((surah) {
            return InkWell(
              onTap: () {
                widget.onSelect('${surah['number']}. ${surah['name']}');
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D2842).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            surah['number'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2842),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  surah['meaning'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1D2842).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Ayat ${surah['ayahRange']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF1D2842),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> surahs) {
    final Color primaryColor = const Color(0xFF1D2842);
    
    if (surahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Surat tidak ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        
        return InkWell(
          onTap: () {
            widget.onSelect('${surah['number']}. ${surah['name']}');
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        surah['number'].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surah['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          surah['meaning'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}