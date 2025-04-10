import 'package:flutter/material.dart';

class SurahSelectionPage extends StatefulWidget {
  final Function(String) onSelect;

  const SurahSelectionPage({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<SurahSelectionPage> createState() => _SurahSelectionPageState();
}

class _SurahSelectionPageState extends State<SurahSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showAll = false;
  
  // List of common surahs (initially show only popular ones)
  final List<Map<String, dynamic>> _commonSurahs = [
    {'number': 1, 'name': 'Al-Fatihah', 'meaning': 'Pembukaan'},
    {'number': 2, 'name': 'Al-Baqarah', 'meaning': 'Sapi Betina'},
    {'number': 3, 'name': 'Ali \'Imran', 'meaning': 'Keluarga Imran'},
    {'number': 4, 'name': 'An-Nisa', 'meaning': 'Wanita'},
    {'number': 5, 'name': 'Al-Ma\'idah', 'meaning': 'Hidangan'},
    {'number': 12, 'name': 'Yusuf', 'meaning': 'Yusuf'},
    {'number': 18, 'name': 'Al-Kahf', 'meaning': 'Gua'},
    {'number': 19, 'name': 'Maryam', 'meaning': 'Maryam'},
    {'number': 36, 'name': 'Ya Sin', 'meaning': 'Ya Sin'},
    {'number': 55, 'name': 'Ar-Rahman', 'meaning': 'Yang Maha Pemurah'},
    {'number': 56, 'name': 'Al-Waqi\'ah', 'meaning': 'Hari Kiamat'},
    {'number': 67, 'name': 'Al-Mulk', 'meaning': 'Kerajaan'},
    {'number': 75, 'name': 'Al-Qiyamah', 'meaning': 'Hari Kiamat'},
    {'number': 78, 'name': 'An-Naba', 'meaning': 'Berita Besar'},
    {'number': 93, 'name': 'Ad-Duha', 'meaning': 'Waktu Duha'},
    {'number': 94, 'name': 'Ash-Sharh', 'meaning': 'Melapangkan'},
    {'number': 96, 'name': 'Al-\'Alaq', 'meaning': 'Segumpal Darah'},
    {'number': 97, 'name': 'Al-Qadr', 'meaning': 'Kemuliaan'},
    {'number': 112, 'name': 'Al-Ikhlas', 'meaning': 'Keikhlasan'},
    {'number': 113, 'name': 'Al-Falaq', 'meaning': 'Waktu Subuh'},
    {'number': 114, 'name': 'An-Nas', 'meaning': 'Manusia'},
  ];

  // Full list of all 114 surahs in the Quran
  final List<Map<String, dynamic>> _allSurahs = [
    {'number': 1, 'name': 'Al-Fatihah', 'meaning': 'Pembukaan'},
    {'number': 2, 'name': 'Al-Baqarah', 'meaning': 'Sapi Betina'},
    {'number': 3, 'name': 'Ali \'Imran', 'meaning': 'Keluarga Imran'},
    {'number': 4, 'name': 'An-Nisa', 'meaning': 'Wanita'},
    {'number': 5, 'name': 'Al-Ma\'idah', 'meaning': 'Hidangan'},
    {'number': 6, 'name': 'Al-An\'am', 'meaning': 'Binatang Ternak'},
    {'number': 7, 'name': 'Al-A\'raf', 'meaning': 'Tempat Tertinggi'},
    {'number': 8, 'name': 'Al-Anfal', 'meaning': 'Rampasan Perang'},
    {'number': 9, 'name': 'At-Taubah', 'meaning': 'Pengampunan'},
    {'number': 10, 'name': 'Yunus', 'meaning': 'Yunus'},
    {'number': 11, 'name': 'Hud', 'meaning': 'Hud'},
    {'number': 12, 'name': 'Yusuf', 'meaning': 'Yusuf'},
    {'number': 13, 'name': 'Ar-Ra\'d', 'meaning': 'Guruh'},
    {'number': 14, 'name': 'Ibrahim', 'meaning': 'Ibrahim'},
    {'number': 15, 'name': 'Al-Hijr', 'meaning': 'Hijr'},
    {'number': 16, 'name': 'An-Nahl', 'meaning': 'Lebah'},
    {'number': 17, 'name': 'Al-Isra\'', 'meaning': 'Perjalanan Malam'},
    {'number': 18, 'name': 'Al-Kahf', 'meaning': 'Gua'},
    {'number': 19, 'name': 'Maryam', 'meaning': 'Maryam'},
    {'number': 20, 'name': 'Ta Ha', 'meaning': 'Ta Ha'},
    {'number': 21, 'name': 'Al-Anbiya', 'meaning': 'Para Nabi'},
    {'number': 22, 'name': 'Al-Hajj', 'meaning': 'Haji'},
    {'number': 23, 'name': 'Al-Mu\'minun', 'meaning': 'Orang-orang Mukmin'},
    {'number': 24, 'name': 'An-Nur', 'meaning': 'Cahaya'},
    {'number': 25, 'name': 'Al-Furqan', 'meaning': 'Pembeda'},
    {'number': 26, 'name': 'Asy-Syu\'ara', 'meaning': 'Para Penyair'},
    {'number': 27, 'name': 'An-Naml', 'meaning': 'Semut'},
    {'number': 28, 'name': 'Al-Qasas', 'meaning': 'Kisah-kisah'},
    {'number': 29, 'name': 'Al-\'Ankabut', 'meaning': 'Laba-laba'},
    {'number': 30, 'name': 'Ar-Rum', 'meaning': 'Bangsa Romawi'},
    {'number': 31, 'name': 'Luqman', 'meaning': 'Luqman'},
    {'number': 32, 'name': 'As-Sajdah', 'meaning': 'Sujud'},
    {'number': 33, 'name': 'Al-Ahzab', 'meaning': 'Golongan-golongan yang Bersekutu'},
    {'number': 34, 'name': 'Saba\'', 'meaning': 'Saba\''},
    {'number': 35, 'name': 'Fatir', 'meaning': 'Pencipta'},
    {'number': 36, 'name': 'Ya Sin', 'meaning': 'Ya Sin'},
    {'number': 37, 'name': 'As-Saffat', 'meaning': 'Barisan-barisan'},
    {'number': 38, 'name': 'Sad', 'meaning': 'Sad'},
    {'number': 39, 'name': 'Az-Zumar', 'meaning': 'Rombongan-rombongan'},
    {'number': 40, 'name': 'Gafir', 'meaning': 'Yang Mengampuni'},
    {'number': 41, 'name': 'Fussilat', 'meaning': 'Yang Dijelaskan'},
    {'number': 42, 'name': 'Asy-Syura', 'meaning': 'Musyawarah'},
    {'number': 43, 'name': 'Az-Zukhruf', 'meaning': 'Perhiasan'},
    {'number': 44, 'name': 'Ad-Dukhan', 'meaning': 'Kabut'},
    {'number': 45, 'name': 'Al-Jasiyah', 'meaning': 'Yang Berlutut'},
    {'number': 46, 'name': 'Al-Ahqaf', 'meaning': 'Bukit-bukit Pasir'},
    {'number': 47, 'name': 'Muhammad', 'meaning': 'Muhammad'},
    {'number': 48, 'name': 'Al-Fath', 'meaning': 'Kemenangan'},
    {'number': 49, 'name': 'Al-Hujurat', 'meaning': 'Kamar-kamar'},
    {'number': 50, 'name': 'Qaf', 'meaning': 'Qaf'},
    {'number': 51, 'name': 'Az-Zariyat', 'meaning': 'Angin yang Menerbangkan'},
    {'number': 52, 'name': 'At-Tur', 'meaning': 'Bukit'},
    {'number': 53, 'name': 'An-Najm', 'meaning': 'Bintang'},
    {'number': 54, 'name': 'Al-Qamar', 'meaning': 'Bulan'},
    {'number': 55, 'name': 'Ar-Rahman', 'meaning': 'Yang Maha Pemurah'},
    {'number': 56, 'name': 'Al-Waqi\'ah', 'meaning': 'Hari Kiamat'},
    {'number': 57, 'name': 'Al-Hadid', 'meaning': 'Besi'},
    {'number': 58, 'name': 'Al-Mujadilah', 'meaning': 'Wanita yang Mengajukan Gugatan'},
    {'number': 59, 'name': 'Al-Hasyr', 'meaning': 'Pengusiran'},
    {'number': 60, 'name': 'Al-Mumtahanah', 'meaning': 'Wanita yang Diuji'},
    {'number': 61, 'name': 'As-Saff', 'meaning': 'Barisan'},
    {'number': 62, 'name': 'Al-Jumu\'ah', 'meaning': 'Hari Jumat'},
    {'number': 63, 'name': 'Al-Munafiqun', 'meaning': 'Orang-orang Munafik'},
    {'number': 64, 'name': 'At-Tagabun', 'meaning': 'Hari Dinampakkan Kesalahan-kesalahan'},
    {'number': 65, 'name': 'At-Talaq', 'meaning': 'Talak'},
    {'number': 66, 'name': 'At-Tahrim', 'meaning': 'Mengharamkan'},
    {'number': 67, 'name': 'Al-Mulk', 'meaning': 'Kerajaan'},
    {'number': 68, 'name': 'Al-Qalam', 'meaning': 'Pena'},
    {'number': 69, 'name': 'Al-Haqqah', 'meaning': 'Hari Kiamat'},
    {'number': 70, 'name': 'Al-Ma\'arij', 'meaning': 'Tempat Naik'},
    {'number': 71, 'name': 'Nuh', 'meaning': 'Nuh'},
    {'number': 72, 'name': 'Al-Jinn', 'meaning': 'Jin'},
    {'number': 73, 'name': 'Al-Muzzammil', 'meaning': 'Orang yang Berselimut'},
    {'number': 74, 'name': 'Al-Muddassir', 'meaning': 'Orang yang Berkemul'},
    {'number': 75, 'name': 'Al-Qiyamah', 'meaning': 'Hari Kiamat'},
    {'number': 76, 'name': 'Al-Insan', 'meaning': 'Manusia'},
    {'number': 77, 'name': 'Al-Mursalat', 'meaning': 'Malaikat-malaikat Yang Diutus'},
    {'number': 78, 'name': 'An-Naba', 'meaning': 'Berita Besar'},
    {'number': 79, 'name': 'An-Nazi\'at', 'meaning': 'Malaikat-malaikat Yang Mencabut'},
    {'number': 80, 'name': '\'Abasa', 'meaning': 'Ia Bermuka Masam'},
    {'number': 81, 'name': 'At-Takwir', 'meaning': 'Menggulung'},
    {'number': 82, 'name': 'Al-Infitar', 'meaning': 'Terbelah'},
    {'number': 83, 'name': 'Al-Mutaffifin', 'meaning': 'Orang-orang yang Curang'},
    {'number': 84, 'name': 'Al-Insyiqaq', 'meaning': 'Terbelah'},
    {'number': 85, 'name': 'Al-Buruj', 'meaning': 'Gugusan Bintang'},
    {'number': 86, 'name': 'At-Tariq', 'meaning': 'Yang Datang di Malam Hari'},
    {'number': 87, 'name': 'Al-A\'la', 'meaning': 'Yang Paling Tinggi'},
    {'number': 88, 'name': 'Al-Gasyiyah', 'meaning': 'Hari Pembalasan'},
    {'number': 89, 'name': 'Al-Fajr', 'meaning': 'Fajar'},
    {'number': 90, 'name': 'Al-Balad', 'meaning': 'Negeri'},
    {'number': 91, 'name': 'Asy-Syams', 'meaning': 'Matahari'},
    {'number': 92, 'name': 'Al-Lail', 'meaning': 'Malam'},
    {'number': 93, 'name': 'Ad-Duha', 'meaning': 'Waktu Duha'},
    {'number': 94, 'name': 'Asy-Syarh', 'meaning': 'Melapangkan'},
    {'number': 95, 'name': 'At-Tin', 'meaning': 'Buah Tin'},
    {'number': 96, 'name': 'Al-\'Alaq', 'meaning': 'Segumpal Darah'},
    {'number': 97, 'name': 'Al-Qadr', 'meaning': 'Kemuliaan'},
    {'number': 98, 'name': 'Al-Bayyinah', 'meaning': 'Pembuktian'},
    {'number': 99, 'name': 'Az-Zalzalah', 'meaning': 'Kegoncangan'},
    {'number': 100, 'name': 'Al-\'Adiyat', 'meaning': 'Kuda Perang yang Berlari Kencang'},
    {'number': 101, 'name': 'Al-Qari\'ah', 'meaning': 'Hari Kiamat'},
    {'number': 102, 'name': 'At-Takasur', 'meaning': 'Bermegah-megahan'},
    {'number': 103, 'name': 'Al-\'Asr', 'meaning': 'Masa'},
    {'number': 104, 'name': 'Al-Humazah', 'meaning': 'Pengumpat'},
    {'number': 105, 'name': 'Al-Fil', 'meaning': 'Gajah'},
    {'number': 106, 'name': 'Quraisy', 'meaning': 'Suku Quraisy'},
    {'number': 107, 'name': 'Al-Ma\'un', 'meaning': 'Barang-barang yang Berguna'},
    {'number': 108, 'name': 'Al-Kausar', 'meaning': 'Nikmat yang Berlimpah'},
    {'number': 109, 'name': 'Al-Kafirun', 'meaning': 'Orang-orang Kafir'},
    {'number': 110, 'name': 'An-Nasr', 'meaning': 'Pertolongan'},
    {'number': 111, 'name': 'Al-Lahab', 'meaning': 'Gejolak Api'},
    {'number': 112, 'name': 'Al-Ikhlas', 'meaning': 'Keikhlasan'},
    {'number': 113, 'name': 'Al-Falaq', 'meaning': 'Waktu Subuh'},
    {'number': 114, 'name': 'An-Nas', 'meaning': 'Manusia'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredSurahs() {
    final List<Map<String, dynamic>> surahs = _showAll ? _allSurahs : _commonSurahs;
    
    if (_searchQuery.isEmpty) {
      return surahs;
    }
    
    return surahs.where((surah) {
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
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Pilih Surat'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor.withOpacity(0.05),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama surat atau nomor',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSurahs.length + (_showAll ? 0 : 1),
              itemBuilder: (context, index) {
                // If we're showing the "View All" button
                if (!_showAll && index == filteredSurahs.length) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _showAll = true;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          'Lihat Semua Surat',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                // Regular surah item
                final surah = filteredSurahs[index];
                
                return InkWell(
                  onTap: () {
                    widget.onSelect('${surah['number']}. ${surah['name']}');
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surah['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  surah['meaning'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
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
            ),
          ),
        ],
      ),
    );
  }
}