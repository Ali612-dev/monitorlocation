import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'RealTimeLocationMethod.dart';

class HandleHeadlessEvents {
  /// Critical: Must use @pragma('vm:entry-point') for release builds
  @pragma('vm:entry-point')
  static void backgroundGeolocationHeadlessTask(bg.HeadlessEvent headlessEvent) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      // Initialize Firebase with timeout
      await Firebase.initializeApp().timeout(const Duration(seconds: 5));
    } catch (e) {
      bg.Logger.error("Firebase initialization failed: $e");
      return;
    }

    await bg.BackgroundGeolocation.ready(bg.Config(
      reset: false,  // Maintain existing configuration
    ));

    bg.Logger.info("Headless event: ${headlessEvent.name}");

    switch (headlessEvent.name) {
      case bg.Event.ENABLEDCHANGE:
        final enabled = headlessEvent.event as bool;
        bg.Logger.info("**Service enabled state changed: $enabled");
        if (!enabled) {
          try {
            await bg.BackgroundGeolocation.start();
          } catch (error) {
            bg.Logger.error("##Failed to restart service: $error");
          }
        }

        break;

      case bg.Event.TERMINATE:  // Correct event name
        bg.Logger.info("App termination event received");
        try {
          // Perform final cleanup operations
          await bg.BackgroundGeolocation.stop();
          bg.Logger.info("**Service stopped successfully on termination");
        } catch (error) {
          bg.Logger.error("##Termination cleanup failed: $error");
        }
        break;

      case bg.Event.HEARTBEAT:
        bg.Logger.info("Heartbeat event received");
        try {
          final location = await bg.BackgroundGeolocation.getCurrentPosition(
              timeout: 10,  // Add timeout for safety
              persist: true
          );
          await sendLocationToRealtimeDatabase(location);
          bg.Logger.info("Heartbeat location sent to database");
        } catch (error) {
          bg.Logger.error("Heartbeat location error: $error");
        }
        break;

      case bg.Event.LOCATION:
        final location = headlessEvent.event as bg.Location;
        bg.Logger.info("Location update received");
        try {
          await sendLocationToRealtimeDatabase(location);
          bg.Logger.info("Location sent to database");
        } catch (error) {
          bg.Logger.error("Location update error: $error");
        }
        break;
      default:
        bg.Logger.warn("Unhandled event type: ${headlessEvent.name}");
        break;
    }
  }
}