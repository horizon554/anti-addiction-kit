package com.antiaddiction.sdk.utils;

import android.util.Log;

public class LogUtil {

    private final static String TAG = "[AntiAddiction]";
    public static boolean IS_DEBUG = false;

    public static void setIsDebug(boolean isDebug){
        IS_DEBUG = isDebug;
    }

    public static void logd(String msg){
        if(IS_DEBUG) {
            Log.d(TAG, msg);
        }
    }

    public static void loge(String msg){
        if(IS_DEBUG){
            Log.e(TAG,msg);
        }
    }
}
