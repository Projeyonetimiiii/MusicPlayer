class SearchVideo {
  String? status;
  String? mess;
  String? p;
  String? vid;
  String? title;
  int? t;
  String? a;
  List<Link>? links;

  SearchVideo(
      {this.status,
      this.mess,
      this.p,
      this.vid,
      this.title,
      this.t,
      this.a,
      this.links});

  SearchVideo.fromJson(Map json) {
    status = json['status'];
    mess = json['mess'];
    p = json['p'];
    vid = json['vid'];
    title = json['title'];
    t = json['t'];
    a = json['a'];
    links = json['links'] != null ? _getLinks(json['links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['mess'] = this.mess;
    data['p'] = this.p;
    data['vid'] = this.vid;
    data['title'] = this.title;
    data['t'] = this.t;
    data['a'] = this.a;
    if (this.links != null) {
      data['links'] = this.links!;
    }
    return data;
  }
}

List<Link> _getLinks(Map map) {
  return map.keys.map((e) {
    return Link(title: e, datas: _getLinkDatas(map[e]));
  }).toList();
}

List<LinkData> _getLinkDatas(Map map) {
  return map.keys.map((e) {
    return LinkData(title: e, datas: _getDatas(map[e]));
  }).toList();
}

Data _getDatas(Map map) {
  return Data.fromJson(map);
}

class Link {
  String title;
  List<LinkData> datas;
  Link({
    required this.title,
    required this.datas,
  });
}

class Data {
  String? size;
  String? f;
  String? q;
  String? k;
  Data({
    this.size,
    this.f,
    this.q,
    this.k,
  });

  Data.fromJson(Map json) {
    size = json['size'];
    f = json['f'];
    q = json['q'];
    k = json['k'];
  }
}

class LinkData {
  String title;
  Data datas;
  LinkData({
    required this.title,
    required this.datas,
  });
}
