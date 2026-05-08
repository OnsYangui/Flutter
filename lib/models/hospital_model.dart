class Hospital {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? email;
  final String? website;
  final double? latitude;
  final double? longitude;
  final List<String> specialties;
  final String? imageUrl;
  final bool isEmergency;
  final DateTime? createdAt;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.email,
    this.website,
    this.latitude,
    this.longitude,
    this.specialties = const [],
    this.imageUrl,
    this.isEmergency = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'specialties': specialties,
      'imageUrl': imageUrl,
      'isEmergency': isEmergency,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Hospital.fromMap(Map<String, dynamic> map, String id) {
    return Hospital(
      id: id,
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      email: map['email'],
      website: map['website'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      specialties: map['specialties'] != null
          ? List<String>.from(map['specialties'])
          : [],
      imageUrl: map['imageUrl'],
      isEmergency: map['isEmergency'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }
}

class Doctor {
  final String id;
  final String firstName;
  final String lastName;
  final String specialty;
  final String? hospitalId;
  final String? hospitalName;
  final String? phone;
  final String? email;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> availableDays;
  final String? imageUrl;
  final double? consultationFee;
  final DateTime? createdAt;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    this.hospitalId,
    this.hospitalName,
    this.phone,
    this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.availableDays = const [],
    this.imageUrl,
    this.consultationFee,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'specialty': specialty,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'phone': phone,
      'email': email,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'availableDays': availableDays,
      'imageUrl': imageUrl,
      'consultationFee': consultationFee,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map, String id) {
    return Doctor(
      id: id,
      firstName: map['firstName'],
      lastName: map['lastName'],
      specialty: map['specialty'],
      hospitalId: map['hospitalId'],
      hospitalName: map['hospitalName'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      availableDays: map['availableDays'] != null
          ? List<String>.from(map['availableDays'])
          : [],
      imageUrl: map['imageUrl'],
      consultationFee: map['consultationFee']?.toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }
}
