class ItemTask {
  final String itemTitle;
  final DateTime itemDatetime;
  final String itemDesc;
  final String itemTags;
  final String itemStatus;
  final String userUid;

  ItemTask(
      {required this.userUid,
      required this.itemTitle,
      required this.itemDesc,
      required this.itemDatetime,
      required this.itemTags,
      required this.itemStatus});

  Map<String, dynamic> toJson() {
    return {
      "userUid": userUid,
      "title": itemTitle,
      "datetime": itemDatetime,
      "desc": itemDesc,
      "tags": itemTags,
      "status": itemStatus,
    };
  }

  factory ItemTask.fromJson(Map<String, dynamic> json) {
    return ItemTask(
        userUid: json['userUid'],
        itemTitle: json['title'],
        itemDatetime: json['datetime'],
        itemDesc: json['desc'],
        itemTags: json['tags'],
        itemStatus: json['staus']);
  }
}
