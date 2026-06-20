import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class AppNotification {
  final int id;
  final String title;
  final String? body;
  final bool isRead;
  AppNotification({required this.id, required this.title, this.body, required this.isRead});
  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'], title: j['title'], body: j['body'], isRead: j['isRead'] == true);
}

final notificationRepositoryProvider =
    Provider((ref) => NotificationRepository(ref.read(dioProvider)));

final notificationsProvider = FutureProvider<List<AppNotification>>(
    (ref) => ref.read(notificationRepositoryProvider).list());

class NotificationRepository {
  final Dio _dio;
  NotificationRepository(this._dio);

  Future<List<AppNotification>> list() async {
    final res = await _dio.get('/notifications');
    return (res.data['data'] as List).map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> markAllRead() => _dio.put('/notifications/read-all');
}
