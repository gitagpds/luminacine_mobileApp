class BookingSeatModel {
  String? status;
  String? message;
  List<BookingSeat>? data;

  BookingSeatModel({this.status, this.message, this.data});

  BookingSeatModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BookingSeat>[];
      json['data'].forEach((v) {
        data!.add(BookingSeat.fromJson(v));
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

class BookingSeat {
  int? idBooking;
  int? idSeat;

  BookingSeat(
    {this.idBooking, 
    this.idSeat
  });

  BookingSeat.fromJson(Map<String, dynamic> json) {
    idBooking = json['idBooking'];
    idSeat = json['idSeat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idBooking'] = idBooking;
    data['idSeat'] = idSeat;
    return data;
  }
}
