import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:aplikasi_guru/GURU/Tugas/task_detail_page.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:aplikasi_guru/ANIMASI/task_storage.dart';
import '../../SERVICE/task_manager_service.dart';
import 'package:aplikasi_guru/SERVICE/notification_service.dart';

class tugaskelas extends StatefulWidget {
  final Function(Map<String, dynamic>, String)? onTaskAdded;
  final String className;

  const tugaskelas({
    Key? key,
    this.onTaskAdded,
    required this.className,
  }) : super(key: key);

  @override
  _AbsensiKelasPageState createState() => _AbsensiKelasPageState();
}

class _AbsensiKelasPageState extends State<tugaskelas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> kelasList = ['Tugas', 'Ujian'];
  final TaskManagerService _taskManager = TaskManagerService();
  final NotificationService _notificationService = NotificationService();
  Map<String, List<Map<String, dynamic>>> siswaData = {};

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
    // Initialize siswaData with empty lists for each category
    for (var type in kelasList) {
      siswaData[type] = [];
    }
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
    
    // Initialize with first task selected
    selectedClass = kelasList[0];
    selectedIndex = 0;
    _currentCategoryPage = 0;
    _categoryPageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );
    
    // Set initial checkedCount
    Future.delayed(Duration.zero, () {
      setState(() {
        if (selectedClass != null) {
          checkedCount = siswaData[selectedClass]!
              .where((siswa) => siswa['checked'])
              .length;
        }
      });
    });
  }

  Future<void> _loadSavedTasks() async {
    try {
      final tasks = await _taskManager.getTasksForClass(widget.className);
      
      setState(() {
        // Group tasks by type
        for (var type in kelasList) {
          siswaData[type] = tasks.where((task) => 
            task['type'] == type && task['className'] == widget.className
          ).toList();
        }
        
        // Update checkedCount for current category
        if (selectedClass != null) {
          checkedCount = siswaData[selectedClass]!
              .where((task) => task['checked'])
              .length;
        }
      });
    } catch (e) {
      print('Error loading tasks: $e');
      // Initialize with empty lists if loading fails
      for (var type in kelasList) {
        if (siswaData[type] == null) {
          siswaData[type] = [];
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    searchController.dispose();
    _categoryPageController.dispose();
    super.dispose();
  }

  void _toggleCheck(int index) async {
    HapticFeedback.lightImpact();
    if (selectedClass != null) {
      final task = siswaData[selectedClass]![index];
      final newCheckedState = !task['checked'];
      
      try {
        // Update local state
        setState(() {
          task['checked'] = newCheckedState;
          checkedCount = siswaData[selectedClass]!
              .where((siswa) => siswa['checked'])
              .length;
        });

        // Save to service
        await _taskManager.updateTask(
          widget.className,
          task['id'],
          {'checked': newCheckedState}
        );

        // Update notification
        await _notificationService.updateNotification(
          task['id'],
          {'isCompleted': newCheckedState}
        );

        // Save to local storage
        await TaskStorage.saveTasks(siswaData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newCheckedState ? 'Tugas ditandai selesai' : 'Tugas ditandai belum selesai'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: newCheckedState ? Colors.green : Colors.blue,
          ),
        );
      } catch (e) {
        print('Error saving task state: $e');
        // Revert the change if saving failed
        setState(() {
          task['checked'] = !newCheckedState;
          checkedCount = siswaData[selectedClass]!
              .where((siswa) => siswa['checked'])
              .length;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan perubahan'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }


void _addNewTask() async {
  if (selectedClass == null) return;

  File? selectedImage;
  PlatformFile? selectedFile;
  DateTime? selectedDate;
  DateTime? selectedAssignmentDate;
  String assignmentDate = '';
  String selectedMapel = '';
  final List<String> mapelList = [
    'Matematika', 'Bahasa Indonesia', 'Bahasa Inggris', 'IPA', 'IPS', 'PPKN', 'Agama', 'Seni', 'PJOK', 'Lainnya'
  ];

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
                  // 1. Mata Pelajaran
                  DropdownButtonFormField<String>(
                    value: selectedMapel.isNotEmpty ? selectedMapel : null,
                    items: mapelList.map((mapel) {
                      return DropdownMenuItem(
                        value: mapel,
                        child: Text(mapel),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Mata Pelajaran',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedMapel = value ?? '';
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  // 2. Nama Tugas
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
                  // 3. Tanggal Penugasan
                  InkWell(
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: selectedAssignmentDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: const Color.fromARGB(255, 13, 90, 153),
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
                          selectedAssignmentDate = date;
                          assignmentDate = DateFormat('yyyy-MM-dd').format(date);
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
                          Icon(Icons.event_note, color: const Color.fromARGB(255, 17, 86, 143)),
                          SizedBox(width: 10),
                          Text(
                            assignmentDate.isEmpty
                                ? 'Pilih Tanggal Penugasan'
                                : 'Penugasan: $assignmentDate',
                            style: TextStyle(
                              fontSize: 16,
                              color: assignmentDate.isEmpty ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // 4. Deadline
                  InkWell(
                    onTap: () async {
                      final DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: const Color.fromARGB(255, 13, 80, 134),
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
                          Icon(Icons.calendar_today, color: const Color.fromARGB(255, 16, 72, 129)),
                          SizedBox(width: 10),
                          Text(
                            deadline.isEmpty
                                ? 'Pilih Deadline'
                                : 'Deadline: $deadline',
                            style: TextStyle(
                              fontSize: 16,
                              color: deadline.isEmpty ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // 5. File
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
                  // 6. Deskripsi
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
                onPressed: () async {
                  // Validasi field baru
                  if (taskName.isNotEmpty && deadline.isNotEmpty && assignmentDate.isNotEmpty && selectedMapel.isNotEmpty) {
                    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
                    final newTask = {
                      'id': taskId,
                      'name': taskName,
                      'assignmentDate': assignmentDate,
                      'deadline': deadline,
                      'description': description,
                      'type': selectedClass,
                      'checked': false,
                      'image': selectedImage,
                      'file': selectedFile,
                      'className': widget.className,
                      'mapel': selectedMapel,
                    };

                    try {
                      await _taskManager.saveTaskToClass(widget.className, newTask);
                      await _notificationService.addNotification({
                        'taskId': taskId,
                        'taskName': taskName,
                        'className': widget.className,
                        'deadline': deadline,
                        'isCompleted': false,
                        'type': 'deadline',
                        'description': description,
                      });

                      this.setState(() {
                        siswaData[selectedClass]?.add(Map<String, dynamic>.from(newTask));
                        checkedCount = siswaData[selectedClass]!
                            .where((task) => task['checked'])
                            .length;
                      });

                      await TaskStorage.saveTasks(siswaData);

                      if (widget.onTaskAdded != null) {
                        widget.onTaskAdded!(newTask, selectedClass!);
                      }

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tugas baru berhasil ditambahkan'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      print('Error adding task: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menambahkan tugas'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 16, 72, 129),
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

  void _onTaskUpdated(Map<String, dynamic> updatedTask) {
    setState(() {
      final taskList = siswaData[selectedClass]!;
      final index = taskList.indexWhere((task) => task['id'] == updatedTask['id']);
      if (index != -1) {
        taskList[index] = Map<String, dynamic>.from(updatedTask);
        TaskStorage.saveTasks(siswaData);
      }
    });
  }

  bool _isDeadlineNear(String deadline) {
    final now = DateTime.now();
    final deadlineDate = DateFormat('yyyy-MM-dd').parse(deadline);
    final difference = deadlineDate.difference(now).inDays;
    return difference <= 3 && difference >= 0; 
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
          final isDeadlineNear = _isDeadlineNear(task['deadline']);

          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
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
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: task['checked']
                        ? Colors.blue.shade50
                        : (isDeadlineNear ? Colors.orange.shade50 : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withOpacity(0.13),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDeadlineNear
                          ? Colors.orange.shade200
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nomor urut
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: task['checked'] ? Colors.blue.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
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
                      SizedBox(width: 14),
                      // Info utama tugas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama tugas dan badge selesai
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task['name'] ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: task['checked'] ? Colors.blue.shade900 : Color(0xFF2E3F7F),
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (task['checked'] == true)
                                  Container(
                                    margin: EdgeInsets.only(left: 6),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green[600],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check, color: Colors.white, size: 13),
                                        SizedBox(width: 2),
                                        Text(
                                          'Selesai',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4),
                            // Mapel dan tanggal penugasan
                            Row(
                              children: [
                                Icon(Icons.book, size: 15, color: Colors.blue.shade700),
                                SizedBox(width: 4),
                                Text(
                                  task['mapel'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.event_note, size: 15, color: Colors.orange.shade700),
                                SizedBox(width: 4),
                                Text(
                                  task['assignmentDate'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            // Deadline
                            Row(
                              children: [
                                Icon(Icons.timer, size: 15, color: isDeadlineNear ? Colors.red : Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  'Deadline: ${task['deadline']}',
                                  style: TextStyle(
                                    color: isDeadlineNear ? Colors.red : Colors.grey.shade700,
                                    fontWeight: isDeadlineNear ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                                if (isDeadlineNear && !task['checked'])
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      'Segera!',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Checkbox
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: Transform.scale(
                          scale: 1.15,
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
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _currentCategoryPage = index;
      selectedClass = kelasList[index];
      selectedIndex = index;
      
      // Ensure the category exists in siswaData
      if (selectedClass != null && siswaData[selectedClass] == null) {
        siswaData[selectedClass!] = [];
      }
      
      // Update checkedCount
      checkedCount = siswaData[selectedClass]!
          .where((task) => task['checked'])
          .length;
    });
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 180,
      margin: EdgeInsets.only(top: 0), 
      padding: EdgeInsets.only(left: 15), 
      child: Row(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _categoryPageController,
              scrollDirection: Axis.vertical,
              itemCount: kelasList.length,
              onPageChanged: _onCategoryChanged,
              itemBuilder: (context, index) {
                String kelas = kelasList[index];
                bool isSelected = selectedIndex == index;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15), 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withOpacity(0.5),
                        blurRadius: 8,
                        offset: Offset(0, 4), 
                      ),
                    ],
                    border: Border.all(
                      color: isSelected ? const Color.fromARGB(255, 11, 83, 143) : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue.shade50 : Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.assignment,
                                color: isSelected ? Colors.blue.shade900 : Colors.blue.shade300,
                                size: 28, 
                              ),
                            ),
                            SizedBox(height: 8), 
                            Text(
                              kelas,
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.blue.shade900 : Colors.blue.shade300,
                              ),
                            ),
                            if (selectedClass == kelas)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3), 
                                margin: EdgeInsets.only(top: 4),
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
                                    fontSize: 11, 
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
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E3F7F), Color(0xFF4557A4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Tugas Kelas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSearching) ...[
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari tugas...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ],
            SizedBox(height: 10), 
            Row(
              children: [
                Expanded(
                  child: _buildCategorySelector(),
                ),
                // Add navigation controls on the right
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward, color: Colors.blue.shade700),
                        onPressed: () {
                          if (_currentCategoryPage > 0) {
                            _categoryPageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                      ),
                      ...List.generate(
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
                      IconButton(
                        icon: Icon(Icons.arrow_downward, color: const Color.fromARGB(255, 16, 72, 129)),
                        onPressed: () {
                          if (_currentCategoryPage < kelasList.length - 1) {
                            _categoryPageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                      ),
                    ],
                  ),
                ),
              ],
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
                      icon: Icon(Icons.add_task, color: const Color.fromARGB(255, 16, 72, 129)),
                      onPressed: _addNewTask,
                    ),
                  ],
                ),
              ),
              _buildTaskList(), 
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