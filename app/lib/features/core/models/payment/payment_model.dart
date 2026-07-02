class PaymentModel {
  bool? status;
  String? message;
  Data? data;

  PaymentModel({this.status, this.message, this.data});

  PaymentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  WebSetting? webSetting;
  List<PaymentGateway>? paymentGateway;

  Data({this.webSetting, this.paymentGateway});

  Data.fromJson(Map<String, dynamic> json) {
    webSetting = json['web_setting'] != null
        ? WebSetting.fromJson(json['web_setting'])
        : null;
    if (json['payment_gateway'] != null) {
      paymentGateway = <PaymentGateway>[];
      json['payment_gateway'].forEach((v) {
        paymentGateway!.add(PaymentGateway.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (webSetting != null) {
      data['web_setting'] = webSetting!.toJson();
    }
    if (paymentGateway != null) {
      data['payment_gateway'] = paymentGateway!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WebSetting {
  String? themeName;
  String? version;
  Null appName;
  Null address;
  Null phone;
  Null email;
  bool? subscription;
  String? currency;
  String? favicon;
  String? logo;

  WebSetting(
      {this.themeName,
      this.version,
      this.appName,
      this.address,
      this.phone,
      this.email,
      this.subscription,
      this.currency,
      this.favicon,
      this.logo});

  WebSetting.fromJson(Map<String, dynamic> json) {
    themeName = json['theme_name'];
    version = json['version'];
    appName = json['app_name'];
    address = json['address'];
    phone = json['phone'];
    email = json['email'];
    subscription = json['subscription'];
    currency = json['currency'];
    favicon = json['favicon'];
    logo = json['logo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['theme_name'] = themeName;
    data['version'] = version;
    data['app_name'] = appName;
    data['address'] = address;
    data['phone'] = phone;
    data['email'] = email;
    data['subscription'] = subscription;
    data['currency'] = currency;
    data['favicon'] = favicon;
    data['logo'] = logo;
    return data;
  }
}

class PaymentGateway {
  String? name;
  String? thumbnail;

  PaymentGateway({this.name, this.thumbnail});

  PaymentGateway.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['thumbnail'] = thumbnail;
    return data;
  }
}
