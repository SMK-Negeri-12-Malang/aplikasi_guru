import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kebijakan Privasi'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Kebijakan Privasi untuk Aplikasi Santri',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Terakhir diperbarui: 14-12-2025',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16.0),
            Text(
              'Kami menghargai privasi Anda dan berkomitmen untuk melindungi informasi pribadi Anda. Kebijakan privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda saat Anda menggunakan aplikasi santri kami.',
            ),
            SizedBox(height: 16.0),
            Text(
              'Informasi yang Kami Kumpulkan',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Kami dapat mengumpulkan informasi berikut dari Anda:',
            ),
            SizedBox(height: 8.0),
            Text(
              '- Informasi pribadi yang Anda berikan saat mendaftar atau menggunakan aplikasi, seperti nama, alamat email, dan nomor telepon.',
            ),
            Text(
              '- Informasi tentang penggunaan aplikasi Anda, seperti fitur yang Anda gunakan dan waktu Anda menggunakannya.',
            ),
            Text(
              '- Informasi perangkat Anda, seperti jenis perangkat, sistem operasi, dan pengidentifikasi unik perangkat.',
            ),
            SizedBox(height: 16.0),
            Text(
              'Bagaimana Kami Menggunakan Informasi Anda',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Kami dapat menggunakan informasi Anda untuk tujuan berikut:',
            ),
            SizedBox(height: 8.0),
            Text(
              '- Menyediakan dan meningkatkan layanan aplikasi.',
            ),
            Text(
              '- Mempersonalisasi pengalaman Anda di aplikasi.',
            ),
            Text(
              '- Menghubungi Anda dengan informasi terkait aplikasi.',
            ),
            Text(
              '- Menganalisis penggunaan aplikasi untuk meningkatkan kualitasnya.',
            ),
            SizedBox(height: 16.0),
            Text(
              'Bagaimana Kami Melindungi Informasi Anda',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Kami mengambil langkah-langkah keamanan yang wajar untuk melindungi informasi Anda dari akses yang tidak sah, penggunaan, atau pengungkapan.',
            ),
            SizedBox(height: 16.0),
            Text(
              'Perubahan pada Kebijakan Privasi',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. Perubahan akan diposting di halaman ini dengan tanggal efektif yang diperbarui.',
            ),
            SizedBox(height: 16.0),
            Text(
              'Hubungi Kami',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Jika Anda memiliki pertanyaan tentang kebijakan privasi ini, silakan hubungi kami di [alamat email atau nomor telepon].',
            ),
          ],
        ),
      ),
    );
  }
}