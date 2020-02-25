package com.antiaddiction.sdk.dao;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.antiaddiction.sdk.entity.User;

import org.json.JSONObject;

import java.util.Date;

public class UserDao {
    private final static String USER_PREFIX = "USER_INFO";

    public static User getUser(Context context, String userId){
        if( null != context && null != userId && userId.length() > 0){
            SharedPreferences sharedPreferences = context.getSharedPreferences(USER_PREFIX+userId,Context.MODE_PRIVATE);
            String string = sharedPreferences.getString(userId,null);
            if( null != string){
                return User.getUserFromJson(string);
            }
            return null;
        }else{
            return null;
        }
    }

    public static void saveUser(Context context, User user){
        if( null != context && null != user && user.getUserId() != null && user.getUserId().length() > 0){
            user.setSaveTimeStamp(new Date().getTime());
            SharedPreferences sharedPreferences = context.getSharedPreferences(USER_PREFIX+user.getUserId(),Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = sharedPreferences.edit();
            JSONObject jsonObject = user.toJsonString();
            if( null != jsonObject){
                editor.putString(user.getUserId(),jsonObject.toString());
            }
            editor.apply();
        }
    }
}
