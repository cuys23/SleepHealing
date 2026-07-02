class PaymentUrlModel {
  String? message;
  Data? data;

  PaymentUrlModel({this.message, this.data});

  PaymentUrlModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? redirectUrl;

  Data({this.redirectUrl});

  Data.fromJson(Map<String, dynamic> json) {
    redirectUrl = json['redirectUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['redirectUrl'] = redirectUrl;
    return data;
  }
}
