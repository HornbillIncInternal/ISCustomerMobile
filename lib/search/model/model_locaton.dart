class BranchLocationModel {
  String? status;
  String? message;
  List<BranchLocationData>? data;

  BranchLocationModel({this.status, this.message, this.data});

  BranchLocationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BranchLocationData>[];
      json['data'].forEach((v) {
        data!.add(new BranchLocationData.fromJson(v));
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

class BranchLocationData {
  List<Images>? images;
  List<OpeningHours>? openingHours;

  String? type;
  String? status;
  String? sId;
  String? corporateId;
  String? name;
  String? displayName;
  String? email;
  String? tel;
  Address? address;
  String? description;
  Meta? meta;
  String? since;
  int? iV;
  Aminities? aminities;

  BranchLocationData(
      {this.images,
        this.openingHours,

        this.type,
        this.status,
        this.sId,
        this.corporateId,
        this.name,
        this.displayName,
        this.email,
        this.tel,
        this.address,
        this.description,
        this.meta,
        this.since,
        this.iV,
        this.aminities});

  BranchLocationData.fromJson(Map<String, dynamic> json) {
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(new Images.fromJson(v));
      });
    }
    if (json['openingHours'] != null) {
      openingHours = <OpeningHours>[];
      json['openingHours'].forEach((v) {
        openingHours!.add(new OpeningHours.fromJson(v));
      });
    }

    type = json['type'];
    status = json['status'];
    sId = json['_id'];
    corporateId = json['corporateId'];
    name = json['name'];
    displayName = json['displayName'];
    email = json['email'];
    tel = json['tel'];
    address =
    json['address'] != null ? new Address.fromJson(json['address']) : null;
    description = json['description'];
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
    since = json['since'];
    iV = json['__v'];
    aminities = json['aminities'] != null
        ? new Aminities.fromJson(json['aminities'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }
    if (this.openingHours != null) {
      data['openingHours'] = this.openingHours!.map((v) => v.toJson()).toList();
    }

    data['type'] = this.type;
    data['status'] = this.status;
    data['_id'] = this.sId;
    data['corporateId'] = this.corporateId;
    data['name'] = this.name;
    data['displayName'] = this.displayName;
    data['email'] = this.email;
    data['tel'] = this.tel;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['description'] = this.description;
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    data['since'] = this.since;
    data['__v'] = this.iV;
    if (this.aminities != null) {
      data['aminities'] = this.aminities!.toJson();
    }
    return data;
  }
}

class Images {
  String? filename;
  String? originalFilename;
  String? path;
  String? mimeType;

  Images({this.filename, this.originalFilename, this.path, this.mimeType});

  Images.fromJson(Map<String, dynamic> json) {
    filename = json['Filename'];
    originalFilename = json['OriginalFilename'];
    path = json['path'];
    mimeType = json['MimeType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Filename'] = this.filename;
    data['OriginalFilename'] = this.originalFilename;
    data['path'] = this.path;
    data['MimeType'] = this.mimeType;
    return data;
  }
}

class OpeningHours {
  String? day;
  bool? isOpen;
  bool? allDay;
  String? from;
  String? to;

  OpeningHours({this.day, this.isOpen, this.allDay, this.from, this.to});

  OpeningHours.fromJson(Map<String, dynamic> json) {
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





class Address {
  String? name;
  String? formattedAddress;
  List<AddressComponents>? addressComponents;
  Location? location;

  Address(
      {this.name,
        this.formattedAddress,
        this.addressComponents,
        this.location});

  Address.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    formattedAddress = json['formattedAddress'];
    if (json['address_components'] != null) {
      addressComponents = <AddressComponents>[];
      json['address_components'].forEach((v) {
        addressComponents!.add(new AddressComponents.fromJson(v));
      });
    }
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['formattedAddress'] = this.formattedAddress;
    if (this.addressComponents != null) {
      data['address_components'] =
          this.addressComponents!.map((v) => v.toJson()).toList();
    }
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    return data;
  }
}

class AddressComponents {
  String? longName;
  String? shortName;
  List<String>? types;

  AddressComponents({this.longName, this.shortName, this.types});

  AddressComponents.fromJson(Map<String, dynamic> json) {
    longName = json['long_name'];
    shortName = json['short_name'];
    types = json['types'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['long_name'] = this.longName;
    data['short_name'] = this.shortName;
    data['types'] = this.types;
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

class Meta {
  int? stepsCompleted;

  Meta({this.stepsCompleted});

  Meta.fromJson(Map<String, dynamic> json) {
    stepsCompleted = json['stepsCompleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stepsCompleted'] = this.stepsCompleted;
    return data;
  }
}

class Aminities {
  bool? wifi;
  bool? ac;
  bool? events;
  bool? sportsTeam;
  bool? standingDesk;

  Aminities(
      {this.wifi, this.ac, this.events, this.sportsTeam, this.standingDesk});

  Aminities.fromJson(Map<String, dynamic> json) {
    wifi = json['wifi'];
    ac = json['ac'];
    events = json['events'];
    sportsTeam = json['sports_team'];
    standingDesk = json['standing_desk'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wifi'] = this.wifi;
    data['ac'] = this.ac;
    data['events'] = this.events;
    data['sports_team'] = this.sportsTeam;
    data['standing_desk'] = this.standingDesk;
    return data;
  }
}