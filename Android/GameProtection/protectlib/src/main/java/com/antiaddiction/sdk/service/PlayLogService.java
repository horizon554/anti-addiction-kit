package com.antiaddiction.sdk.service;

import android.content.Intent;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.antiaddiction.sdk.AntiAddictionCore;
import com.antiaddiction.sdk.AntiAddictionPlatform;
import com.antiaddiction.sdk.AntiAddictionKit;
import com.antiaddiction.sdk.entity.User;
import com.antiaddiction.sdk.utils.LogUtil;
import com.antiaddiction.sdk.utils.TimeUtil;

import org.json.JSONObject;

public class PlayLogService {
    static JSONObject handlePlayLog(long startTime,long endTime,User user){
        LogUtil.logd("handlePlayLog startTime = " + startTime + " endTime = " + endTime +
                " user = " + user.toJsonString());
        user.updateOnlineTime((int) (endTime - startTime));
        AntiAddictionCore.saveUserInfo();
        return checkUserState(user,false);
    }

    public static JSONObject checkUserState(User user,boolean isLogin){
        JSONObject response = new JSONObject();
        int restrictType = 0; //1 宵禁 2 在线时长限制
        int remainTime = 0;
        String description = "";
        String title = "";
        try {
            if (null == user) {
                return null;
            }
            if(user.getAccountType() != AntiAddictionKit.USER_TYPE_ADULT){
                int toNightTime = TimeUtil.getTimeToNightStrict();
                int toLimitTime = TimeUtil.getTimeToStrict(user);
                if(user.getAccountType() == AntiAddictionKit.USER_TYPE_UNKNOWN){
                    remainTime = toLimitTime;
                    restrictType = 2;
                }else {
                    remainTime = toLimitTime > toNightTime ? toNightTime : toLimitTime;
                    restrictType = toLimitTime > toNightTime ? 1 : 2;
                }
                if(restrictType == 2){
                    title = "健康游戏提示";
                    if(user.getAccountType() == AntiAddictionKit.USER_TYPE_UNKNOWN){
                        if((!isLogin && remainTime <= 3 * 60) || remainTime <= 0 ) {
                            description = "您的游戏体验时长已达 " + AntiAddictionKit.getCommonConfig().getGuestTime() / 60 + " 分钟。" +
                                    "登记实名信息后可深度体验。";
                        }else{
                            if(remainTime == AntiAddictionKit.getCommonConfig().getGuestTime() && user.getSaveTimeStamp() <= 0){
                                description = "您当前为游客账号，根据国家相关规定，游客账号享有 " +
                                        AntiAddictionKit.getCommonConfig().getGuestTime() / 60 + " 分钟游戏体验时间。登记实名信息后可深度体验。";
                            }else {
                                description = "您当前为游客账号，游戏体验时间还剩余 " + (remainTime / 60 > 0 ? (remainTime / 60) : 1) + " 分钟。" +
                                        "登记实名信息后可深度体验。";
                            }
                        }
                    }else{
                        if((!isLogin && remainTime <= 3 * 60) || remainTime <= 0 ) {
                            int min = TimeUtil.isHoliday() ? AntiAddictionKit.getCommonConfig().getChildHolidayTime() : AntiAddictionKit.getCommonConfig().getChildCommonTime();
                            description = "您今日游戏时间已达 " + min / 60 + " 分钟。根据国家相关规定，今日无法再进行游戏。请注意适当休息。";
                        }
                    }
                }else {
                    title = "健康游戏提示";
                    description = "根据国家相关规定，每日 " + AntiAddictionKit.getCommonConfig().getNightStrictStart() / 3600 + " 点 - 次日 "
                            + AntiAddictionKit.getCommonConfig().getNightStrictEnd() / 3600 + " 点为健康保护时段，当前无法进入游戏。";
                }
            }
            response.put("restrictType",restrictType);
            response.put("remainTime",remainTime);
            Intent intent = new Intent("time.click");
            intent.putExtra("time",remainTime);
            LocalBroadcastManager.getInstance(AntiAddictionPlatform.getActivity()).sendBroadcast(intent);
            response.put("description",description);
            response.put("title",title);
            LogUtil.logd(" timeResult = " + response);
            return response;
        }catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }
}
