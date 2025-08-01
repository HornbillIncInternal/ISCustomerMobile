class BlockAssetModel {
  String? status;
  String? message;
  List<BlockData>? data;

  BlockAssetModel({this.status, this.message, this.data});

  BlockAssetModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BlockData>[];
      json['data'].forEach((v) {
        data!.add(new BlockData.fromJson(v));
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

class BlockData {
  String? status;

  String? sId;
  String? assetId;
  String? fromDate;
  String? toDate;
  String? bookedBy;
  String? bookingBy;
  int? iV;
  String? createdAt;
  String? updatedAt;

  BlockData(
      {this.status,

        this.sId,
        this.assetId,
        this.fromDate,
        this.toDate,
        this.bookedBy,
        this.bookingBy,
        this.iV,
        this.createdAt,
        this.updatedAt});

  BlockData.fromJson(Map<String, dynamic> json) {
    status = json['status'];

    sId = json['_id'];
    assetId = json['assetId'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    bookedBy = json['bookedBy'];
    bookingBy = json['bookingBy'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;

    data['_id'] = this.sId;
    data['assetId'] = this.assetId;
    data['fromDate'] = this.fromDate;
    data['toDate'] = this.toDate;
    data['bookedBy'] = this.bookedBy;
    data['bookingBy'] = this.bookingBy;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}