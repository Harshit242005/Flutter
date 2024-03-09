// user.dart
import 'package:hive/hive.dart';

part 'user.g.dart'; // This file will be generated by build_runner

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String base64Image;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String passwordHash;

  // Constructor for easy initialization
  User({
    required this.email,
    required this.passwordHash,
    required this.base64Image,
  });
}