// Flic2Service.java
package uk.co.darkerwaters.flic_button;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.app.AlarmManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.app.ActivityManager;
import android.Manifest;
import android.content.pm.PackageManager;

import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import io.flic.flic2libandroid.Flic2Button;
import io.flic.flic2libandroid.Flic2ButtonListener;
import io.flic.flic2libandroid.Flic2Manager;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flic.flic2libandroid.Flic2ScanCallback;
import android.os.Handler;
import java.util.List;
import io.flutter.plugin.common.MethodChannel;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class Flic2Service extends Service {
    private static Flic2Service instance;
    private static final int NOTIFICATION_ID = 1;
    private static final String CHANNEL_ID = "flic_service_channel";
    private static final String CHANNEL_NAME = "flic_button_channel";
    private MethodChannel methodChannel;

    @Override
    public void onCreate() {
        Log.d("MethodChannel", "flic2Service onCreate()");
        super.onCreate();
        instance = this;
        methodChannel = new MethodChannel(
                FlutterEngineCache.getInstance().get("flutter_engine").getDartExecutor().getBinaryMessenger(),
                CHANNEL_NAME
        );
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startForeground(NOTIFICATION_ID, createNotification());
        return START_STICKY;
    }


    private Notification createNotification() {
        // Create a notification channel for Android 8.0 and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Flic2 Service Channel",
                    NotificationManager.IMPORTANCE_LOW
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Flic2 Service")
                .setContentText("Listening for button events")
                .setSmallIcon(R.mipmap.ic_launcher)
                .build();
    }

    @Override
    public void onDestroy() {
        stopForeground(true);
        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    public void listenForButtonHold(){
        // Define the delay time in milliseconds (2 seconds = 2000 milliseconds)

        final int delayTimeMillis = 2000;

        // Create a new Handler to execute the delayed task
        Handler handler = new Handler();

        //New stuff
        Runnable delayedTask = new Runnable() {
            @Override
            public void run() {
                // Init flic stuff
                Flic2Manager.initAndGetInstance(getApplicationContext(), new Handler());
                Flic2Manager manager = Flic2Manager.getInstance();

                // Get the buttons
                List<Flic2Button> buttons = manager.getButtons();
                if (!buttons.isEmpty()) {
                    Flic2Button button1 = manager.getButtonByBdAddr(String.valueOf(buttons.get(0)));
                    button1.addListener(new Flic2ButtonListener() {
                        public void onButtonClickOrHold(Flic2Button button, boolean wasQueued, boolean lastQueued, long timestamp, boolean isClick, boolean isHold) {
                            if (isHold) {
                                // Broadcast an event to wake up the MainActivity
                                //Note: This part will send a broadcast to the file ForegroundService inside the example
                                //That file will be listening for "uk.co.darkerwater.flic_button.WAKE_UP_APP"
                                Intent broadcastIntent = new Intent("uk.co.darkerwaters.flic_button.WAKE_UP_APP");
                                sendBroadcast(broadcastIntent);
                            }
                        }
                    });
                    // Print the buttons to the console
//                    Log.d("MethodChannel", "getButtons");
//                    Log.d("MethodChannel", String.valueOf(buttons));
                }
            }
        };
        //Note: Important! We need some delay before the listener because we need to make sure the buttons is
        //connected
        handler.postDelayed(delayedTask, delayTimeMillis);
    }
    public static Flic2Service getInstance() {
        return instance;
    }
}
