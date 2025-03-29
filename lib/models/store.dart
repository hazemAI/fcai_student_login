import 'package:hive/hive.dart';

part 'store.g.dart';

@HiveType(typeId: 1)
class Store {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  Store({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });
} 