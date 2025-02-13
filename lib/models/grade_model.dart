class Grade {
  final String id;
  final String studentId;
  final String subjectId;
  final double score;
  final String semester;

  Grade({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.score,
    required this.semester,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      studentId: json['student_id'],
      subjectId: json['subject_id'],
      score: json['score'].toDouble(),
      semester: json['semester'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'score': score,
      'semester': semester,
    };
  }
}
