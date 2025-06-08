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
  
  Seat(
    {this.idSeat, 
    this.idSchedule, 
    this.seatCode
  });

  Seat.fromJson(Map<String, dynamic> json) {
    idSeat = json['idSeat'];
    idSchedule = json['idSchedule'];
    seatCode = json['seatCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idSeat'] = idSeat;
    data['idSchedule'] = idSchedule;
    data['seatCode'] = seatCode;
    return data;
  }
}
