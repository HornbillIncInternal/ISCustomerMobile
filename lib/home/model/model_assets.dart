


import 'dart:convert';


AssetData assetDataFromJson(String str) => AssetData.fromJson(json.decode(str));

String assetDataToJson(AssetData data) => json.encode(data.toJson());

class AssetData {
  final String? status;
  final String? message;
  final List<Datum>? data;

  AssetData({
    this.status,
    this.message,
    this.data,
  });

  factory AssetData.fromJson(Map<String, dynamic>? json) => AssetData(
    status: json?["status"],
    message: json?["message"],
    data: json?["data"] == null ? [] : List<Datum>.from(json!["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  final String? id;
  final List<String>? aminities;
  final List<DataImage>? images;
  final AssetType? assetType;
  final Branch? branch;
  final String? description;
  final String? title;
  final DataImage? thumbnail;
  final String? familyId;
  final String? familyTitle;
  final Rate? rate;
  final List<DateTime>? holidays;
  final AvailableItems? availableItems;

  Datum({
    this.id,
    this.aminities,
    this.images,
    this.assetType,
    this.branch,
    this.description,
    this.title,
    this.thumbnail,
    this.familyId,
    this.familyTitle,
    this.rate,
    this.holidays,
    this.availableItems,
  });

  factory Datum.fromJson(Map<String, dynamic>? json) => Datum(
    id: json?["_id"],
    aminities: json?['aminities'] == null ? [] : List<String>.from(json!['aminities']),
    images: json?["images"] == null ? [] : List<DataImage>.from(json!["images"].map((x) => DataImage.fromJson(x))),
    assetType: json?["assetType"] == null ? null : AssetType.fromJson(json!["assetType"]),
    branch: json?["branch"] == null ? null : Branch.fromJson(json!["branch"]),
    description: json?["description"],
    title: json?["title"],
    thumbnail: json?["thumbnail"] == null ? null : DataImage.fromJson(json!["thumbnail"]),
    familyId: json?["familyId"],
    familyTitle: json?["familyTitle"],
    rate: json?["rate"] == null ? null : Rate.fromJson(json!["rate"]),
    holidays: json?["holidays"] == null ? [] : List<DateTime>.from(json!["holidays"].map((x) => DateTime.parse(x))),
    availableItems: json?["availableItems"] == null ? null : AvailableItems.fromJson(json!["availableItems"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "aminities": aminities,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
    "assetType": assetType?.toJson(),
    "branch": branch?.toJson(),
    "description": description,
    "title": title,
    "thumbnail": thumbnail?.toJson(),
    "familyId": familyId,
    "familyTitle": familyTitle,
    "rate": rate?.toJson(),
    "holidays": holidays == null ? [] : List<dynamic>.from(holidays!.map((x) => "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
    "availableItems": availableItems?.toJson(),
  };
}

enum Aminity {
  HDMI,
  MIKE,
  PANTRY_ACCESS,
  SPEAKERS,
  WIFI_ACCESS
}

final aminityValues = EnumValues({
  "HDMI": Aminity.HDMI,
  "mike": Aminity.MIKE,
  "pantry access": Aminity.PANTRY_ACCESS,
  "speakers": Aminity.SPEAKERS,
  "wifi access": Aminity.WIFI_ACCESS
});

class AssetType {
  final String? id;
  final List<dynamic>? additionalInputs;
  final AssetTypeStatus? status;
  final String? title;
  final String? description;
  final Thumbnail? thumbnail;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  AssetType({
    this.id,
    this.additionalInputs,
    this.status,
    this.title,
    this.description,
    this.thumbnail,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory AssetType.fromJson(Map<String, dynamic>? json) => AssetType(
    id: json?["_id"],
    additionalInputs: json?["additionalInputs"] == null ? [] : List<dynamic>.from(json!["additionalInputs"]),
    status: json?["status"] == null ? null : assetTypeStatusValues.map[json!["status"]],
    title: json?["title"],
    description: json?["description"],
    thumbnail: json?["thumbnail"] == null ? null : Thumbnail.fromJson(json!["thumbnail"]),
    createdAt: json?["createdAt"] == null ? null : DateTime.parse(json!["createdAt"]),
    updatedAt: json?["updatedAt"] == null ? null : DateTime.parse(json!["updatedAt"]),
    v: json?["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "additionalInputs": additionalInputs == null ? [] : List<dynamic>.from(additionalInputs!),
    "status": status == null ? null : assetTypeStatusValues.reverse[status],
    "title": title,
    "description": description,
    "thumbnail": thumbnail?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

enum AssetTypeStatus {
  ACTIVE,
  DELETED
}

final assetTypeStatusValues = EnumValues({
  "active": AssetTypeStatus.ACTIVE,
  "deleted": AssetTypeStatus.DELETED
});

class Thumbnail {
  final String? fileName;
  final String? originalFileName;
  final String? path;
  final MimeType? mimeType;

  Thumbnail({
    this.fileName,
    this.originalFileName,
    this.path,
    this.mimeType,
  });

  factory Thumbnail.fromJson(Map<String, dynamic>? json) => Thumbnail(
    fileName: json?["fileName"],
    originalFileName: json?["originalFileName"],
    path: json?["path"],
    mimeType: json?["mimeType"] == null ? null : mimeTypeValues.map[json!["mimeType"]],
  );

  Map<String, dynamic> toJson() => {
    "fileName": fileName,
    "originalFileName": originalFileName,
    "path": path,
    "mimeType": mimeType == null ? null : mimeTypeValues.reverse[mimeType!],
  };
}

enum MimeType {
  APPLICATION_JSON,
  IMAGE_JPEG
}

final mimeTypeValues = EnumValues({
  "application/json": MimeType.APPLICATION_JSON,
  "image/jpeg": MimeType.IMAGE_JPEG
});

class AvailableItems {
  final int? count;
  final List<Item>? items;

  AvailableItems({
    this.count,
    this.items,
  });

  factory AvailableItems.fromJson(Map<String, dynamic>? json) => AvailableItems(
    count: json?["count"],
    items: json?["items"] == null ? [] : List<Item>.from(json!["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  final int? tempId;
  final List<Asset>? assets;

  Item({
    this.tempId,
    this.assets,
  });

  factory Item.fromJson(Map<String, dynamic>? json) => Item(
    tempId: json?["tempId"],
    assets: json?["assets"] == null ? [] : List<Asset>.from(json!["assets"].map((x) => Asset.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "tempId": tempId,
    "assets": assets == null ? [] : List<dynamic>.from(assets!.map((x) => x.toJson())),
  };
}

class Asset {
  final String? title;
  final String? id;
  final Availability? availability;

  Asset({
    this.title,
    this.id,
    this.availability,
  });

  factory Asset.fromJson(Map<String, dynamic>? json) => Asset(
    title: json?["title"],
    id: json?["_id"],
    availability: json?["availability"] == null ? null : Availability.fromJson(json!["availability"]),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "_id": id,
    "availability": availability?.toJson(),
  };
}

class Availability {
  DateTime? start;
  DateTime? end;
  String? fromTime;
  String? toTime;

  Availability({
    this.start,
    this.end,
    this.fromTime,
    this.toTime,
  });

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
    start: json["start"] == null ? null : DateTime.parse(json["start"]),
    end: json["end"] == null ? null : DateTime.parse(json["end"]),
    fromTime: json["fromTime"],
    toTime: json["toTime"],
  );

  Map<String, dynamic> toJson() => {
    "start": start?.toIso8601String(),
    "end": end?.toIso8601String(),
    "fromTime": fromTime,
    "toTime": toTime,
  };
}

class Branch {
  final String? id;
  final List<BranchDataImage>? images;
  final List<OpeningHour>? openingHours;
  final List<FloorsAndZone>? floorsAndZones;
  final BranchType? type;
  final BranchStatus? status;
  final CorporateId? corporateId;
  final String? name;
  final String? displayName;
  final String? email;
  final Tel? tel;
  final Address? address;
  final String? description;
  final Meta? meta;
  final DateTime? since;
  final String? website;
  final int? v;
  final Aminities? aminities;
  final double? averageRating;
  final int? totalReviews;

  Branch({
    this.id,
    this.images,
    this.openingHours,
    this.floorsAndZones,
    this.type,
    this.status,
    this.corporateId,
    this.name,
    this.displayName,
    this.email,
    this.tel,
    this.address,
    this.description,
    this.meta,
    this.since,
    this.website,
    this.v,
    this.aminities,
    this.averageRating,
    this.totalReviews,
  });

  factory Branch.fromJson(Map<String, dynamic>? json) => Branch(
    id: json?["_id"],
    images: json?["images"] == null ? [] : List<BranchDataImage>.from(json!["images"].map((x) => BranchDataImage.fromJson(x))),
    openingHours: json?["openingHours"] == null ? [] : List<OpeningHour>.from(json!["openingHours"].map((x) => OpeningHour.fromJson(x))),
    floorsAndZones: json?["floorsAndZones"] == null ? [] : List<FloorsAndZone>.from(json!["floorsAndZones"].map((x) => FloorsAndZone.fromJson(x))),
    type: json?["type"] == null ? null : branchTypeValues.map[json!["type"]],
    status: json?["status"] == null ? null : branchStatusValues.map[json!["status"]],
    corporateId: json?["corporateId"] == null ? null : corporateIdValues.map[json!["corporateId"]],
    name: json?["name"],
    displayName: json?["displayName"],
    email: json?["email"],
    tel: json?["tel"] == null ? null : telValues.map[json!["tel"]],
    address: json?["address"] == null ? null : Address.fromJson(json!["address"]),
    description: json?["description"],
    meta: json?["meta"] == null ? null : Meta.fromJson(json!["meta"]),
    since: json?["since"] == null ? null : DateTime.parse(json!["since"]),
    website: json?["website"],
    v: json?["__v"],
    aminities: json?["aminities"] == null ? null : Aminities.fromJson(json!["aminities"]),
    averageRating: json?["averageRating"]?.toDouble(),
    totalReviews: json?["totalReviews"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x.toJson())),
    "openingHours": openingHours == null ? [] : List<dynamic>.from(openingHours!.map((x) => x.toJson())),
    "floorsAndZones": floorsAndZones == null ? [] : List<dynamic>.from(floorsAndZones!.map((x) => x.toJson())),
    "type": type == null ? null : branchTypeValues.reverse[type!],
    "status": status == null ? null : branchStatusValues.reverse[status!],
    "corporateId": corporateId == null ? null : corporateIdValues.reverse[corporateId!],
    "name": name,
    "displayName": displayName,
    "email": email,
    "tel": tel == null ? null : telValues.reverse[tel!],
    "address": address?.toJson(),
    "description": description,
    "meta": meta?.toJson(),
    "since": since?.toIso8601String(),
    "website": website,
    "__v": v,
    "aminities": aminities?.toJson(),
    "averageRating": averageRating,
    "totalReviews": totalReviews,
  };
}

class Address {
  final String? name;
  final String? formattedAddress;
  final List<AddressComponent>? addressComponents;
  final Location? location;

  Address({
    this.name,
    this.formattedAddress,
    this.addressComponents,
    this.location,
  });

  factory Address.fromJson(Map<String, dynamic>? json) => Address(
    name: json?["name"],
    formattedAddress: json?["formattedAddress"],
    addressComponents: json?["address_components"] == null ? [] : List<AddressComponent>.from(json!["address_components"].map((x) => AddressComponent.fromJson(x))),
    location: json?["location"] == null ? null : Location.fromJson(json!["location"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "formattedAddress": formattedAddress,
    "address_components": addressComponents == null ? [] : List<dynamic>.from(addressComponents!.map((x) => x.toJson())),
    "location": location?.toJson(),
  };
}

class AddressComponent {
  final String? longName;
  final String? shortName;
  final List<TypeElement>? types;

  AddressComponent({
    this.longName,
    this.shortName,
    this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic>? json) => AddressComponent(
    longName: json?["long_name"],
    shortName: json?["short_name"],
    types: json?["types"] == null ? [] : List<TypeElement>.from(json!["types"].map((x) => typeElementValues.map[x]!)),
  );

  Map<String, dynamic> toJson() => {
    "long_name": longName,
    "short_name": shortName,
    "types": types == null ? [] : List<dynamic>.from(types!.map((x) => typeElementValues.reverse[x])),
  };
}

enum TypeElement {
  ADMINISTRATIVE_AREA_LEVEL_1,
  ADMINISTRATIVE_AREA_LEVEL_2,
  ADMINISTRATIVE_AREA_LEVEL_3,
  ADMINISTRATIVE_AREA_LEVEL_4,
  COUNTRY,
  ESTABLISHMENT,
  LANDMARK,
  LOCALITY,
  NATURAL_FEATURE,
  NEIGHBORHOOD,
  POLITICAL,
  POSTAL_CODE,
  ROUTE,
  STREET_NUMBER,
  SUBLOCALITY,
  SUBLOCALITY_LEVEL_1,
  SUBLOCALITY_LEVEL_2
}

final typeElementValues = EnumValues({
  "administrative_area_level_1": TypeElement.ADMINISTRATIVE_AREA_LEVEL_1,
  "administrative_area_level_2": TypeElement.ADMINISTRATIVE_AREA_LEVEL_2,
  "administrative_area_level_3": TypeElement.ADMINISTRATIVE_AREA_LEVEL_3,
  "administrative_area_level_4": TypeElement.ADMINISTRATIVE_AREA_LEVEL_4,
  "country": TypeElement.COUNTRY,
  "establishment": TypeElement.ESTABLISHMENT,
  "landmark": TypeElement.LANDMARK,
  "locality": TypeElement.LOCALITY,
  "natural_feature": TypeElement.NATURAL_FEATURE,
  "neighborhood": TypeElement.NEIGHBORHOOD,
  "political": TypeElement.POLITICAL,
  "postal_code": TypeElement.POSTAL_CODE,
  "route": TypeElement.ROUTE,
  "street_number": TypeElement.STREET_NUMBER,
  "sublocality": TypeElement.SUBLOCALITY,
  "sublocality_level_1": TypeElement.SUBLOCALITY_LEVEL_1,
  "sublocality_level_2": TypeElement.SUBLOCALITY_LEVEL_2
});

class Location {
  final double? lat;
  final double? lng;

  Location({
    this.lat,
    this.lng,
  });

  factory Location.fromJson(Map<String, dynamic>? json) => Location(
    lat: json?["lat"]?.toDouble(),
    lng: json?["lng"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
  };
}

class Aminities {
  final bool? sportsTeam;

  Aminities({
    this.sportsTeam,
  });

  factory Aminities.fromJson(Map<String, dynamic>? json) => Aminities(
    sportsTeam: json?["sports_team"],
  );

  Map<String, dynamic> toJson() => {
    "sports_team": sportsTeam,
  };
}

enum CorporateId {
  THE_672603_F221332_F000_B8_D9_E8_F
}

final corporateIdValues = EnumValues({
  "672603f221332f000b8d9e8f": CorporateId.THE_672603_F221332_F000_B8_D9_E8_F
});

class FloorsAndZone {
  final List<Floor>? floors;
  final String? name;

  FloorsAndZone({
    this.floors,
    this.name,
  });

  factory FloorsAndZone.fromJson(Map<String, dynamic>? json) => FloorsAndZone(
    floors: json?["floors"] == null ? [] : List<Floor>.from(json!["floors"].map((x) => Floor.fromJson(x))),
    name: json?["name"],
  );

  Map<String, dynamic> toJson() => {
    "floors": floors == null ? [] : List<dynamic>.from(floors!.map((x) => x.toJson())),
    "name": name,
  };
}

class Floor {
  final FloorName? name;
  final int? level;
  final List<Zone>? zones;

  Floor({
    this.name,
    this.level,
    this.zones,
  });

  factory Floor.fromJson(Map<String, dynamic>? json) => Floor(
    name: json?["name"] == null ? null : floorNameValues.map[json!["name"]],
    level: json?["level"],
    zones: json?["zones"] == null ? [] : List<Zone>.from(json!["zones"].map((x) => Zone.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : floorNameValues.reverse[name!],
    "level": level,
    "zones": zones == null ? [] : List<dynamic>.from(zones!.map((x) => x.toJson())),
  };
}

enum FloorName {
  FIRST,
  FIRST_FLOOR,
  FORTH_FLOOR,
  GF,
  GFF,
  GROUND,
  GROUND_FLOOR,
  NAME_FIRST_FLOOR,
  SECOND_FLOOR,
  THIRD_FLOOR
}

final floorNameValues = EnumValues({
  "FIRST": FloorName.FIRST,
  "First Floor": FloorName.FIRST_FLOOR,
  "Forth Floor": FloorName.FORTH_FLOOR,
  "GF": FloorName.GF,
  "GFF": FloorName.GFF,
  "GROUND": FloorName.GROUND,
  "Ground Floor": FloorName.GROUND_FLOOR,
  "FIRST FLOOR": FloorName.NAME_FIRST_FLOOR,
  "Second Floor": FloorName.SECOND_FLOOR,
  "Third Floor": FloorName.THIRD_FLOOR
});

class Zone {
  final ZoneName? name;

  Zone({
    this.name,
  });

  factory Zone.fromJson(Map<String, dynamic>? json) => Zone(
    name: json?["name"] == null ? null : zoneNameValues.map[json!["name"]],
  );

  Map<String, dynamic> toJson() => {
    "name": name == null ? null : zoneNameValues.reverse[name!],
  };
}

enum ZoneName {
  CLOSED_AREA,
  CLOSED_SPACE,
  NAME_CLOSED_AREA,
  NAME_OPEN_AREA,
  OPEN_AREA,
  OPEN_SPACE
}

final zoneNameValues = EnumValues({
  "CLOSED AREA": ZoneName.CLOSED_AREA,
  "Closed Space": ZoneName.CLOSED_SPACE,
  "Closed area": ZoneName.NAME_CLOSED_AREA,
  "Open Area": ZoneName.NAME_OPEN_AREA,
  "OPEN AREA": ZoneName.OPEN_AREA,
  "Open Space": ZoneName.OPEN_SPACE
});

class DataImage {
  final String? filename;
  final String? originalFilename;
  final String? path;
  final MimeTypeEnum? mimeType;

  DataImage({
    this.filename,
    this.originalFilename,
    this.path,
    this.mimeType,
  });

  factory DataImage.fromJson(Map<String, dynamic>? json) => DataImage(
    filename: json?["Filename"],
    originalFilename: json?["OriginalFilename"],
    path: json?["path"],
    mimeType: json?["MimeType"] == null ? null : mimeTypeEnumValues.map[json!["MimeType"]],
  );

  Map<String, dynamic> toJson() => {
    "Filename": filename,
    "OriginalFilename": originalFilename,
    "path": path,
    "MimeType": mimeType == null ? null : mimeTypeEnumValues.reverse[mimeType!],
  };
}

class BranchDataImage {
  final String? filename;
  final String? originalFilename;
  final String? path;
  final MimeTypeEnum? mimeType;

  BranchDataImage({
    this.filename,
    this.originalFilename,
    this.path,
    this.mimeType,
  });

  factory BranchDataImage.fromJson(Map<String, dynamic>? json) => BranchDataImage(
    filename: json?["filename"],
    originalFilename: json?["originalFilename"],
    path: json?["path"],
    mimeType: json?["mimeType"] == null ? null : mimeTypeEnumValues.map[json!["mimeType"]],
  );

  Map<String, dynamic> toJson() => {
    "filename": filename,
    "originalFilename": originalFilename,
    "path": path,
    "mimeType": mimeType == null ? null : mimeTypeEnumValues.reverse[mimeType!],
  };
}

enum MimeTypeEnum {
  IMAGE_JPEG,
  IMAGE_PNG,
  IMAGE_WEBP
}

final mimeTypeEnumValues = EnumValues({
  "image/jpeg": MimeTypeEnum.IMAGE_JPEG,
  "image/png": MimeTypeEnum.IMAGE_PNG,
  "image/webp": MimeTypeEnum.IMAGE_WEBP
});

class Meta {
  final int? stepsCompleted;

  Meta({
    this.stepsCompleted,
  });

  factory Meta.fromJson(Map<String, dynamic>? json) => Meta(
    stepsCompleted: json?["stepsCompleted"],
  );

  Map<String, dynamic> toJson() => {
    "stepsCompleted": stepsCompleted,
  };
}

class OpeningHour {
  final String? day;
  final bool? isOpen;
  final bool? allDay;
  final String? from;
  final String? to;

  OpeningHour({
    this.day,
    this.isOpen,
    this.allDay,
    this.from,
    this.to,
  });

  factory OpeningHour.fromJson(Map<String, dynamic>? json) => OpeningHour(
    day: json?['day'],
    isOpen: json?['isOpen'],
    allDay: json?['allDay'],
    from: json?['from'],
    to: json?['to'],
  );

  Map<String, dynamic> toJson() => {
    'day': day,
    'isOpen': isOpen,
    'allDay': allDay,
    'from': from,
    'to': to,
  };
}

enum BranchStatus {
  ACTIVE,
  INACTIVE
}

final branchStatusValues = EnumValues({
  "active": BranchStatus.ACTIVE,
  "inactive": BranchStatus.INACTIVE
});

enum Tel {
  THE_911212121212,
  THE_911234567890,
  THE_911234567891,
  THE_918089473444,
  THE_918714883444,
  THE_918943524444,
  THE_919645684444
}

final telValues = EnumValues({
  "+91 1212121212": Tel.THE_911212121212,
  "+91 1234567890": Tel.THE_911234567890,
  "+91 1234567891": Tel.THE_911234567891,
  "+91 8089473444": Tel.THE_918089473444,
  "+91 8714883444": Tel.THE_918714883444,
  "+91 8943524444": Tel.THE_918943524444,
  "+91 9645684444": Tel.THE_919645684444
});

enum BranchType {
  OWN
}

final branchTypeValues = EnumValues({
  "own": BranchType.OWN
});

class Rate {
  final dynamic price;
  final dynamic effectivePrice;
  final List<Package>? packages;

  Rate({
    this.price,
    this.effectivePrice,
    this.packages,
  });

  factory Rate.fromJson(Map<String, dynamic>? json) => Rate(
    price: json?["price"] ?? 0,
    effectivePrice: json?["effectivePrice"] ?? 0,
    packages: json?["packages"] == null ? [] : List<Package>.from(json!["packages"].map((x) => Package.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "effectivePrice": effectivePrice,
    "packages": packages == null ? [] : List<dynamic>.from(packages!.map((x) => x.toJson())),
  };
}

class Package {
  final String? id;
  final PackageType? type;
  final String? name;
  final int? rate;
  final Duratin? duration;
  final int? perHourRate;

  Package({
    this.id,
    this.type,
    this.name,
    this.rate,
    this.duration,
    this.perHourRate,
  });

  factory Package.fromJson(Map<String, dynamic>? json) => Package(
    id: json?["_id"],
    type: json?["type"] == null ? null : packageTypeValues.map[json!["type"]],
    name: json?["name"],
    rate: json?["rate"],
    duration: json?["duration"] == null ? null : Duratin.fromJson(json!["duration"]),
    perHourRate: json?["perHourRate"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type == null ? null : packageTypeValues.reverse[type!],
    "name": name,
    "rate": rate,
    "duration": duration?.toJson(),
    "perHourRate": perHourRate,
  };
}

class Duratin {
  final int? value;
  final Unit? unit;

  Duratin({
    this.value,
    this.unit,
  });

  factory Duratin.fromJson(Map<String, dynamic>? json) => Duratin(
    value: json?["value"],
    unit: json?["unit"] == null ? null : unitValues.map[json!["unit"]],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "unit": unit == null ? null : unitValues.reverse[unit!],
  };
}

enum Unit {
  DAY,
  HOUR
}

final unitValues = EnumValues({
  "day": Unit.DAY,
  "hour": Unit.HOUR
});

enum PackageType {
  HOURLY
}

final packageTypeValues = EnumValues({
  "hourly": PackageType.HOURLY
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
/*

AssetData assetDataFromJson(String str) => AssetData.fromJson(json.decode(str));

String assetDataToJson(AssetData data) => json.encode(data.toJson());

class AssetData {
  String status;
  String message;
  List<Datum> data;

  AssetData({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AssetData.fromJson(Map<String, dynamic> json) => AssetData(
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
  String id;
  List<String>? aminities;
  List<DataImage> images;
  AssetType assetType;
  Branch branch;
  String description;
  String title;
  DataImage? thumbnail;
  String familyId;
  String familyTitle;
  Rate rate;
  List<DateTime> holidays;
  AvailableItems availableItems;

  Datum({
    required this.id,
    required this.aminities,
    required this.images,
    required this.assetType,
    required this.branch,
    required this.description,
    required this.title,
    this.thumbnail,
    required this.familyId,
    required this.familyTitle,
    required this.rate,
    required this.holidays,
    required this.availableItems,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
      aminities : json['aminities'].cast<String>(),
    images: List<DataImage>.from(json["images"].map((x) => DataImage.fromJson(x))),
    assetType: AssetType.fromJson(json["assetType"]),
    branch: Branch.fromJson(json["branch"]),
    description: json["description"],
    title: json["title"],
    thumbnail: json["thumbnail"] == null ? null : DataImage.fromJson(json["thumbnail"]),
    familyId: json["familyId"],
    familyTitle: json["familyTitle"],
    rate: Rate.fromJson(json["rate"]),
    holidays: List<DateTime>.from(json["holidays"].map((x) => DateTime.parse(x))),
    availableItems: AvailableItems.fromJson(json["availableItems"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "assetType": assetType.toJson(),
    "branch": branch.toJson(),
    "description": description,
    "title": title,
    "thumbnail": thumbnail?.toJson(),
    "familyId": familyId,
    "familyTitle": familyTitle,
    "rate": rate.toJson(),
    "holidays": List<dynamic>.from(holidays.map((x) => "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
    "availableItems": availableItems.toJson(),
  };
}

enum Aminity {
  HDMI,
  MIKE,
  PANTRY_ACCESS,
  SPEAKERS,
  WIFI_ACCESS
}

final aminityValues = EnumValues({
  "HDMI": Aminity.HDMI,
  "mike": Aminity.MIKE,
  "pantry access": Aminity.PANTRY_ACCESS,
  "speakers": Aminity.SPEAKERS,
  "wifi access": Aminity.WIFI_ACCESS
});

class AssetType {
  String id;
  List<dynamic> additionalInputs;
  AssetTypeStatus status;
  String title;
  String description;
  Thumbnail? thumbnail;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  AssetType({
    required this.id,
    required this.additionalInputs,
    required this.status,
    required this.title,
    required this.description,
    this.thumbnail,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory AssetType.fromJson(Map<String, dynamic> json) => AssetType(
    id: json["_id"],
    additionalInputs: List<dynamic>.from(json["additionalInputs"].map((x) => x)),
    status: assetTypeStatusValues.map[json["status"]]!,
    title: json["title"],
    description: json["description"],
    thumbnail: json["thumbnail"] == null ? null : Thumbnail.fromJson(json["thumbnail"]),
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "additionalInputs": List<dynamic>.from(additionalInputs.map((x) => x)),
    "status": assetTypeStatusValues.reverse[status],
    "title": title,
    "description": description,
    "thumbnail": thumbnail?.toJson(),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

enum AssetTypeStatus {
  ACTIVE,
  DELETED
}

final assetTypeStatusValues = EnumValues({
  "active": AssetTypeStatus.ACTIVE,
  "deleted": AssetTypeStatus.DELETED
});

class Thumbnail {
  String fileName;
  String originalFileName;
  String path;
  MimeType mimeType;

  Thumbnail({
    required this.fileName,
    required this.originalFileName,
    required this.path,
    required this.mimeType,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
    fileName: json["fileName"],
    originalFileName: json["originalFileName"],
    path: json["path"],
    mimeType: mimeTypeValues.map[json["mimeType"]]!,
  );

  Map<String, dynamic> toJson() => {
    "fileName": fileName,
    "originalFileName": originalFileName,
    "path": path,
    "mimeType": mimeTypeValues.reverse[mimeType],
  };
}

enum MimeType {
  APPLICATION_JSON,
  IMAGE_JPEG
}

final mimeTypeValues = EnumValues({
  "application/json": MimeType.APPLICATION_JSON,
  "image/jpeg": MimeType.IMAGE_JPEG
});

class AvailableItems {
  int count;
  List<Item> items;

  AvailableItems({
    required this.count,
    required this.items,
  });

  factory AvailableItems.fromJson(Map<String, dynamic> json) => AvailableItems(
    count: json["count"],
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Item {
  int tempId;
  List<Asset> assets;

  Item({
    required this.tempId,
    required this.assets,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    tempId: json["tempId"],
    assets: List<Asset>.from(json["assets"].map((x) => Asset.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "tempId": tempId,
    "assets": List<dynamic>.from(assets.map((x) => x.toJson())),
  };
}

class Asset {
  String title;
  String id;
  Availability availability;

  Asset({
    required this.title,
    required this.id,
    required this.availability,
  });

  factory Asset.fromJson(Map<String, dynamic> json) => Asset(
    title: json["title"],
    id: json["_id"],
    availability: Availability.fromJson(json["availability"]),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "_id": id,
    "availability": availability.toJson(),
  };
}

class Availability {
  DateTime start;
  DateTime end;

  Availability({
    required this.start,
    required this.end,
  });

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
    start: DateTime.parse(json["start"]),
    end: DateTime.parse(json["end"]),
  );

  Map<String, dynamic> toJson() => {
    "start": start.toIso8601String(),
    "end": end.toIso8601String(),
  };
}

class Branch {
  String id;
  List<BranchDataImage> images;
  List<OpeningHour> openingHours;
  List<FloorsAndZone> floorsAndZones;
  BranchType type;
  BranchStatus status;
  CorporateId corporateId;
  String name;
  String displayName;
  String email;
  Tel tel;
  Address address;
  String description;
  Meta meta;
  DateTime? since;
  String? website;
  int v;
  Aminities? aminities;
  double averageRating;
  int totalReviews;

  Branch({
    required this.id,
    required this.images,
    required this.openingHours,
    required this.floorsAndZones,
    required this.type,
    required this.status,
    required this.corporateId,
    required this.name,
    required this.displayName,
    required this.email,
    required this.tel,
    required this.address,
    required this.description,
    required this.meta,
    this.since,
    this.website,
    required this.v,
    this.aminities,
    required this.averageRating,
    required this.totalReviews,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json["_id"],
    images: List<BranchDataImage>.from(json["images"].map((x) => BranchDataImage.fromJson(x))),
    openingHours: List<OpeningHour>.from(json["openingHours"].map((x) => OpeningHour.fromJson(x))),
    floorsAndZones: List<FloorsAndZone>.from(json["floorsAndZones"].map((x) => FloorsAndZone.fromJson(x))),
    type: branchTypeValues.map[json["type"]]!,
    status: branchStatusValues.map[json["status"]]!,
    corporateId: corporateIdValues.map[json["corporateId"]]!,
    name: json["name"],
    displayName: json["displayName"],
    email: json["email"],
    tel: telValues.map[json["tel"]]!,
    address: Address.fromJson(json["address"]),
    description: json["description"],
    meta: Meta.fromJson(json["meta"]),
    since: json["since"] == null ? null : DateTime.parse(json["since"]),
    website: json["website"],
    v: json["__v"],
    aminities: json["aminities"] == null ? null : Aminities.fromJson(json["aminities"]),
    averageRating: json["averageRating"]?.toDouble(),
    totalReviews: json["totalReviews"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "images": List<dynamic>.from(images.map((x) => x.toJson())),

    "floorsAndZones": List<dynamic>.from(floorsAndZones.map((x) => x.toJson())),
    "type": branchTypeValues.reverse[type],
    "status": branchStatusValues.reverse[status],
    "corporateId": corporateIdValues.reverse[corporateId],
    "name": name,
    "displayName": displayName,
    "email": email,
    "tel": telValues.reverse[tel],
    "address": address.toJson(),
    "description": description,
    "meta": meta.toJson(),
    "since": since?.toIso8601String(),
    "website": website,
    "__v": v,
    "aminities": aminities?.toJson(),
    "averageRating": averageRating,
    "totalReviews": totalReviews,
  };
}

class Address {
  String name;
  String formattedAddress;
  List<AddressComponent> addressComponents;
  Location location;

  Address({
    required this.name,
    required this.formattedAddress,
    required this.addressComponents,
    required this.location,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    name: json["name"],
    formattedAddress: json["formattedAddress"],
    addressComponents: List<AddressComponent>.from(json["address_components"].map((x) => AddressComponent.fromJson(x))),
    location: Location.fromJson(json["location"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "formattedAddress": formattedAddress,
    "address_components": List<dynamic>.from(addressComponents.map((x) => x.toJson())),
    "location": location.toJson(),
  };
}

class AddressComponent {
  String longName;
  String shortName;
  List<TypeElement> types;

  AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) => AddressComponent(
    longName: json["long_name"],
    shortName: json["short_name"],
    types: List<TypeElement>.from(json["types"].map((x) => typeElementValues.map[x]!)),
  );

  Map<String, dynamic> toJson() => {
    "long_name": longName,
    "short_name": shortName,
    "types": List<dynamic>.from(types.map((x) => typeElementValues.reverse[x])),
  };
}

enum TypeElement {
  ADMINISTRATIVE_AREA_LEVEL_1,
  ADMINISTRATIVE_AREA_LEVEL_2,
  ADMINISTRATIVE_AREA_LEVEL_3,
  ADMINISTRATIVE_AREA_LEVEL_4,
  COUNTRY,
  ESTABLISHMENT,
  LANDMARK,
  LOCALITY,
  NATURAL_FEATURE,
  NEIGHBORHOOD,
  POLITICAL,
  POSTAL_CODE,
  ROUTE,
  STREET_NUMBER,
  SUBLOCALITY,
  SUBLOCALITY_LEVEL_1,
  SUBLOCALITY_LEVEL_2
}

final typeElementValues = EnumValues({
  "administrative_area_level_1": TypeElement.ADMINISTRATIVE_AREA_LEVEL_1,
  "administrative_area_level_2": TypeElement.ADMINISTRATIVE_AREA_LEVEL_2,
  "administrative_area_level_3": TypeElement.ADMINISTRATIVE_AREA_LEVEL_3,
  "administrative_area_level_4": TypeElement.ADMINISTRATIVE_AREA_LEVEL_4,
  "country": TypeElement.COUNTRY,
  "establishment": TypeElement.ESTABLISHMENT,
  "landmark": TypeElement.LANDMARK,
  "locality": TypeElement.LOCALITY,
  "natural_feature": TypeElement.NATURAL_FEATURE,
  "neighborhood": TypeElement.NEIGHBORHOOD,
  "political": TypeElement.POLITICAL,
  "postal_code": TypeElement.POSTAL_CODE,
  "route": TypeElement.ROUTE,
  "street_number": TypeElement.STREET_NUMBER,
  "sublocality": TypeElement.SUBLOCALITY,
  "sublocality_level_1": TypeElement.SUBLOCALITY_LEVEL_1,
  "sublocality_level_2": TypeElement.SUBLOCALITY_LEVEL_2
});

class Location {
  double lat;
  double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"]?.toDouble(),
    lng: json["lng"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
  };
}

class Aminities {
  bool sportsTeam;

  Aminities({
    required this.sportsTeam,
  });

  factory Aminities.fromJson(Map<String, dynamic> json) => Aminities(
    sportsTeam: json["sports_team"],
  );

  Map<String, dynamic> toJson() => {
    "sports_team": sportsTeam,
  };
}

enum CorporateId {
  THE_672603_F221332_F000_B8_D9_E8_F
}

final corporateIdValues = EnumValues({
  "672603f221332f000b8d9e8f": CorporateId.THE_672603_F221332_F000_B8_D9_E8_F
});

class FloorsAndZone {
  List<Floor> floors;
  String name;

  FloorsAndZone({
    required this.floors,
    required this.name,
  });

  factory FloorsAndZone.fromJson(Map<String, dynamic> json) => FloorsAndZone(
    floors: List<Floor>.from(json["floors"].map((x) => Floor.fromJson(x))),
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "floors": List<dynamic>.from(floors.map((x) => x.toJson())),
    "name": name,
  };
}

class Floor {
  FloorName name;
  int level;
  List<Zone> zones;

  Floor({
    required this.name,
    required this.level,
    required this.zones,
  });

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
    name: floorNameValues.map[json["name"]]!,
    level: json["level"],
    zones: List<Zone>.from(json["zones"].map((x) => Zone.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "name": floorNameValues.reverse[name],
    "level": level,
    "zones": List<dynamic>.from(zones.map((x) => x.toJson())),
  };
}

enum FloorName {
  FIRST,
  FIRST_FLOOR,
  FORTH_FLOOR,
  GF,
  GFF,
  GROUND,
  GROUND_FLOOR,
  NAME_FIRST_FLOOR,
  SECOND_FLOOR,
  THIRD_FLOOR
}

final floorNameValues = EnumValues({
  "FIRST": FloorName.FIRST,
  "First Floor": FloorName.FIRST_FLOOR,
  "Forth Floor": FloorName.FORTH_FLOOR,
  "GF": FloorName.GF,
  "GFF": FloorName.GFF,
  "GROUND": FloorName.GROUND,
  "Ground Floor": FloorName.GROUND_FLOOR,
  "FIRST FLOOR": FloorName.NAME_FIRST_FLOOR,
  "Second Floor": FloorName.SECOND_FLOOR,
  "Third Floor": FloorName.THIRD_FLOOR
});

class Zone {
  ZoneName name;

  Zone({
    required this.name,
  });

  factory Zone.fromJson(Map<String, dynamic> json) => Zone(
    name: zoneNameValues.map[json["name"]]!,
  );

  Map<String, dynamic> toJson() => {
    "name": zoneNameValues.reverse[name],
  };
}

enum ZoneName {
  CLOSED_AREA,
  CLOSED_SPACE,
  NAME_CLOSED_AREA,
  NAME_OPEN_AREA,
  OPEN_AREA,
  OPEN_SPACE
}

final zoneNameValues = EnumValues({
  "CLOSED AREA": ZoneName.CLOSED_AREA,
  "Closed Space": ZoneName.CLOSED_SPACE,
  "Closed area": ZoneName.NAME_CLOSED_AREA,
  "Open Area": ZoneName.NAME_OPEN_AREA,
  "OPEN AREA": ZoneName.OPEN_AREA,
  "Open Space": ZoneName.OPEN_SPACE
});

class DataImage {
  String filename;
  String originalFilename;
  String path;
  MimeTypeEnum mimeType;

  DataImage({
    required this.filename,
    required this.originalFilename,
    required this.path,
    required this.mimeType,
  });

  factory DataImage.fromJson(Map<String, dynamic> json) => DataImage(
    filename: json["Filename"],
    originalFilename: json["OriginalFilename"],
    path: json["path"],
    mimeType: mimeTypeEnumValues.map[json["MimeType"]]!,
  );

  Map<String, dynamic> toJson() => {
    "Filename": filename,
    "OriginalFilename": originalFilename,
    "path": path,
    "MimeType": mimeTypeEnumValues.reverse[mimeType],
  };
}

enum MimeTypeEnum {
  IMAGE_JPEG,
  IMAGE_PNG,
  IMAGE_WEBP
}

final mimeTypeEnumValues = EnumValues({
  "image/jpeg": MimeTypeEnum.IMAGE_JPEG,
  "image/png": MimeTypeEnum.IMAGE_PNG,
  "image/webp": MimeTypeEnum.IMAGE_WEBP
});

class Meta {
  int stepsCompleted;

  Meta({
    required this.stepsCompleted,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    stepsCompleted: json["stepsCompleted"],
  );

  Map<String, dynamic> toJson() => {
    "stepsCompleted": stepsCompleted,
  };
}




class OpeningHour {
  String? day;
  bool? isOpen;
  bool? allDay;
  String? from;
  String? to;

  OpeningHour({this.day, this.isOpen, this.allDay, this.from, this.to});

  OpeningHour.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    isOpen = json['isOpen'];
    allDay = json['allDay'];
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['isOpen'] = this.isOpen;
    data['allDay'] = this.allDay;
    data['from'] = this.from;
    data['to'] = this.to;
    return data;
  }
}
enum BranchStatus {
  ACTIVE,
  INACTIVE
}

final branchStatusValues = EnumValues({
  "active": BranchStatus.ACTIVE,
  "inactive": BranchStatus.INACTIVE
});

enum Tel {
  THE_911212121212,
  THE_911234567890,
  THE_911234567891,
  THE_918089473444,
  THE_918714883444,
  THE_918943524444,
  THE_919645684444
}

final telValues = EnumValues({
  "+91 1212121212": Tel.THE_911212121212,
  "+91 1234567890": Tel.THE_911234567890,
  "+91 1234567891": Tel.THE_911234567891,
  "+91 8089473444": Tel.THE_918089473444,
  "+91 8714883444": Tel.THE_918714883444,
  "+91 8943524444": Tel.THE_918943524444,
  "+91 9645684444": Tel.THE_919645684444
});

enum BranchType {
  OWN
}

final branchTypeValues = EnumValues({
  "own": BranchType.OWN
});

class Rate {
  dynamic? price;
  dynamic? effectivePrice;
  List<Package>? packages;
  Rate({
   this.price,
    required this.effectivePrice,
    this.packages
  });

  factory Rate.fromJson(Map<String, dynamic> json) => Rate(
    price: json["price"]??0,
    effectivePrice: json["effectivePrice"]??0,
    packages: List<Package>.from(json["packages"].map((x) => Package.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "effectivePrice": effectivePrice,
  };
}
class Package {
  String id;
  PackageType type;
  String name;
  int rate;
  Duratin duration;
  int perHourRate;

  Package({
    required this.id,
    required this.type,
    required this.name,
    required this.rate,
    required this.duration,
    required this.perHourRate,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
    id: json["_id"],
    type: packageTypeValues.map[json["type"]]!,
    name: json["name"],
    rate: json["rate"],
    duration: Duratin.fromJson(json["duration"]),
    perHourRate: json["perHourRate"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": packageTypeValues.reverse[type],
    "name": name,
    "rate": rate,
    "duration": duration.toJson(),
    "perHourRate": perHourRate,
  };
}
class BranchDataImage {
  String filename;
  String originalFilename;
  String path;
  MimeTypeEnum mimeType;

  BranchDataImage({
    required this.filename,
    required this.originalFilename,
    required this.path,
    required this.mimeType,
  });

  factory BranchDataImage.fromJson(Map<String, dynamic> json) => BranchDataImage(
    filename: json["filename"],
    originalFilename: json["originalFilename"],
    path: json["path"],
    mimeType: mimeTypeEnumValues.map[json["mimeType"]]!,
  );

  Map<String, dynamic> toJson() => {
    "filename": filename,
    "originalFilename": originalFilename,
    "path": path,
    "mimeType": mimeTypeEnumValues.reverse[mimeType],
  };
}
class Duratin {
  int value;
  String unit;

  Duratin({
    required this.value,
    required this.unit,
  });

  factory Duratin.fromJson(Map<String, dynamic> json) => Duratin(
    value: json["value"],
    unit: json["unit"]!,
  );

  Map<String, dynamic> toJson() => {
    "value": value,

  };
}



enum PackageType {
  HOURLY
}

final packageTypeValues = EnumValues({
  "hourly": PackageType.HOURLY
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

*/












