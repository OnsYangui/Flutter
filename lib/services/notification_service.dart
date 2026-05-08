import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/medication_model.dart';
import '../models/consultation_model.dart';
import '../models/vital_sign_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions for Android 13+
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleMedicationReminder(Medication medication) async {
    // First, cancel any existing reminders for this medication to avoid duplicates
    await cancelMedicationReminders(medication.id);

    for (int i = 0; i < medication.times.length; i++) {
      DateTime time = medication.times[i];
      final scheduledDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );

      final finalDate = scheduledDate.isAfter(DateTime.now())
          ? scheduledDate
          : scheduledDate.add(const Duration(days: 1));

      // Notification ID is a combination of medication hash and index of time
      final int notificationId = medication.id.hashCode + i;

      await _localNotifications.zonedSchedule(
        notificationId,
        '💊 Rappel médicament',
        'C\'est l\'heure de prendre : ${medication.name} (${medication.dosage})',
        tz.TZDateTime.from(finalDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Rappels de médicaments',
            channelDescription:
                'Notifications pour les rappels de prise de médicaments',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'medication_${medication.id}',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.time, // Repeat daily at this time
      );
    }
  }

  Future<void> cancelMedicationReminders(String medicationId) async {
    // We can't easily find notifications by payload, but we used hashCode + index
    // For simplicity, we cancel the first 10 possible indices for that hash
    for (int i = 0; i < 10; i++) {
      await _localNotifications.cancel(medicationId.hashCode + i);
    }
  }

  Future<void> scheduleConsultationReminder(Consultation consultation) async {
    await cancelConsultationReminders(consultation.id);

    final reminders = [
      {
        'offset': const Duration(days: 1),
        'message':
            'Vous avez une consultation avec ${consultation.doctorName} demain à ${consultation.scheduledAt.hour}:${consultation.scheduledAt.minute.toString().padLeft(2, '0')}',
        'idSuffix': 1,
      },
      {
        'offset': const Duration(hours: 2),
        'message': 'Consultation avec ${consultation.doctorName} dans 2 heures',
        'idSuffix': 2,
      },
      {
        'offset': const Duration(minutes: 30),
        'message':
            'Votre consultation avec ${consultation.doctorName} commence dans 30 minutes',
        'idSuffix': 3,
      },
      {
        'offset': const Duration(minutes: 10),
        'message':
            'Consultation imminente avec ${consultation.doctorName} (dans 10 min)',
        'idSuffix': 4,
      },
    ];

    for (final reminder in reminders) {
      final reminderTime =
          consultation.scheduledAt.subtract(reminder['offset'] as Duration);

      if (reminderTime.isAfter(DateTime.now())) {
        await _localNotifications.zonedSchedule(
          consultation.id.hashCode + (reminder['idSuffix'] as int),
          '📅 Rappel consultation',
          reminder['message'] as String,
          tz.TZDateTime.from(reminderTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'appointment_channel',
              'Rappels de rendez-vous',
              channelDescription:
                  'Notifications pour les rappels de consultations',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              category: AndroidNotificationCategory.event,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: 'consultation_${consultation.id}',
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelConsultationReminders(String consultationId) async {
    for (int i = 1; i <= 4; i++) {
      await _localNotifications.cancel(consultationId.hashCode + i);
    }
  }

  Future<void> cancelReminder(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllReminders() async {
    await _localNotifications.cancelAll();
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel',
          'Notifications générales',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigation logic can be handled here or in the UI layer
    final payload = response.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
    }
  }

  Future<bool> checkPermissions() async {
    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final enabled = await androidImplementation.areNotificationsEnabled();
      if (enabled == false) {
        await androidImplementation.requestNotificationsPermission();
      }
      return enabled ?? false;
    }

    final iosImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      final result = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    return false;
  }
}
