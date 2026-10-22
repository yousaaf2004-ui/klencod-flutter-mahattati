class StationModel {
  final int? id;
  final String name;
  final String location;
  final bool isOpen;
  final double allocatedLiters;
  final double remainingLiters;

  StationModel({
    this.id,
    required this.name,
    required this.location,
    required this.isOpen,
    required this.allocatedLiters,
    required this.remainingLiters,
  });

  factory StationModel.fromMap(Map<String, dynamic> map) => StationModel(
        id: map['id'],
        name: map['name'],
        location: map['location'],
        isOpen: map['is_open'] == 1,
        allocatedLiters: map['allocated_liters'].toDouble(),
        remainingLiters: map['remaining_liters'].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'location': location,
        'is_open': isOpen ? 1 : 0,
        'allocated_liters': allocatedLiters,
        'remaining_liters': remainingLiters,
      };
}
