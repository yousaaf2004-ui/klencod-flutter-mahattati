class BookingModel {
  final int? id;
  final int userId;
  final int stationId;
  final int vehicleId;
  final String bookingDate;
  final int groupNumber;
  final String barcode;
  final String status;

  BookingModel({
    this.id,
    required this.userId,
    required this.stationId,
    required this.vehicleId,
    required this.bookingDate,
    required this.groupNumber,
    required this.barcode,
    this.status = 'pending',
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
        id: map['id'],
        userId: map['user_id'],
        stationId: map['station_id'],
        vehicleId: map['vehicle_id'],
        bookingDate: map['booking_date'],
        groupNumber: map['group_number'],
        barcode: map['barcode'],
        status: map['status'],
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'station_id': stationId,
        'vehicle_id': vehicleId,
        'booking_date': bookingDate,
        'group_number': groupNumber,
        'barcode': barcode,
        'status': status,
      };
}
