import 'dart:convert';

CancelModel cancelModelFromJson(String str) => CancelModel.fromJson(json.decode(str));

String cancelModelToJson(CancelModel data) => json.encode(data.toJson());

class CancelModel {
  String status;
  String message;

  CancelModel({
    required this.status,
    required this.message,
  });

  factory CancelModel.fromJson(Map<String, dynamic> json) => CancelModel(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}