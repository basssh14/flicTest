package uk.co.darkerwaters.flic_button_example;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import androidx.annotation.NonNull;
//New stuff
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineGroup;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodCall;

public class ForegroundService extends Service {
    private static final String CHANNEL_ID = "ForegroundServiceChannel";
    private static final String CHANNEL_NAME = "your_channel_name";

    private FlutterEngine flutterEngine;

    private final BroadcastReceiver wakeUpAppReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            // Handle the event to wake up the app and execute the desired functionality
            onWakeUpApp();
        }
    };

    @Override
    public void onCreate() {
        super.onCreate();
        IntentFilter intentFilter = new IntentFilter("uk.co.darkerwaters.flic_button.WAKE_UP_APP");
        registerReceiver(wakeUpAppReceiver, intentFilter);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        createNotificationChannel();
        Notification notification = new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Foreground Service")
                .setContentText("Foreground service is running.")
                .setSmallIcon(R.mipmap.ic_launcher)
                .build();

        startForeground(1, notification);
        if (flutterEngine == null) {
            flutterEngine = new FlutterEngine(this);
            flutterEngine.getDartExecutor().executeDartEntrypoint(
                    DartExecutor.DartEntrypoint.createDefault()
            );
        }
        onWakeUpApp();

        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }



    @Override
    public void onDestroy() {
        super.onDestroy();
        unregisterReceiver(wakeUpAppReceiver);
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Foreground Service Channel",
                    NotificationManager.IMPORTANCE_LOW
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }
    private void onWakeUpApp() {
        //Note: This function will send a channel broadcast to flutter with the method "showLocalNotification"
        Log.d("MethodChannel", "FS22 onWakeUpApp()");
        MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME);
        channel.invokeMethod("showLocalNotification", null);
    }
}
