
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class GeolocationConfiguration{

  static Future<void> getGeolocationReady()async{
    await bg.BackgroundGeolocation.ready(bg.Config(

      stopOnStationary: false,

      // scheduleUseAlarmManager: ,
      // Critical Android foreground service settings
      motionTriggerDelay: 0,
// batchSync: true,
        foregroundService: true,
        enableHeadless: true,
        stopOnTerminate: false,
        startOnBoot: true,
        forceReloadOnBoot: true,

        // forceReloadOnHeartbeat: true,
        // forceReloadOnMotionChange: true,
        // forceReloadOnLocationChange: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        notification: bg.Notification(
          title: "Location Service Active",
          text: "Tap to return to app",
          channelName: "Background Tracking",
          channelId: "background_tracking_channel",  // Important for Android 8+
          sticky: true,  // Make notification persistent
          priority: bg.Config.NOTIFICATION_PRIORITY_MAX,
          layout: 'my_notification_layout',  // Optional: custom layout

        ),
        // Service persistence settings
        persistMode: bg.Config.PERSIST_MODE_LOCATION,
        maxDaysToPersist: 7,
        preventSuspend: true,
        heartbeatInterval: 1,

        // Location settings
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 0,
        stationaryRadius: 1,
        locationUpdateInterval: 1000,
        fastestLocationUpdateInterval: 500,
        // stopAfterElapsedMinutes: null,
        debug: true,
    ));
  }

}