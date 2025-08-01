class ReviewModel {
  String? status;
  bool? success;
  List<ReviewData>? data;

  ReviewModel({this.status, this.success, this.data});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <ReviewData>[];
      json['data'].forEach((v) {
        data!.add(new ReviewData.fromJson(v));
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

class ReviewData {
  String? userType;
  String? sId;
  String? review;
  int? rating;
  User? user;
  String? branch;
  String? createdAt;
  String? updatedAt;

  ReviewData(
      {this.userType,
        this.sId,
        this.review,
        this.rating,
        this.user,
        this.branch,
        this.createdAt,
        this.updatedAt});

  ReviewData.fromJson(Map<String, dynamic> json) {
    userType = json['userType'];
    sId = json['_id'];
    review = json['review'];
    rating = json['rating'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    branch = json['branch'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userType'] = this.userType;
    data['_id'] = this.sId;
    data['review'] = this.review;
    data['rating'] = this.rating;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['branch'] = this.branch;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class User {
  String? name;
  String? sId;

  User({this.name, this.sId});

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['_id'] = this.sId;
    return data;
  }
}