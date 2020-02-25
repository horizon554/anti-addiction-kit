package com.antiaddiction.sdk.service;

import com.antiaddiction.sdk.AntiAddictionKit;
import com.antiaddiction.sdk.entity.User;
import com.antiaddiction.sdk.utils.RexCheckUtil;

import java.text.SimpleDateFormat;
import java.util.Date;

public class UserService {

    //根据日期充值用户相关信息
    public static User resetUserState(User user){
        long saveTimeStamp = user.getSaveTimeStamp();
        int onlineTime = user.getOnlineTime();
        int payMonthNum = user.getPayMonthNum();
        String birthday = user.getBirthday();
        int accountType = user.getAccountType();
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd");
        Date date1 = new Date();
        String time1 = simpleDateFormat.format(date1);
        String time2 = simpleDateFormat.format(new Date(saveTimeStamp));
        if(!time1.equals(time2)) {
            onlineTime = 0;
            saveTimeStamp = date1.getTime();
            if (!time1.substring(4, 6).equals(time2.substring(4, 6))) {
                payMonthNum = 0;
            }
            try {
                if (birthday != null && birthday.length() > 0) {
                    Date date = simpleDateFormat.parse(birthday);
                    if (null != date) {
                        int age = RexCheckUtil.getAgeByDate(date);
                       accountType = getUserTypeByAge(age);
                    }
                }
                user.setSaveTimeStamp(saveTimeStamp);
                user.setOnlineTime(onlineTime);
                user.setPayMonthNum(payMonthNum);
                user.setAccountType(accountType);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return user;
    }

    public static int getUserTypeByAge(int age){
        int accountType = AntiAddictionKit.USER_TYPE_UNKNOWN;
        if (age < 8) {
            accountType = AntiAddictionKit.USER_TYPE_CHILD;
        } else if (age < 16) {
            accountType = AntiAddictionKit.USER_TYPE_TEEN;
        } else if (age < 18) {
            accountType = AntiAddictionKit.USER_TYPE_YOUNG;
        } else {
            accountType = AntiAddictionKit.USER_TYPE_ADULT;
        }
        return accountType;
    }
}
