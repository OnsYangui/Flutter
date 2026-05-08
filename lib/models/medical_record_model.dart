class MedicalRecord {
  final String id;
  final String title;
  final String description;
  final String? fileUrl;
  final String? thumbnailUrl;
  final String fileType; // 'pdf', 'image', 'document'
  final DateTime recordDate;
  final List<String> tags;
  final String? category; // 'analysis', 'radio', 'hospitalization', 'vaccination'
  final String? hospitalName;
  final String? doctorName;
  final Map<String, dynamic>? metadata;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.description,
    this.fileUrl,
    this.thumbnailUrl,
    required this.fileType,
    required this.recordDate,
    this.tags = const [],
    this.category,
    this.hospitalName,
    this.doctorName,
    this.metadata,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileType': fileType,
      'recordDate': recordDate.toIso8601String(),
      'tags': tags,
      'category': category,
      'hospitalName': hospitalName,
      'doctorName': doctorName,
      'metadata': metadata,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map, [String? id]) {
    return MedicalRecord(
      id: id ?? map['id'],
      title: map['title'],
      description: map['description'],
      fileUrl: map['fileUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      fileType: map['fileType'],
      recordDate: DateTime.parse(map['recordDate']),
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
      category: map['category'],
      hospitalName: map['hospitalName'],
      doctorName: map['doctorName'],
      metadata: map['metadata'],
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}