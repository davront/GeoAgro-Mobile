import 'dart:convert';

class Comment {
  final int id;
  final String body;
  final String createdAt;
  final CreatedBy? createdBy;
  final bool isModeration;
  final String? image;
  final String? action;

  Comment({
    required this.id,
    required this.body,
    required this.createdAt,
    this.createdBy,
    required this.isModeration,
    this.image,
    this.action,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"] as int,
        body: json["body"] as String,
        createdAt: json["created_at"] as String,
        createdBy: json["created_by"] == null
            ? null
            : CreatedBy.fromJson(json["created_by"] as Map<String, dynamic>),
        isModeration: json["is_moderation"] as bool? ?? false,
        image: json["image"] as String?,
        action: json["action"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "body": body,
        "created_at": createdAt,
        "created_by": createdBy?.toJson(),
        "is_moderation": isModeration,
        "image": image,
        "action": action,
      };
}

class CreatedBy {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;

  CreatedBy({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["id"] as int,
        username: json["username"] as String,
        firstName: json["first_name"] as String?,
        lastName: json["last_name"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "first_name": firstName,
        "last_name": lastName,
      };

  String get fullName {
    if (firstName != null && lastName != null) {
      return "$firstName $lastName";
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }
}

List<Comment> commentsFromJson(String str) =>
    List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentsToJson(List<Comment> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

