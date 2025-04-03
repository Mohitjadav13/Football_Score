package com.onefootball.app;

import io.flutter.embedding.android.FlutterActivity;
import androidx.multidex.MultiDex;
import android.content.Context;

public class MainActivity extends FlutterActivity {
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
    }
} 