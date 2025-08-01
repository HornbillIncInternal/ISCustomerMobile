// To parse this JSON data, do
//
//     final signupModel = signupModelFromJson(jsonString);

import 'dart:convert';

SignupModel signupModelFromJson(String str) => SignupModel.fromJson(json.decode(str));

String signupModelToJson(SignupModel data) => json.encode(data.toJson());

class SignupModel {
  String status;
  String message;
  SignupData data;

  SignupModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SignupModel.fromJson(Map<String, dynamic> json) => SignupModel(
    status: json["status"],
    message: json["message"],
    data: SignupData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class SignupData {
  String accessToken;
  String id;
  String name;
  String email;

  SignupData({
    required this.accessToken,
    required this.id,
    required this.name,
    required this.email,
  });

  factory SignupData.fromJson(Map<String, dynamic> json) => SignupData(
    accessToken: json["accessToken"],
    id: json["id"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "id": id,
    "name": name,
    "email": email,
  };
}
