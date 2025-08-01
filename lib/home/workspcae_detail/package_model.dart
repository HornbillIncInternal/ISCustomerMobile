class PackageModel {
  String? status;
  bool? success;
  List<PackageData>? data;

  PackageModel({this.status, this.success, this.data});

  PackageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <PackageData>[];
      json['data'].forEach((v) {
        data!.add(new PackageData.fromJson(v));
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

class PackageData {
  String? familyId;
  String? familyTitle;
  String? fromDate;
  String? toDate;
  AvlblItems? availableItems;

  PackageData(
      {this.familyId,
        this.familyTitle,
        this.fromDate,
        this.toDate,
        this.availableItems});

  PackageData.fromJson(Map<String, dynamic> json) {
    familyId = json['familyId'];
    familyTitle = json['familyTitle'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    availableItems = json['availableItems'] != null
        ? new AvlblItems.fromJson(json['availableItems'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['familyId'] = this.familyId;
    data['familyTitle'] = this.familyTitle;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    if (this.availableItems != null) {
      data['availableItems'] = this.availableItems!.toJson();
    }
    return data;
  }
}

class AvlblItems {
  int? count;
  List<Items>? items;

  AvlblItems({this.count, this.items});

  AvlblItems.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
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

class Items {
  int? tempId;
  List<Assets>? assets;

  Items({this.tempId, this.assets});

  Items.fromJson(Map<String, dynamic> json) {
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
