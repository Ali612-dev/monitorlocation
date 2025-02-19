import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;



import 'package:firebase_database/firebase_database.dart';

Future<void> sendLocationToRealtimeDatabase(bg.Location location) async {
  try {
    final database = FirebaseDatabase.instance.ref();

    // Use the relative path in the Realtime Database
    await database.child('geolocation').child('user_location').set({
      'lat': location.coords.latitude,
      'lon': location.coords.longitude,
      'timestamp': location.timestamp,
      'battery': location.battery.level,// Assuming battery info is available
      'heading':location.coords.heading
    });

    print('Location sent to Realtime Database: ${location.coords.latitude}, ${location.coords.longitude}');
  } catch (e) {
    print('Error sending location to Realtime Database: $e');
  }
}


@pragma('vm:entry-point')
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (headlessEvent.name == bg.Event.LOCATION||  headlessEvent.name ==  bg.Event.MOTIONCHANGE) {
    bg.Location location = headlessEvent.event;
    await sendLocationToRealtimeDatabase(location);
  }
   await initializeGeolocationService();


  switch (headlessEvent.name) {


    case bg.Event.BOOT:{
      await bg.BackgroundGeolocation.ready(bg.Config(
        // Critical Android foreground service settings
          foregroundService: true,
          enableHeadless: true,
          stopOnTerminate: false,
          startOnBoot: true,
          forceReloadOnBoot: true,
          forceReloadOnHeartbeat: true,
          forceReloadOnMotionChange: true,
          forceReloadOnLocationChange: true,

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
          distanceFilter: 1,
          stationaryRadius: 1,
          locationUpdateInterval: 1000,
          fastestLocationUpdateInterval: 500,
          debug: true,
          logLevel: bg.Config.LOG_LEVEL_VERBOSE
      ));

      try {
        // Ensure service stays active on terminate
        await bg.BackgroundGeolocation.start();
        bg.Logger.notice("/////////////////////////////////////////////////////////////////////////////////");
        await bg.BackgroundGeolocation.setConfig(
            bg.Config(
                notification: bg.Notification(
                    title: "Location Service terminate",
                    text: "Service running in background terminate on",
                    sticky: true,
                    priority: bg.Config.NOTIFICATION_PRIORITY_MAX
                )
            )
        );

        // Force a location update
       var location= await bg.BackgroundGeolocation.getCurrentPosition(
            samples: 1,
            persist: true,
            extras: {"event": "terminate"}
        );
await     sendLocationToRealtimeDatabase(location);

        // Reset notification

      } catch (error) {
        bg.Logger.error("[TERMINATE] Error: $error");
      }
      break;
    }


    case bg.Event.TERMINATE:{
      await bg.BackgroundGeolocation.ready(bg.Config(
        // Critical Android foreground service settings
          foregroundService: true,
          enableHeadless: true,
          stopOnTerminate: false,
          startOnBoot: true,
          forceReloadOnBoot: true,
          forceReloadOnHeartbeat: true,
          forceReloadOnMotionChange: true,
          forceReloadOnLocationChange: true,

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
          distanceFilter: 1,
          stationaryRadius: 1,
          locationUpdateInterval: 1000,
          fastestLocationUpdateInterval: 500,
          debug: true,
          logLevel: bg.Config.LOG_LEVEL_VERBOSE
      ));

      try {
        // Ensure service stays active on terminate
        await bg.BackgroundGeolocation.start();
        bg.Logger.notice("/////////////////////////////////////////////////////////////////////////////////");
        await bg.BackgroundGeolocation.setConfig(
            bg.Config(
                notification: bg.Notification(
                    title: "Location Service terminate",
                    text: "Service running in background terminate on",
                    sticky: true,
                    priority: bg.Config.NOTIFICATION_PRIORITY_MAX
                )
            )
        );

        // Force a location update
      var location=  await bg.BackgroundGeolocation.getCurrentPosition(
            samples: 1,
            persist: true,
            extras: {"event": "terminate"}
        );

        // Reset notification
await     sendLocationToRealtimeDatabase(location);

      } catch (error) {
        bg.Logger.error("[TERMINATE] Error: $error");
      }
      break;
    }


    case bg.Event.HEARTBEAT:{
      await bg.BackgroundGeolocation.ready(bg.Config(
        // Critical Android foreground service settings
          foregroundService: true,
          enableHeadless: true,
          stopOnTerminate: false,
          startOnBoot: true,
          forceReloadOnBoot: true,
          forceReloadOnHeartbeat: true,
          forceReloadOnMotionChange: true,
          forceReloadOnLocationChange: true,

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
          distanceFilter: 1,
          stationaryRadius: 1,
          locationUpdateInterval: 1000,
          fastestLocationUpdateInterval: 500,
          debug: true,
          logLevel: bg.Config.LOG_LEVEL_VERBOSE
      ));

      try {
        // Ensure service stays active on terminate
        await bg.BackgroundGeolocation.start();
        bg.Logger.notice("/////////////////////////////////////////////////////////////////////////////////");
        await bg.BackgroundGeolocation.setConfig(
            bg.Config(
                notification: bg.Notification(
                    title: "Location Service terminate",
                    text: "Service running in background terminate on",
                    sticky: true,
                    priority: bg.Config.NOTIFICATION_PRIORITY_MAX
                )
            )
        );

        // Force a location update
       var location= await bg.BackgroundGeolocation.getCurrentPosition(
            samples: 1,
            persist: true,
            extras: {"event": "terminate"}
        );

        // Reset notification
       await sendLocationToRealtimeDatabase(location);

      } catch (error) {
        bg.Logger.error("[TERMINATE] Error: $error");
      }
      break;
    }

    case bg.Event.MOTIONCHANGE:{

      await bg.BackgroundGeolocation.ready(bg.Config(

        // Critical Android foreground service settings
          foregroundService: true,
          enableHeadless: true,
          stopOnTerminate: false,
          startOnBoot: true,
          forceReloadOnBoot: true,
          forceReloadOnHeartbeat: true,
          forceReloadOnMotionChange: true,
          forceReloadOnLocationChange: true,
          disableMotionActivityUpdates:false,
          preventSuspend:true,
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

          heartbeatInterval: 1,
          // Location settings
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
          distanceFilter: 1,
          stationaryRadius: 1,
          locationUpdateInterval: 1000,
          fastestLocationUpdateInterval: 500,
          debug: true,
          logLevel: bg.Config.LOG_LEVEL_VERBOSE
      ));

      try {
        // Ensure service stays active on terminate
        await bg.BackgroundGeolocation.start();
        bg.Logger.notice("/////////////////////////////////////////////////////////////////////////////////");
        await bg.BackgroundGeolocation.setConfig(
            bg.Config(
                notification: bg.Notification(
                    title: "Location Service terminate",
                    text: "Service running in background terminate on",
                    sticky: true,
                    priority: bg.Config.NOTIFICATION_PRIORITY_MAX
                )
            )
        );

        // Force a location update
      var location=  await bg.BackgroundGeolocation.getCurrentPosition(
            samples: 1,
            persist: true,
            extras: {"event": "terminate"}
        );

        // Reset notification
      await  sendLocationToRealtimeDatabase(location);

      } catch (error) {
        bg.Logger.error("[TERMINATE] Error: $error");
      }
      break;
    }

    case bg.Event.LOCATION:{


      try {
        // Ensure service stays active on terminate
        await bg.BackgroundGeolocation.start();
        bg.Logger.notice("/////////////////////////////////////////////////////////////////////////////////");
        await bg.BackgroundGeolocation.setConfig(
            bg.Config(
                notification: bg.Notification(
                    title: "Location Service terminate",
                    text: "Service running in background terminate on",
                    sticky: true,
                    priority: bg.Config.NOTIFICATION_PRIORITY_MAX
                )
            )
        );


        // Force a location update
        var location= await bg.BackgroundGeolocation.getCurrentPosition(
            samples: 1,
            persist: true,
            extras: {"event": "terminate"}
        );
       await sendLocationToRealtimeDatabase(location);

        // Reset notification

      } catch (error) {
        bg.Logger.error("[TERMINATE] Error: $error");
      }
      break;
    }
  }
}




Future<void>getGeolocationReady()async{

  await bg.BackgroundGeolocation.ready(bg.Config(
    // scheduleUseAlarmManager: ,
    // Critical Android foreground service settings
      foregroundService: true,
      enableHeadless: true,
      stopOnTerminate: false,
      startOnBoot: true,
      forceReloadOnBoot: true,
      forceReloadOnHeartbeat: true,
      forceReloadOnMotionChange: true,
      forceReloadOnLocationChange: true,
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
      distanceFilter: 1,
      stationaryRadius: 1,
      locationUpdateInterval: 1000,
      fastestLocationUpdateInterval: 500,
      stopAfterElapsedMinutes: null,
      debug: true,
      logLevel: bg.Config.LOG_LEVEL_VERBOSE
  ));
}


Future<void> initializeGeolocationService() async {
  await bg.BackgroundGeolocation.ready(bg.Config(
    foregroundService: true,
    enableHeadless: true,
    stopOnTerminate: false,
    startOnBoot: true,
    notification: bg.Notification(
      title: "Location Service Active",
      text: "Tap to return to app",
      channelName: "Background Tracking",
      channelId: "background_tracking_channel",
      sticky: true,
      priority: bg.Config.NOTIFICATION_PRIORITY_MAX,
    ),
    persistMode: bg.Config.PERSIST_MODE_LOCATION,
    desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
    distanceFilter: 1,
    debug: true,
    logLevel: bg.Config.LOG_LEVEL_VERBOSE,
  ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeGeolocationService();





  // Listen for location updates
  bg.BackgroundGeolocation.onLocation((bg.Location location) {
    sendLocationToRealtimeDatabase(location);
  }, (bg.LocationError error) {
    print("[onLocation] ERROR: $error");
  });

  bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
    sendLocationToRealtimeDatabase(location);
  });


  // Register and start service
  await bg.BackgroundGeolocation.registerHeadlessTask(backgroundGeolocationHeadlessTask);
  await bg.BackgroundGeolocation.start();

  // Listen to enabledchange events
  bg.BackgroundGeolocation.onEnabledChange((bool enabled) {
    if (!enabled) {
      bg.BackgroundGeolocation.start();
    }
  });
  //

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text('Location Service Active'),
      ),
    ),
  ));
}