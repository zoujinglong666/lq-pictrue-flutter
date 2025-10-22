import 'dart:convert';
NotifyVO NotifyVOFromJson(String str) => NotifyVO.fromJson(json.decode(str));
String NotifyVOToJson(NotifyVO data) => json.encode(data.toJson());

class NotifyVO {
  int id;
  String type;
  int refId;
  int pictureId;
  String content;
  int readStatus;
  int createTime;
  String? pictureUrl;
  int? actorId;
  String? actorName;
  String? actorAvatar;

  NotifyVO({
    required this.id,
    required this.type,
    required this.refId,
    required this.pictureId,
    required this.content,
    required this.readStatus,
    required this.createTime,
    this.pictureUrl,
    this.actorId,
    this.actorName,
    this.actorAvatar,
  });

  factory NotifyVO.fromJson(Map<String, dynamic> json) => NotifyVO(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
    type: json["type"]?.toString() ?? '',
    refId: json["refId"] is int ? json["refId"] : int.tryParse(json["refId"]?.toString() ?? '0') ?? 0,
    pictureId: json["pictureId"] is int ? json["pictureId"] : int.tryParse(json["pictureId"]?.toString() ?? '0') ?? 0,
    content: json["content"]?.toString() ?? '',
    readStatus: json["readStatus"] is int ? json["readStatus"] : int.tryParse(json["readStatus"]?.toString() ?? '0') ?? 0,
    createTime: json["createTime"] is int ? json["createTime"] : int.tryParse(json["createTime"]?.toString() ?? '0') ?? 0,
    pictureUrl: json["pictureUrl"]?.toString(),
    actorId: json["actorId"] is int ? json["actorId"] : int.tryParse(json["actorId"]?.toString() ?? ''),
    actorName: json["actorName"]?.toString(),
    actorAvatar: json["actorAvatar"]?.toString(),
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
