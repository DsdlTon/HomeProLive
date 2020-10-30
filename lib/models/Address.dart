class Address {
  int id;
  String firstname;
  String lastname;
  String phone;
  String type;
  String homeNo;
  String roomNo;
  String floor;
  String villageCondoname;
  String moo;
  String soi;
  String street;
  String province;
  String district;
  String subDistrict;
  String createdAt;
  String updatedAt;
  int userId;

  Address(
      {this.id,
      this.firstname,
      this.lastname,
      this.phone,
      this.type,
      this.homeNo,
      this.roomNo,
      this.floor,
      this.villageCondoname,
      this.moo,
      this.soi,
      this.street,
      this.province,
      this.district,
      this.subDistrict,
      this.createdAt,
      this.updatedAt,
      this.userId});

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    phone = json['phone'];
    type = json['type'];
    homeNo = json['homeNo'];
    roomNo = json['roomNo'];
    floor = json['floor'];
    villageCondoname = json['village_condoname'];
    moo = json['moo'];
    soi = json['soi'];
    street = json['street'];
    province = json['province'];
    district = json['district'];
    subDistrict = json['sub_district'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['firstname'] = this.firstname;
    data['lastname'] = this.lastname;
    data['phone'] = this.phone;
    data['type'] = this.type;
    data['homeNo'] = this.homeNo;
    data['roomNo'] = this.roomNo;
    data['floor'] = this.floor;
    data['village_condoname'] = this.villageCondoname;
    data['moo'] = this.moo;
    data['soi'] = this.soi;
    data['street'] = this.street;
    data['province'] = this.province;
    data['district'] = this.district;
    data['sub_district'] = this.subDistrict;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['user_id'] = this.userId;
    return data;
  }
}
