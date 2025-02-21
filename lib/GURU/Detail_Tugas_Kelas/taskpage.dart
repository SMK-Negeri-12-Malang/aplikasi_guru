import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:aplikasi_ortu/GURU/Detail_Tugas_Kelas/task_detail_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:aplikasi_ortu/utils/task_storage.dart';

class tugaskelas extends StatefulWidget {
  final Function(Map<String, dynamic>, String)? onTaskAdded;  // Add this line

  const tugaskelas({
    Key? key,
    this.onTaskAdded,  // Add this line
  }) : super(key: key);

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<tugaskelas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> kelasList = ['Tugas', 'Ujian'];
  final Map<String, List<Map<String, dynamic>>> siswaData = {
    'Tugas': [], // Empty list initially
    'Ujian': [],
  };

  String? selectedClass;
  int checkedCount = 0;
  int? selectedIndex;

  // Add new controller for search
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  // Add search functionality
  List<Map<String, dynamic>> _getFilteredTasks() {
    if (!isSearching || searchController.text.isEmpty) {
      return siswaData[selectedClass] ?? [];
    }
    return (siswaData[selectedClass] ?? []).where((task) {
      return task['name'].toLowerCase().contains(searchController.text.toLowerCase());
    }).toList();
  }

  // Add this controller
  late PageController _categoryPageController;
  int _currentCategoryPage = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedTasks();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _categoryPageController = PageController(viewportFraction: 0.85); // Changed viewportFraction
  }

  Future<void> _loadSavedTasks() async {
    final savedTasks = await TaskStorage.loadTasks();
    setState(() {
      siswaData.addAll(savedTasks);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    searchController.dispose();
    _categoryPageController.dispose();
    super.dispose();
  }

  void _toggleCheck(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      if (selectedClass != null) {
        siswaData[selectedClass]![index]['checked'] =
            !siswaData[selectedClass]![index]['checked'];
        checkedCount = siswaData[selectedClass]!
            .where((siswa) => siswa['checked'])
            .length;
        
        // Save tasks after toggling check
        TaskStorage.saveTasks(siswaData);
      }
    });
  }


void _addNewTask() {
  if (selectedClass != null) {
    File? selectedImage;
    PlatformFile? selectedFile;
    DateTime? selectedDate;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String taskName = '';
        String deadline = '';
        String description = '';
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Tambah Tugas Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color.fromARGB(255, 247, 244, 244)),
                      ),
                      child: InkWell(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if (result != null) {
                            setState(() {
                              selectedFile = result.files.first;
                              selectedImage = null;
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedFile != null 
                                  ? Icons.file_present
                                  : Icons.upload_file,
                              size: 30,
                              color: const Color.fromARGB(255, 155, 153, 153),
                            ),
                            SizedBox(width: 12),
                            Text(
                              selectedFile != null
                                  ? (selectedFile!.name.length > 20
                                      ? '${selectedFile!.name.substring(0, 20)}...'
                                      : selectedFile!.name)
                                  : 'Tambah File',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nama Tugas',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) => taskName = value,
                    ),
                    SizedBox(height: 10),
                    // Replace TextField with DatePicker button
                    InkWell(
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Colors.blue,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() {
                            selectedDate = date;
                            deadline = DateFormat('yyyy-MM-dd').format(date);
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              deadline.isEmpty
                                  ? 'Pilih Deadline'
                                  : 'Deadline: $deadline',
                              style: TextStyle(
                                fontSize: 16,
                                color: deadline.isEmpty
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      maxLines: 3,
                      onChanged: (value) => description = value,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (taskName.isNotEmpty && deadline.isNotEmpty) {
                      this.setState(() {
                        siswaData[selectedClass]!.add({
                          'name': taskName,
                          'deadline': deadline,
                          'description': description,
                          'checked': false,
                          'image': selectedImage,
                          'file': selectedFile,
                          'absen': (siswaData[selectedClass]!.length + 1).toString().padLeft(2, '0'),
                        });
                      });

                      // Save tasks after adding new task
                      TaskStorage.saveTasks(siswaData);

                      // After adding the task to siswaData, notify parent
                      if (widget.onTaskAdded != null) {
                        widget.onTaskAdded!(
                          {
                            'name': taskName,
                            'deadline': deadline,
                            'description': description,
                            'checked': false,
                            'image': selectedImage,
                            'file': selectedFile,
                          },
                          selectedClass!,
                        );
                      }

                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tugas baru berhasil ditambahkan'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

  void _onTaskUpdated(Map<String, dynamic> updatedTask) {
    setState(() {
      final taskList = siswaData[selectedClass]!;
      final index = taskList.indexWhere((task) => task['absen'] == updatedTask['absen']);
      if (index != -1) {
        taskList[index] = updatedTask;
        
        // Save tasks after updating
        TaskStorage.saveTasks(siswaData);
      }
    });
  }

  Widget _buildTaskList() {
    final filteredTasks = _getFilteredTasks();
    
    if (filteredTasks.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 70,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16),
              Text(
                isSearching ? 'Tidak ada tugas yang ditemukan' : 'Belum ada tugas',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tekan tombol + untuk menambahkan tugas',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          var task = filteredTasks[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: task['checked']
                  ? Colors.blue.shade50
                  : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailPage(
                      task: task,
                      className: selectedClass!,
                      onTaskUpdated: _onTaskUpdated,
                    ),
                  ),
                );
              },
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: task['checked'] ? Colors.blue.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: task['checked'] ? Colors.blue.shade900 : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              title: Text(
                task['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: task['checked'] ? Colors.blue.shade900 : Colors.black87,
                ),
              ),
              subtitle: Text(
                'Deadline: ${task['deadline']}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task['checked'],
                  onChanged: (value) => _toggleCheck(index),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: Colors.blue.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 180, // Reduced height
      margin: EdgeInsets.only(top: 0), // Added top margin to reduce space
      padding: EdgeInsets.only(left: 15), // Added left padding
      child: Row(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _categoryPageController,
              scrollDirection: Axis.vertical,
              itemCount: kelasList.length,
              onPageChanged: (index) {
                setState(() {
                  _currentCategoryPage = index;
                  selectedClass = kelasList[index];
                  selectedIndex = index;
                  checkedCount = siswaData[selectedClass]!
                      .where((siswa) => siswa['checked'])
                      .length;
                });
              },
              itemBuilder: (context, index) {
                String kelas = kelasList[index];
                bool isSelected = selectedIndex == index;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5), // Reduced from 5
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15), // Reduced from 20
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withOpacity(0.5),
                        blurRadius: 8, // Reduced from 10
                        offset: Offset(0, 4), // Reduced from 5
                      ),
                    ],
                    border: Border.all(
                      color: isSelected ? const Color.fromARGB(255, 11, 83, 143) : Colors.transparent,
                      width: 1.5, // Reduced from 2
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3), // Reduced from 4
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue.shade50 : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.assignment,
                                color: isSelected ? Colors.blue.shade900 : Colors.blue.shade300,
                                size: 28, // Reduced from 35
                              ),
                            ),
                            SizedBox(height: 8), // Reduced from 12
                            Text(
                              kelas,
                              style: TextStyle(
                                fontSize: 18, // Reduced from 22
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.blue.shade900 : Colors.blue.shade300,
                              ),
                            ),
                            if (selectedClass == kelas)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3), // Reduced padding
                                margin: EdgeInsets.only(top: 4), // Reduced from 5
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  checkedCount == (siswaData[selectedClass]?.length ?? 0)
                                      ? 'Selesai Semua ✓'
                                      : 'Selesai: $checkedCount',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 11, // Reduced from 13
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Dot indicators
          Container(
            width: 16,
            padding: EdgeInsets.symmetric(vertical: 8),
            margin: EdgeInsets.only(right: 16), // Added right margin
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                kelasList.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentCategoryPage == index
                        ? Colors.blue.shade700
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FadeTransition(
        opacity: _animation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 22), // Reduced vertical padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade900.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              'Tugas Kelas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            isSearching ? Icons.close : Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              isSearching = !isSearching;
                              if (!isSearching) {
                                searchController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (isSearching) ...[
                      SizedBox(height: 10),
                      TextField(
                        controller: searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari tugas...',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ] else ...[
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 10), // Reduced spacing from 20 to 10
            _buildCategorySelector(),
            SizedBox(height: 20),
            if (selectedClass != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Tugas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_task, color: Colors.blue.shade600),
                      onPressed: _addNewTask, // Use the new function here
                    ),
                  ],
                ),
              ),
              _buildTaskList(), // Replace the existing Expanded ListView.builder with this
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.class_outlined,
                        size: 50,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Pilih tugas terlebih dahulu',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}