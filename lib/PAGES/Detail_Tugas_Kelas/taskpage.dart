import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:aplikasi_ortu/PAGES/Detail_Tugas_Kelas/task_detail_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

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

  final List<String> kelasList = ['Tugas', 'Kamar B', 'Kamar C', 'Kamar D'];
  final Map<String, List<Map<String, dynamic>>> siswaData = {
    'Tugas': [], // Empty list initially
    'Kamar B': [],
    'Kamar C': [],
    'Kamar D': [],
  };

  String? selectedClass;
  int checkedCount = 0;
  int? selectedIndex;
  final ImagePicker _picker = ImagePicker();

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    searchController.dispose();
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
      }
    });
  }


  void _addNewTask() {
    if (selectedClass != null) {
      File? selectedImage;
      PlatformFile? selectedFile;
      
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
                        height: 70, // Reduced height from 100
                        width: double.infinity, // Ensure full width
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
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
                                color: Colors.grey,
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
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Deadline',
                          hintText: 'YYYY-MM-DD',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) => deadline = value,
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
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 22),
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
            SizedBox(height: 20),
            Container(
              height: 120,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: kelasList.length,
                itemBuilder: (context, index) {
                  String kelas = kelasList[index];
                  bool isSelected = selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        selectedClass = kelas;
                        selectedIndex = index;
                        checkedCount = siswaData[selectedClass]!
                            .where((siswa) => siswa['checked'])
                            .length;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: MediaQuery.of(context).size.width * 0.7,
                      margin:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.shade100,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ]
                            : [],
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade300
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.class_,
                                color: isSelected
                                    ? Colors.blue.shade900
                                    : Colors.blue.shade300,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                kelas,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.blue.shade900
                                      : Colors.blue.shade300,
                                ),
                              ),
                            ],
                          ),
                          if (selectedClass == kelas) ...[
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                checkedCount ==
                                        (siswaData[selectedClass]?.length ??
                                            0)
                                    ? 'Selesai Semua ✓'
                                    : 'Selesai: $checkedCount',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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