class AssetTypeModel {
  String? status;
  String? message;
  List<AssetTypeModelData>? data;

  AssetTypeModel({this.status, this.message, this.data});

  AssetTypeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AssetTypeModelData>[];
      json['data'].forEach((v) {
        data!.add(new AssetTypeModelData.fromJson(v));
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

class AssetTypeModelData {
  String? sId;
  List<String>? additionalInputs;
  String? status;
  String? title;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? iV;
  Thumbnail? thumbnail;

  AssetTypeModelData(
      {this.sId,
        this.additionalInputs,
        this.status,
        this.title,
        this.description,
        this.createdAt,
        this.updatedAt,
        this.iV,
        this.thumbnail});

  AssetTypeModelData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    additionalInputs = json['additionalInputs'].cast<String>();
    status = json['status'];
    title = json['title'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    thumbnail = json['thumbnail'] != null
        ? new Thumbnail.fromJson(json['thumbnail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['additionalInputs'] = this.additionalInputs;
    data['status'] = this.status;
    data['title'] = this.title;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.thumbnail != null) {
      data['thumbnail'] = this.thumbnail!.toJson();
    }
    return data;
  }
}

class Thumbnail {
  String? fileName;
  String? originalFileName;
  String? path;
  String? mimeType;

  Thumbnail({this.fileName, this.originalFileName, this.path, this.mimeType});

  Thumbnail.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    originalFileName = json['originalFileName'];
    path = json['path'];
    mimeType = json['mimeType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileName'] = this.fileName;
    data['originalFileName'] = this.originalFileName;
    data['path'] = this.path;
    data['mimeType'] = this.mimeType;
    return data;
  }
}