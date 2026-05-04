class ReportModel {
  final String id;
  final String userId;
  final String userName;
  final String photoUrl;
  final String wasteType;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String status;
  final int pointsAwarded;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.photoUrl,
    required this.wasteType,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.status,
    required this.pointsAwarded,
    required this.createdAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      wasteType: map['wasteType'] ?? 'mixed',
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'] ?? '',
      status: map['status'] ?? 'pending',
      pointsAwarded: map['pointsAwarded'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'photoUrl': photoUrl,
    'wasteType': wasteType,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'status': status,
    'pointsAwarded': pointsAwarded,
    'createdAt': createdAt,
  };
}
