package com.antiaddiction.sdk.utils;

import android.content.Context;



public final class Res {

    public static int anim(Context context, String name) {
        return context.getResources().getIdentifier(name, "anim", context.getPackageName());
    }


    public static int attr(Context context, String name) {
        return context.getResources().getIdentifier(name, "attr", context.getPackageName());
    }

    public static int color(Context context, String name) {
        return context.getResources().getIdentifier(name, "color", context.getPackageName());
    }


    public static int dimen(Context context, String name) {
        return context.getResources().getIdentifier(name, "dimen", context.getPackageName());
    }

    public static int drawable(Context context, String name) {
        return context.getResources().getIdentifier(name, "drawable", context.getPackageName());
    }

    public static int id(Context context, String name) {
        return context.getResources().getIdentifier(name, "id", context.getPackageName());
    }

    public static int layout(Context context, String name) {
        return context.getResources().getIdentifier(name, "layout", context.getPackageName());
    }

    public static int menu(Context context, String name) {
        return context.getResources().getIdentifier(name, "menu", context.getPackageName());
    }

    public static int string(Context context, String name) {
        return context.getResources().getIdentifier(name, "string", context.getPackageName());
    }

    public static int style(Context context, String name) {
        return context.getResources().getIdentifier(name, "style", context.getPackageName());
    }
}
