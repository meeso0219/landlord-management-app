import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:landlord_management_app/models/unit_lease.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _configureLocalTimeZone();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final macPlugin = _notifications.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    await macPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> syncFollowUpNotifications(List<UnitLease> leases) async {
    for (final lease in leases) {
      await syncFollowUpNotification(lease);
    }
  }

  Future<void> syncFollowUpNotification(UnitLease lease) async {
    final nextContactDate = lease.nextContactDate;
    if (nextContactDate == null) {
      await cancelFollowUpNotificationByLeaseId(lease.id);
      return;
    }

    final scheduledAt = DateTime(
      nextContactDate.year,
      nextContactDate.month,
      nextContactDate.day,
      9,
    );

    if (!scheduledAt.isAfter(DateTime.now())) {
      await cancelFollowUpNotificationByLeaseId(lease.id);
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'follow_up_notifications',
      '연락 일정 알림',
      channelDescription: '세입자 연락 일정을 알려주는 알림입니다.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _notificationIdForLease(lease.id),
      '오늘 연락 일정',
      '${lease.buildingName} ${lease.unitNo} ${lease.tenantName}님께 연락할 시간입니다.',
      tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelFollowUpNotificationByLeaseId(String leaseId) {
    return _notifications.cancel(_notificationIdForLease(leaseId));
  }

  int _notificationIdForLease(String leaseId) {
    return leaseId.hashCode & 0x7fffffff;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}
