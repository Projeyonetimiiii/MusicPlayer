class ConvertResult {
  String? status;
  String? mess;
  String? cStatus;
  String? vid;
  String? title;
  String? ftype;
  String? fquality;
  String? dlink;

  ConvertResult(
      {this.status,
      this.mess,
      this.cStatus,
      this.vid,
      this.title,
      this.ftype,
      this.fquality,
      this.dlink});

  ConvertResult.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    mess = json['mess'];
    cStatus = json['c_status'];
    vid = json['vid'];
    title = json['title'];
    ftype = json['ftype'];
    fquality = json['fquality'];
    dlink = json['dlink'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['mess'] = this.mess;
    data['c_status'] = this.cStatus;
    data['vid'] = this.vid;
    data['title'] = this.title;
    data['ftype'] = this.ftype;
    data['fquality'] = this.fquality;
    data['dlink'] = this.dlink;
    return data;
  }
}
