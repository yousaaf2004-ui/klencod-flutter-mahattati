class VehicleModel {
  final int? id;
  final int userId;
  final String plateNumber;
  final String model;
  final String color;
  final int year;
  final String status;

  VehicleModel({
    this.id,
    required this.userId,
    required this.plateNumber,
    required this.model,
    required this.color,
    required this.year,
    this.status = 'pending',
  });

  factory VehicleModel.fromMap(Map<String, dynamic> map) => VehicleModel(
        id: map['id'],
        userId: map['user_id'],
        plateNumber: map['plate_number'],
        model: map['model'],
        color: map['color'],
        year: map['year'],
        status: map['status'],
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'plate_number': plateNumber,
        'model': model,
        'color': color,
        'year': year,
        'status': status,
      };
}