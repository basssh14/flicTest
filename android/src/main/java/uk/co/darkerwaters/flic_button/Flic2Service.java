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
    private static final int REQUEST_FINE_LOCATION_PERMISSION = 1;
    private boolean isScanningPending = false;

    @Override
    public void onCreate() {
        Log.d("MethodChannel", "flic2Service onCreate()");
        super.onCreate();
        //NEw stuff 28
        instance = this;
        //Delete this
        methodChannel = new MethodChannel(
                FlutterEngineCache.getInstance().get("flutter_engine").getDartExecutor().getBinaryMessenger(),
                CHANNEL_NAME
        );



        // Print the buttons to the console
//        Log.d("MethodChannel", "getButtons");
//        Log.d("MethodChannel", String.valueOf(buttons));
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startForeground(NOTIFICATION_ID, createNotification());
        return START_STICKY;
    }


    private Notification createNotification() {
        Log.d("MethodChannel", "flic2Service createNotification()");
        // Create a notification channel for Android 8.0 and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Flic2 Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
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
        Log.d("MethodChannel", "Flic2Service, listenForButtonHold()asdfafd####");
        // Define the delay time in milliseconds (2 seconds = 2000 milliseconds)
        final int delayTimeMillis = 2000;

        // Create a new Handler to execute the delayed task
        Handler handler = new Handler();

        //New stuff
        Runnable delayedTask = new Runnable() {
            @Override
            public void run() {
                // This code will be executed after the specified delay
                Log.d("MethodChannel", "Flic2Service, executeHandler 454545!!!!!");
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
                                Log.d("MethodChannel", "holddddddddddd");
                                // Broadcast an event to wake up the MainActivity
                                Intent broadcastIntent = new Intent("uk.co.darkerwaters.flic_button.WAKE_UP_APP");
                                sendBroadcast(broadcastIntent);
                            }
                        }
                    });
                    // Print the buttons to the console
                    Log.d("MethodChannel", "getButtons");
                    Log.d("MethodChannel", String.valueOf(buttons));
                    Log.d("MethodChannel", "getButton");
                    Log.d("MethodChannel", String.valueOf(button1));
                }
            }
        };
        //Init flic stuff
//        Flic2Manager.initAndGetInstance(getApplicationContext(), new Handler());
//        Flic2Manager manager = Flic2Manager.getInstance();
//        // Get the buttons
//        List<Flic2Button> buttons = manager.getButtons();
//        if(!buttons.isEmpty()){
//            Flic2Button button1 = manager.getButtonByBdAddr(String.valueOf(buttons.get(0)));
//            button1.addListener(new Flic2ButtonListener() {
//
//                public void onButtonClickOrHold(Flic2Button button, boolean wasQueued, boolean lastQueued, long timestamp, boolean isClick, boolean isHold){
//                    if(isHold){
//                        Log.d("MethodChannel", "holddddddddddd");
//                        // Broadcast an event to wake up the MainActivity
//                        Intent broadcastIntent = new Intent("uk.co.darkerwaters.flic_button.WAKE_UP_APP");
//                        sendBroadcast(broadcastIntent);
//                    }
//                }
//            });
//            // Print the buttons to the console
//            Log.d("MethodChannel", "getButtons");
//            Log.d("MethodChannel", String.valueOf(buttons));
//            Log.d("MethodChannel", "getButton");
//            Log.d("MethodChannel", String.valueOf(button1));
//        }
        // Post the delayed task with the specified delay time
        handler.postDelayed(delayedTask, delayTimeMillis);
    }
    public static Flic2Service getInstance() {
        return instance;
    }
}
