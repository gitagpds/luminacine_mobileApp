class SeatModel {
  String? status;
  String? message;
  List<Seat>? data;

  SeatModel({this.status, this.message, this.data});

  SeatModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Seat>[];
      json['data'].forEach((v) {
        data!.add(Seat.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Seat {
  int? idSeat;
  int? idSchedule;
  String? seatCode;
  String? seatStatus; // ✅ Tambahan untuk status kursi (booked/available)

  Seat({
    this.idSeat,
    this.idSchedule,
    this.seatCode,
    this.seatStatus,
  });

  Seat.fromJson(Map<String, dynamic> json) {
    idSeat = json['id_seat'];
    idSchedule = json.containsKey('id_schedule') ? json['id_schedule'] : null;
    seatCode = json['seat_code'];
    seatStatus = json['status']; // ✅ Ambil status dari API jika ada
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_seat'] = idSeat;
    data['id_schedule'] = idSchedule;
    data['seat_code'] = seatCode;
    data['status'] = seatStatus; // ✅ Sertakan status kursi juga
    return data;
  }
}
