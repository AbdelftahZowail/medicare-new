class ClinicProfile {
  final int id;
  final String name;
  final String? facilityId;
  final String? description;
  final String? government;
  final String? area;
  final String? address;
  final String? linkMap;
  final String? phoneNumber;
  final String? email;
  final String? logoUrl;
  final String? licenseImageUrl;
  final double? latitude;
  final double? longitude;
  final String? openingTime;
  final String? closingTime;
  final bool isActive;
  final int doctorsCount;

  ClinicProfile({
    required this.id,
    required this.name,
    this.facilityId,
    this.description,
    this.government,
    this.area,
    this.address,
    this.linkMap,
    this.phoneNumber,
    this.email,
    this.logoUrl,
    this.licenseImageUrl,
    this.latitude,
    this.longitude,
    this.openingTime,
    this.closingTime,
    required this.isActive,
    required this.doctorsCount,
  });

  factory ClinicProfile.fromJson(Map<String, dynamic> json) {
    return ClinicProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      facilityId: json['facilityId'],
      description: json['description'],
      government: json['government'],
      area: json['area'],
      address: json['address'],
      linkMap: json['linkMap'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      logoUrl: json['logoUrl'],
      licenseImageUrl: json['licenseImageUrl'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      isActive: json['isActive'] ?? false,
      doctorsCount: json['doctorsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'facilityId': facilityId,
      'description': description,
      'government': government,
      'area': area,
      'address': address,
      'linkMap': linkMap,
      'phoneNumber': phoneNumber,
      'email': email,
      'logoUrl': logoUrl,
      'licenseImageUrl': licenseImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isActive': isActive,
      'doctorsCount': doctorsCount,
    };
  }
}
