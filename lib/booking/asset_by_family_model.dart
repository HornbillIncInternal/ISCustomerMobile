class AssetByFamilyIdModel {
  String? status;
  bool? success;
  List<Data>? data;

  AssetByFamilyIdModel({this.status, this.success, this.data});

  AssetByFamilyIdModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? familyId;
  String? familyTitle;
  AvailableItemsF? availableItems;

  Data({this.familyId, this.familyTitle, this.availableItems});

  Data.fromJson(Map<String, dynamic> json) {
    familyId = json['familyId'];
    familyTitle = json['familyTitle'];
    availableItems = json['availableItems'] != null
        ? new AvailableItemsF.fromJson(json['availableItems'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['familyId'] = this.familyId;
    data['familyTitle'] = this.familyTitle;
    if (this.availableItems != null) {
      data['availableItems'] = this.availableItems!.toJson();
    }
    return data;
  }
}

class AvailableItemsF {
  int? count;
  List<AvailableItemsByFamily>? items;

  AvailableItemsF({this.count, this.items});

  AvailableItemsF.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['items'] != null) {
      items = <AvailableItemsByFamily>[];
      json['items'].forEach((v) {
        items!.add(new AvailableItemsByFamily.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvailableItemsByFamily {
  int? tempId;
  List<Assets>? assets;

  AvailableItemsByFamily({this.tempId, this.assets});

  AvailableItemsByFamily.fromJson(Map<String, dynamic> json) {
    tempId = json['tempId'];
    if (json['assets'] != null) {
      assets = <Assets>[];
      json['assets'].forEach((v) {
        assets!.add(new Assets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tempId'] = this.tempId;
    if (this.assets != null) {
      data['assets'] = this.assets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Assets {
  String? title;
  String? sId;
  Availability? availability;

  Assets({this.title, this.sId, this.availability});

  Assets.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    sId = json['_id'];
    availability = json['availability'] != null
        ? new Availability.fromJson(json['availability'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['_id'] = this.sId;
    if (this.availability != null) {
      data['availability'] = this.availability!.toJson();
    }
    return data;
  }
}

class Availability {
  String? start;
  String? end;

  Availability({this.start, this.end});

  Availability.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start'] = this.start;
    data['end'] = this.end;
    return data;
  }
}
