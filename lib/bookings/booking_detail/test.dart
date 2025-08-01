// To parse this JSON data, do
//
//     final bookingHistoryModel = bookingHistoryModelFromJson(jsonString);

import 'dart:convert';

BookingHistoryModel bookingHistoryModelFromJson(String str) => BookingHistoryModel.fromJson(json.decode(str));

String bookingHistoryModelToJson(BookingHistoryModel data) => json.encode(data.toJson());

class BookingHistoryModel {
  String status;
  String message;
  List<Datum> data;

  BookingHistoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) => BookingHistoryModel(
    status: json["status"],
    message: json["message"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  List<Completed> completed;
  List<Completed> upcoming;

  Datum({
    required this.completed,
    required this.upcoming,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    completed: List<Completed>.from(json["completed"].map((x) => Completed.fromJson(x))),
    upcoming: List<Completed>.from(json["upcoming"].map((x) => Completed.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "completed": List<dynamic>.from(completed.map((x) => x.toJson())),
    "upcoming": List<dynamic>.from(upcoming.map((x) => x.toJson())),
  };
}

class Completed {
  String id;
  Status status;
  DateTime fromDate;
  DateTime toDate;
  DateTime createdAt;
  Asset asset;
  Branch branch;

  Completed({
    required this.id,
    required this.status,
    required this.fromDate,
    required this.toDate,
    required this.createdAt,
    required this.asset,
    required this.branch,
  });

  factory Completed.fromJson(Map<String, dynamic> json) => Completed(
    id: json["_id"],
    status: statusValues.map[json["status"]]!,
    fromDate: DateTime.parse(json["fromDate"]),
    toDate: DateTime.parse(json["toDate"]),
    createdAt: DateTime.parse(json["createdAt"]),
    asset: Asset.fromJson(json["asset"]),
    branch: Branch.fromJson(json["branch"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "status": statusValues.reverse[status],
    "fromDate": fromDate.toIso8601String(),
    "toDate": toDate.toIso8601String(),
    "createdAt": createdAt.toIso8601String(),
    "asset": asset.toJson(),
    "branch": branch.toJson(),
  };
}

class Asset {
  String id;
  String title;
  Thumbnail thumbnail;

  Asset({
    required this.id,
    required this.title,
    required this.thumbnail,
  });

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
    id: json["_id"],
    title: json["title"],
    thumbnail: Thumbnail.fromJson(json["thumbnail"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "thumbnail": thumbnail.toJson(),
  };
}

class Thumbnail {
  String filename;
  String originalFilename;
  String path;
  MimeType mimeType;

  Thumbnail({
    required this.filename,
    required this.originalFilename,
    required this.path,
    required this.mimeType,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
    filename: json["Filename"],
    originalFilename: json["OriginalFilename"],
    path: json["path"],
    mimeType: mimeTypeValues.map[json["MimeType"]]!,
  );

  Map<String, dynamic> toJson() => {
    "Filename": filename,
    "OriginalFilename": originalFilename,
    "path": path,
    "MimeType": mimeTypeValues.reverse[mimeType],
  };
}

enum MimeType {
  IMAGE_JPEG
}

final mimeTypeValues = EnumValues({
  "image/jpeg": MimeType.IMAGE_JPEG
});

class Branch {
  Id id;
  List<Thumbnail> images;
  Name name;

  Branch({
    required this.id,
    required this.images,
    required this.name,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: idValues.map[json["_id"]]!,
    images: List<Thumbnail>.from(json["images"].map((x) => Thumbnail.fromJson(x))),
    name: nameValues.map[json["name"]]!,
  );

  Map<String, dynamic> toJson() => {
    "_id": idValues.reverse[id],
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "name": nameValues.reverse[name],
  };
}

enum Id {
  THE_671_C97_CC0_A5354000_B149_C07,
  THE_671_C97_E80_A5354000_B149_C0_C,
  THE_671_C98450_A5354000_B149_C15
}

final idValues = EnumValues({
  "671c97cc0a5354000b149c07": Id.THE_671_C97_CC0_A5354000_B149_C07,
  "671c97e80a5354000b149c0c": Id.THE_671_C97_E80_A5354000_B149_C0_C,
  "671c98450a5354000b149c15": Id.THE_671_C98450_A5354000_B149_C15
});

enum Name {
  EDAPPALLY,
  KAKKANAD,
  KALOOR
}

final nameValues = EnumValues({
  "Edappally": Name.EDAPPALLY,
  "KAKKANAD": Name.KAKKANAD,
  "Kaloor": Name.KALOOR
});

enum Status {
  BLOCKED,
  BOOKED
}

final statusValues = EnumValues({
  "blocked": Status.BLOCKED,
  "booked": Status.BOOKED
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
