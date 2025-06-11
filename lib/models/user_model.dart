class UserModel {
  String? status;
  String? message;
  List<User>? data;

  UserModel({this.status, this.message, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <User>[];
      json['data'].forEach((v) {
        data!.add(User.fromJson(v));
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

class User {
  int? idUser;
  String? name;
  String? email;
  String? password;
  String? role;

  User({this.idUser, this.name, this.email, this.password, this.role});

  User.fromJson(Map<String, dynamic> json) {
    idUser = json['id_user'];
    //git, ini namanya salah git aakkkhhhhh 
    name = json['name'];
    email = json['email'];
    password = json['password'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idUser'] = idUser;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['role'] = role;
    return data;
  }
}
