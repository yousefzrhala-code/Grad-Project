class ReservationModel {
  final int id;
  final int carOwnerId;
  final int garageId;
  final String reservationDate;
  final String startTime;
  final String endTime;
  final int numberOfSpots;
  final String status;
  final double? pricePerHour;
  final double? totalCost;
  final String? cancelReason;
  final String? ownerResponseNote;
  final String garageName;
  final String? garageLocation;
  final String? checkedInAt;
  final String? checkedOutAt;
  final String? garageOwnerPhone;

  ReservationModel({
    required this.id,
    required this.carOwnerId,
    required this.garageId,
    required this.reservationDate,
    required this.startTime,
    required this.endTime,
    required this.numberOfSpots,
    required this.status,
    this.pricePerHour,
    this.totalCost,
    this.cancelReason,
    this.ownerResponseNote,
    required this.garageName,
    this.garageLocation,
    this.checkedInAt,
    this.checkedOutAt,
    this.garageOwnerPhone,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] ?? 0,
      carOwnerId: json['car_owner_id'] ?? 0,
      garageId: json['garage_id'] ?? 0,
      reservationDate: json['reservation_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      numberOfSpots: json['number_of_spots'] ?? 1,
      status: json['status']?.toString() ?? '',
      pricePerHour: json['price_per_hour'] != null
          ? double.tryParse(json['price_per_hour'].toString())
          : null,
      totalCost: json['total_cost'] != null
          ? double.tryParse(json['total_cost'].toString())
          : null,
      cancelReason: json['cancel_reason']?.toString(),
      ownerResponseNote: json['owner_response_note']?.toString(),
      garageName: json['garage']?['name']?.toString() ?? 'Unknown Garage',
      garageLocation: json['garage']?['address']?.toString() ??
          json['garage']?['location']?.toString(),
      checkedInAt: json['checked_in_at']?.toString(),
      checkedOutAt: json['checked_out_at']?.toString(),
      garageOwnerPhone: json['garage']?['owner']?['phone']?.toString(),
    );
  }

  bool get isCheckedIn => checkedInAt != null && checkedInAt!.isNotEmpty;
  bool get isCheckedOut => checkedOutAt != null && checkedOutAt!.isNotEmpty;

  bool get canCancel {
    if (status == 'cancelled' ||
        status == 'completed' ||
        status == 'rejected') {
      return false;
    }
    try {
      final start = DateTime.parse('$reservationDate $startTime');
      return start.isAfter(DateTime.now().add(const Duration(hours: 2)));
    } catch (_) {
      return false;
    }
  }
  bool get canCheckIn {
    if (status != 'accepted') return false;
    if (isCheckedIn) return false;
    try {
      final start = DateTime.parse('$reservationDate $startTime');
      final end = DateTime.parse('$reservationDate $endTime');
      final now = DateTime.now();
      return now.isAfter(start.subtract(const Duration(minutes: 30))) &&
          now.isBefore(end);
    } catch (_) {
      return false;
    }
  }

  bool get canCheckOut {
    if (!isCheckedIn) return false;
    if (isCheckedOut) return false;
    return status == 'accepted' || status == 'completed';
  }

  bool get canRate => status == 'completed';
}
