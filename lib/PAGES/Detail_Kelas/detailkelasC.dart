import 'package:flutter/material.dart';


class DetailKelasC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Tugas Kelas C'),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 14, 171, 174),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children:[ 
                      SizedBox(height: 65),
                      ElevatedButton(
                      onPressed: () {

                      },
                      child: Text("Tugas 1"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(350, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        
                      },
                      child: Text("Tugas 1"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(350, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        
                      },
                      child: Text("Tugas 1"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(350, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        
                      },
                      child: Text("Tugas 1"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(350, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 14, 171, 174),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children:[ 
                      SizedBox(height: 65),
                      ElevatedButton(
                      onPressed: () {

                      },
                      child: Text("Tugas 1"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(350, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        
                      },
                      child: Text("Tugas 1"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(350, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        
                      },
                      child: Text("Tugas 1"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(350, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        
                      },
                      child: Text("Tugas 1"),
                      style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.blue[700],
                      minimumSize: Size(350, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
