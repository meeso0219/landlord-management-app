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

  Future<void> syncLeaseExpirationNotifications(List<UnitLease> leases) async {
    for (final lease in leases) {
      await syncLeaseExpirationNotification(lease);
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

  Future<void> syncLeaseExpirationNotification(UnitLease lease) async {
    await cancelLeaseExpirationNotificationsByLeaseId(lease.id);

    final sevenDaysBefore = DateTime(
      lease.leaseEnd.year,
      lease.leaseEnd.month,
      lease.leaseEnd.day - 7,
      9,
    );
    final onLeaseEnd = DateTime(
      lease.leaseEnd.year,
      lease.leaseEnd.month,
      lease.leaseEnd.day,
      9,
    );

    if (sevenDaysBefore.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        _leaseExpirationSoonNotificationIdForLease(lease.id),
        '계약 만료 7일 전',
        '${lease.buildingName} ${lease.unitNo} 계약 만료가 7일 남았습니다.',
        tz.TZDateTime.from(sevenDaysBefore, tz.local),
        _leaseExpirationNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (onLeaseEnd.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        _leaseExpirationDayNotificationIdForLease(lease.id),
        '계약 만료일 안내',
        '${lease.buildingName} ${lease.unitNo} 계약이 오늘 만료됩니다.',
        tz.TZDateTime.from(onLeaseEnd, tz.local),
        _leaseExpirationNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelFollowUpNotificationByLeaseId(String leaseId) {
    return _notifications.cancel(_notificationIdForLease(leaseId));
  }

  Future<void> cancelLeaseExpirationNotificationsByLeaseId(String leaseId) {
    return Future.wait([
      _notifications
          .cancel(_leaseExpirationSoonNotificationIdForLease(leaseId)),
      _notifications.cancel(_leaseExpirationDayNotificationIdForLease(leaseId)),
    ]);
  }

  int _notificationIdForLease(String leaseId) {
    return leaseId.hashCode & 0x7fffffff;
  }

  int _leaseExpirationSoonNotificationIdForLease(String leaseId) {
    return (leaseId.hashCode & 0x3fffffff) + 1000000000;
  }

  int _leaseExpirationDayNotificationIdForLease(String leaseId) {
    return (leaseId.hashCode & 0x3fffffff) + 1500000000;
  }

  NotificationDetails get _leaseExpirationNotificationDetails {
    const androidDetails = AndroidNotificationDetails(
      'lease_expiration_notifications',
      '계약 만료 알림',
      channelDescription: '계약 만료 일정을 알려주는 알림입니다.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }
}
