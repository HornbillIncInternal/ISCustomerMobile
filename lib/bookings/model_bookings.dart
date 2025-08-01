

class BookingHistoryModel {
  String? status;
  String? message;
  List<BookingData>? data;

  BookingHistoryModel({this.status, this.message, this.data});

  BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BookingData>[];
      json['data'].forEach((v) {
        data!.add(new BookingData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookingData {
  List<Completed>? completed;
  List<Upcoming>? upcoming;

  BookingData({this.completed, this.upcoming});

  BookingData.fromJson(Map<String, dynamic> json) {
    if (json['completed'] != null) {
      completed = <Completed>[];
      json['completed'].forEach((v) {
        completed!.add(new Completed.fromJson(v));
      });
    }
    if (json['upcoming'] != null) {
      upcoming = <Upcoming>[];
      json['upcoming'].forEach((v) {
        upcoming!.add(new Upcoming.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.completed != null) {
      data['completed'] = this.completed!.map((v) => v.toJson()).toList();
    }
    if (this.upcoming != null) {
      data['upcoming'] = this.upcoming!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Completed {
  String? id;
  List<Bookings>? bookings;
  String? addedByUserType;
  String? status;
  String? bookingId;
  String? fromDate;
  String? toDate;
  String? fromTime;
  String? toTime;
  Billing? billing;
  String? addedBy;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<Branch>? branches;
  Completed(
      {this.id,
        this.bookings,
        this.addedByUserType,
        this.status,
        this.bookingId,
        this.fromDate,
        this.toDate,
        this.fromTime,
        this.toTime,
        this.billing,
        this.addedBy,
        this.createdAt,
        this.updatedAt,
        this.iV,
      this.branches});

  Completed.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    if (json['bookings'] != null) {
      bookings = <Bookings>[];
      json['bookings'].forEach((v) {
        bookings!.add(new Bookings.fromJson(v));
      });
    }
    addedByUserType = json['addedByUserType'];
    status = json['status'];
    bookingId = json['bookingId'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    fromTime = json['fromTime'];
    toTime = json['toTime'];
    billing =
    json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    addedBy = json['addedBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    if (json['branches'] != null) {
      branches = <Branch>[];
      json['branches'].forEach((v) {
        branches!.add(new Branch.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    if (this.bookings != null) {
      data['bookings'] = this.bookings!.map((v) => v.toJson()).toList();
    }
    data['addedByUserType'] = this.addedByUserType;
    data['status'] = this.status;
    data['bookingId'] = this.bookingId;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    data['fromTime'] = this.fromTime;
    data['toTime'] = this.toTime;
    if (this.billing != null) {
      data['billing'] = this.billing!.toJson();
    }
    data['addedBy'] = this.addedBy;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
class Upcoming {
  String? id;
  List<Bookings>? bookings;
  String? addedByUserType;
  String? status;
  String? bookingId;
  String? fromDate;
  String? toDate;
  String? fromTime;
  String? toTime;
  Billing? billing;
  String? addedBy;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<Branch>? branches;
  Upcoming(
      {this.id,
        this.bookings,
        this.addedByUserType,
        this.status,
        this.bookingId,
        this.fromDate,
        this.toDate,
        this.fromTime,
        this.toTime,
        this.billing,
        this.addedBy,
        this.createdAt,
        this.updatedAt,
        this.iV,
      this.branches});

  Upcoming.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    if (json['bookings'] != null) {
      bookings = <Bookings>[];
      json['bookings'].forEach((v) {
        bookings!.add(new Bookings.fromJson(v));
      });
    }
    addedByUserType = json['addedByUserType'];
    status = json['status'];
    bookingId = json['bookingId'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    fromTime = json['fromTime'];
    toTime = json['toTime'];
    billing =
    json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    addedBy = json['addedBy'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    if (json['branches'] != null) {
      branches = <Branch>[];
      json['branches'].forEach((v) {
        branches!.add(new Branch.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    if (this.bookings != null) {
      data['bookings'] = this.bookings!.map((v) => v.toJson()).toList();
    }
    data['addedByUserType'] = this.addedByUserType;
    data['status'] = this.status;
    data['bookingId'] = this.bookingId;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    data['fromTime'] = this.fromTime;
    data['toTime'] = this.toTime;
    if (this.billing != null) {
      data['billing'] = this.billing!.toJson();
    }
    data['addedBy'] = this.addedBy;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Bookings {
  String? sId;
  String? assetId;
  String? fromDate;
  String? toDate;
  Asset? asset;
  Branch? branch;
  Bookings({this.sId, this.assetId, this.fromDate, this.toDate, this.asset,this.branch});

  Bookings.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    assetId = json['assetId'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    asset = json['asset'] != null ? new Asset.fromJson(json['asset']) : null;
    branch =
    json['branch'] != null ? new Branch.fromJson(json['branch']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['assetId'] = this.assetId;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    if (this.asset != null) {
      data['asset'] = this.asset!.toJson();
    }
    return data;
  }
}
class Branch {
  String? sId;
  String? name;

  Address? address;
  Branch({this.sId, this.name,   this.address,});

  Branch.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    address = json['address'] != null ? new Address.fromJson(json['address']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}
class Asset {
  String? id;
  String? title;
  Family? family;

  Asset({this.id, this.title});

  Asset.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    family =
    json['family'] != null ? new Family.fromJson(json['family']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['title'] = this.title;
    return data;
  }
}
class Family {
  String? sId;
  String? title;

  Family({this.sId, this.title});

  Family.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    return data;
  }
}

class Billing {
  String? packageId;

  Billing({this.packageId});

  Billing.fromJson(Map<String, dynamic> json) {
    packageId = json['packageId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['packageId'] = this.packageId;
    return data;
  }
}

class Address {
  Location? location;

  Address({this.location});

  Address.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    return data;
  }
}

class Location {
  double? lat;
  double? lng;

  Location({this.lat, this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    return data;
  }
}
/*BookingHistoryModel bookingHistoryModelFromJson(String str) => BookingHistoryModel.fromJson(json.decode(str));

String bookingHistoryModelToJson(BookingHistoryModel data) => json.encode(data.toJson());

class BookingHistoryModel {
  String status;
  String message;
  List<BookingData> data;

  BookingHistoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) => BookingHistoryModel(
    status: json["status"],
    message: json["message"],
    data: List<BookingData>.from(json["data"].map((x) => BookingData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}
class BookingData {
  List<Completed> completed;
  List<Upcoming> upcoming;

  BookingData({
    required this.completed,
    required this.upcoming,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) => BookingData(
    completed: List<Completed>.from(json["completed"].map((x) => Completed.fromJson(x))),
    upcoming: List<Upcoming>.from(json["upcoming"].map((x) => Upcoming.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "completed": List<dynamic>.from(completed.map((x) => x.toJson())),
    "upcoming": List<dynamic>.from(upcoming.map((x) => x.toJson())),
  };
}





class Upcoming {
  String id;
  String status;
  DateTime fromDate;
  DateTime toDate;
  DateTime createdAt;
  Asset asset;
  Branch branch;

  Upcoming({
    required this.id,
    required this.status,
    required this.fromDate,
    required this.toDate,
    required this.createdAt,
    required this.asset,
    required this.branch,
  });

  factory Upcoming.fromJson(Map<String, dynamic> json) => Upcoming(
    id: json["_id"],
    status: json["status"] ?? '',
    fromDate: DateTime.parse(json["fromDate"]),
    toDate: DateTime.parse(json["toDate"]),
    createdAt: DateTime.parse(json["createdAt"]),
    asset: Asset.fromJson(json["asset"]),
    branch: Branch.fromJson(json["branch"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "status": status,
    "fromDate": fromDate.toIso8601String(),
    "toDate": toDate.toIso8601String(),
    "createdAt": createdAt.toIso8601String(),
    "asset": asset.toJson(),
    "branch": branch.toJson(),
  };
}

class Completed {
  String id;
  String status;
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
      status: json["status"] ?? '',
    fromDate: DateTime.parse(json["fromDate"]),
    toDate: DateTime.parse(json["toDate"]),
    createdAt: DateTime.parse(json["createdAt"]),
    asset: Asset.fromJson(json["asset"]),
    branch: Branch.fromJson(json["branch"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
  "status": status,
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


  Thumbnail({
    required this.filename,
    required this.originalFilename,
    required this.path,

  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
    filename: json["Filename"],
    originalFilename: json["OriginalFilename"],
    path: json["path"],

  );

  Map<String, dynamic> toJson() => {
    "Filename": filename,
    "OriginalFilename": originalFilename,
    "path": path,

  };
}*/





/*class Branch {
  String? id;
  List<Thumbnail> images;
  String? name;

  Branch({
    required this.id,
    required this.images,
    required this.name,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
      id: json["_id"] ?? '',
    images: List<Thumbnail>.from(json["images"].map((x) => Thumbnail.fromJson(x))),
    name: json["name"]!,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "name": name,
  };
}*/

/*class Completed {
  String id;
  String branch;
  String status;
  List<dynamic> history;
  String assetId;
  DateTime fromDate;
  DateTime toDate;
  String fromTime;
  String toTime;
  String bookedBy;
  String bookingBy;
  String? phone; // Make phone nullable
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Completed({
    required this.id,
    required this.branch,
    required this.status,
    required this.history,
    required this.assetId,
    required this.fromDate,
    required this.toDate,
    required this.fromTime,
    required this.toTime,
    required this.bookedBy,
    required this.bookingBy,
    this.phone, // Allow phone to be nullable
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Completed.fromJson(Map<String, dynamic> json) => Completed(
    id: json["_id"] ?? '', // Provide default value if null
    branch: json["branch"] ?? '', // Provide default value if null
    status: json["status"] ?? '', // Provide default value if null
    history: List<dynamic>.from(json["history"].map((x) => x)),
    assetId: json["assetId"] ?? '', // Provide default value if null
    fromDate: DateTime.parse(json["fromDate"]),
    toDate: DateTime.parse(json["toDate"]),
    fromTime: json["fromTime"] ?? '', // Provide default value if null
    toTime: json["toTime"] ?? '', // Provide default value if null
    bookedBy: json["bookedBy"] ?? '', // Provide default value if null
    bookingBy: json["bookingBy"] ?? '', // Provide default value if null
    phone: json["phone"], // Allow null
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"] ?? 0, // Provide default value if null
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "branch": branch,
    "status": status,
    "history": List<dynamic>.from(history.map((x) => x)),
    "assetId": assetId,
    "fromDate": fromDate.toIso8601String(),
    "toDate": toDate.toIso8601String(),
    "fromTime": fromTime,
    "toTime": toTime,
    "bookedBy": bookedBy,
    "bookingBy": bookingBy,
    "phone": phone, // Allow null
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}*/










