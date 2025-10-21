import 'dart:convert';
NotifyVO NotifyVOFromJson(String str) => NotifyVO.fromJson(json.decode(str));
String NotifyVOToJson(NotifyVO data) => json.encode(data.toJson());

class NotifyVO {
  String id;
  String type;
  String refId;
  String pictureId;
  String content;
  int readStatus;
  int createTime;
  String pictureUrl;
  dynamic actorId;
  dynamic actorName;
  dynamic actorAvatar;

  NotifyVO({
    required this.id,
    required this.type,
    required this.refId,
    required this.pictureId,
    required this.content,
    required this.readStatus,
    required this.createTime,
    required this.pictureUrl,
    required this.actorId,
    required this.actorName,
    required this.actorAvatar,
  });

  factory NotifyVO.fromJson(Map<String, dynamic> json) => NotifyVO(
    id: json["id"],
    type: json["type"],
    refId: json["refId"]??"",
    pictureId: json["pictureId"],
    content: json["content"],
    readStatus: json["readStatus"],
    createTime: json["createTime"],
    pictureUrl: json["pictureUrl"],
    actorId: json["actorId"],
    actorName: json["actorName"],
    actorAvatar: json["actorAvatar"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "refId": refId,
    "pictureId": pictureId,
    "content": content,
    "readStatus": readStatus,
    "createTime": createTime,
    "pictureUrl": pictureUrl,
    "actorId": actorId,
    "actorName": actorName,
    "actorAvatar": actorAvatar,
  };
}
