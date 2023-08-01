package uk.co.darkerwaters.flic_button_example;

import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import android.view.View;
import android.widget.Toast;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngineCache;
import android.content.Intent;
import android.app.ActivityManager;
import android.content.Context;
import android.os.Bundle;
import io.flic.flic2libandroid.Flic2Manager;
import uk.co.darkerwaters.flic_button.Flic2Service; // Import the correct Flic2Service class
import android.util.Log;
import android.os.Build;
import java.util.List;
//new stuff 28
import android.Manifest;
import android.app.Activity;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;


public class MainActivity extends FlutterActivity {
    public static final String ACTION_RESTART_APP = "ACTION_RESTART_APP";
    private static final String CHANNEL = "flic_button_channel";
    private static final String METHOD_CHANNEL_NAME = "flic_button_channel";
    private static final int REQUEST_FINE_LOCATION_PERMISSION = 1;
    private MethodChannel methodChannel;
    //To delete
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.d("MethodChannel", "MainActivity onCreate()");
        // Start the foreground service if it's not already running
        if (!isServiceRunning(ForegroundService.class)) {
            startForegroundService(new Intent(this, ForegroundService.class));
        }


//        startForegroundService();
        // Set up a MethodChannel to receive messages from Flutter
//        methodChannel = new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL);

        // Register a BroadcastReceiver to listen for the restart app event
// Register the BroadcastReceiver to listen for the wake-up event
//        IntentFilter intentFilter = new IntentFilter("uk.co.darkerwaters.flic_button.WAKE_UP_APP");
//        registerReceiver(wakeUpAppReceiver, intentFilter);


    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        Log.d("MethodChannel", "MainActivity configureFlutterEngine()");
        super.configureFlutterEngine(flutterEngine);
        FlutterEngineCache.getInstance().put("flutter_engine", flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL_NAME)
                .setMethodCallHandler((call, result) -> {
                    Log.d("MethodChannel", "Method call received: " + call.method + " - " + call.arguments);

                });
    }

    //    @Override
//    protected void onResume() {
//        super.onResume();
//        System.out.println("holaaaaaaaaaaaaaaaaaaaaaaa");
//        // Start the foreground service if it's not already running
//        if (isServiceRunning(Flic2Service.class)) {
//            startForegroundService(new Intent(this, Flic2Service.class));
//        }
//    }
//
//    @Override
//    protected void onPause() {
//        super.onPause();
//        System.out.println("holaaaaaaaaaaaaaaaaaaaaaaa");
//        // Stop the foreground service if it's running
//        stopService(new Intent(this, Flic2Service.class));
//    }

    @Override
    protected void onDestroy() {
        // Unregister the BroadcastReceiver
        //unregisterReceiver(restartAppReceiver);
        // Unregister the BroadcastReceiver
        //unregisterReceiver(wakeUpAppReceiver);
        //stopForegroundService();
        super.onDestroy();
    }
//    public void onRestartButtonClick(View view) {
//        Log.d("MethodChannel", "MainActivity onRestartbuttonClick()");
//        // Send a message to Flutter to handle the restart action
//        methodChannel.invokeMethod("restartApp", null);
//        Toast.makeText(this, "App restarted", Toast.LENGTH_SHORT).show();
//    }
    // BroadcastReceiver to handle the restart app event
//    private BroadcastReceiver restartAppReceiver = new BroadcastReceiver() {
//        @Override
//        public void onReceive(Context context, Intent intent) {
//            Log.d("MethodChannel", "MainActivity onReceiver()");
//            if (intent.getAction() != null && intent.getAction().equals(ACTION_RESTART_APP)) {
//                // Restart the app
//                recreate();
//            }
//        }
//    };
    //To delete
//private final BroadcastReceiver wakeUpAppReceiver = new BroadcastReceiver() {
//    @Override
//    public void onReceive(Context context, Intent intent) {
//        // Handle the event to wake up the app and execute the desired functionality
//        onWakeUpApp();
//    }
//};
//
//    private void onWakeUpApp() {
//        Log.d("MethodChannel", "MainActivity2 onWakeUp()");
//        // Add your code here to execute the desired functionality when the app wakes up
//    }
    //End delete
    private boolean isServiceRunning(Class<?> serviceClass) {
        Log.d("MethodChannel", "MainActivity isServiceRunning()");
        // Helper method to check if the service is running or not
        ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        System.out.println("holaaaaaaaaaaaaaaaaaaaaaaa");
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (serviceClass.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }

    //To delete
    private static String getAppPackageName(Context context) {
        return context.getPackageName();
    }
    // Helper method to check if the app is in the foreground
    public static boolean isAppInForeground(Context context) {
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Use the getRunningAppProcesses method for newer Android versions
            final String packageName = getAppPackageName(context);
            for (ActivityManager.RunningAppProcessInfo appProcess : activityManager.getRunningAppProcesses()) {
                if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND &&
                        appProcess.processName.equals(packageName)) {
                    return true;
                }
            }
        } else {
            // Use the getRunningTasks method for older Android versions
            List<ActivityManager.RunningTaskInfo> tasks = activityManager.getRunningTasks(1);
            if (!tasks.isEmpty()) {
                String topActivityName = tasks.get(0).topActivity.getPackageName();
                if (topActivityName.equals(context.getPackageName())) {
                    return true;
                }
            }
        }
        return false;
    }
}


