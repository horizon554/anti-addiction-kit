package com.antiaddiction.sdk.utils;

import com.antiaddiction.sdk.AntiAddictionKit;
import com.antiaddiction.sdk.entity.User;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class TimeUtil {
    //距离宵禁时间还有多久，单位秒
    public static int getTimeToNightStrict(){
        long currentTime = new Date().getTime();
        SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss");
        String dateString = formatter.format(currentTime);
        int hour = Integer.parseInt(dripZero(dateString.substring(0,2)));
        int min = Integer.parseInt(dripZero(dateString.substring(3,5)));
        int second = Integer.parseInt(dripZero(dateString.substring(6)));
        int startTime = AntiAddictionKit.getCommonConfig().getNightStrictStart();
        int endTime = AntiAddictionKit.getCommonConfig().getNightStrictEnd();
        int currentSecondTime = hour * 60 * 60 + min * 60 + second;
        if(currentSecondTime > startTime || currentSecondTime < endTime){
            return 0;
        }else{
            return startTime - currentSecondTime;
        }
    }
    //距离限制时长还有多久，单位秒
    public static int getTimeToStrict(User user){
        int hasUse = user.getOnlineTime();
        if(user.getAccountType() != AntiAddictionKit.USER_TYPE_UNKNOWN) {
            if (isHoliday()) {
                return AntiAddictionKit.getCommonConfig().getChildHolidayTime() - hasUse;
            } else {
                return AntiAddictionKit.getCommonConfig().getChildCommonTime() - hasUse;
            }
        }else{
            return AntiAddictionKit.getCommonConfig().getGuestTime() - hasUse;
        }
    }

    public static boolean isHoliday(){
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(new Date());
        if(calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY || calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY){
            return true;
        }
        long currentTime = new Date().getTime();
        SimpleDateFormat formatter = new SimpleDateFormat("MM:dd");
        String dateString = formatter.format(currentTime);
        int month = Integer.parseInt(dripZero(dateString.substring(0,2)));
        int day = Integer.parseInt(dripZero(dateString.substring(3)));
        String current = month + "." + day;
        //考虑到单机游戏，暂时假日写死
        String days = "1.1,1.24,1.25,1.26,1.27,1.28,1.29,1.30,4.4,4.5,4.6,5.1,5.2,5.3,5.4,5.5" +
                "6.25,6.26,6.27,10.1,10.2,10.3,10.4,10.5,10.6,10.7,10.8";
        if(days.contains(current)){
            return true;
        }
        return false;
    }

    private static String dripZero(String str){
        if(str != null && str.length() > 1){
            if(str.startsWith("0")){
                return str.substring(1);
            }else{
                return str;
            }
        }else{
            return str;
        }
    }
}
