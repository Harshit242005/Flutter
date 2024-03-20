// user.dart
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class UserData extends HiveObject {
  @HiveField(0)
  late String uid;

  @HiveField(1)
  late String email;

  // Constructor for easy initialization
  UserData({
    required this.uid,
    required this.email,
  });
}
