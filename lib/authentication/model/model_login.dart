// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String status;
  String message;
  Data data;

  LoginModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String accessToken;
  String id;
  String fullName;
  String email;

  Data({
    required this.accessToken,
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    accessToken: json["accessToken"],
    id: json["_id"],
    fullName: json["fullName"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "_id": id,
    "fullName": fullName,
    "email": email,
  };
}
