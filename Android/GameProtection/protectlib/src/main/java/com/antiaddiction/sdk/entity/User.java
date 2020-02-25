package com.antiaddiction.sdk.entity;

import com.antiaddiction.sdk.AntiAddictionKit;
import com.antiaddiction.sdk.service.UserService;
import com.antiaddiction.sdk.utils.RexCheckUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;

public class User {
    private String userId = "";
    private String userName = "";
    private String phone = "";
    private String identify = "";
    private int accountType = AntiAddictionKit.USER_TYPE_UNKNOWN;
    private int onlineTime = 0;
    private int payMonthNum = 0;
    private String birthday = "";
    //上次保存信息的时间
    private long saveTimeStamp = 0;

    public User(String userId){
        this.userId = userId;
    }

    private User(String userId,String identify,int accountType,int onlineTime,
                int payMonthNum,long saveTimeStamp,String userName,String phone,String birthday){
        this.userId = userId;
        this.identify = identify;
        this.accountType = accountType;
        this.onlineTime = onlineTime;
        this.payMonthNum = payMonthNum;
        this.saveTimeStamp = saveTimeStamp;
        this.userName = userName;
        this.phone = phone;
        this.birthday = birthday;
    }

    public void updatePayMonthNum(int num){
        this.payMonthNum += num;
    }

    public int getPayMonthNum() {
        return payMonthNum;
    }

    public void updateOnlineTime(int time){
        this.onlineTime += time;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getIdentify() {
        return identify;
    }

    public void setIdentify(String identify) {
        this.identify = identify;
    }

    public int getAccountType() {
        return accountType;
    }

    public void setAccountType(int accountType) {
        this.accountType = accountType;
    }

    public int getOnlineTime() {
        return onlineTime;
    }

    public void setOnlineTime(int onlineTime) {
        this.onlineTime = onlineTime;
    }


    public void setPayMonthNum(int payMonthNum) {
        this.payMonthNum = payMonthNum;
    }


    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public long getSaveTimeStamp() {
        return saveTimeStamp;
    }

    public void setSaveTimeStamp(long saveTimeStamp) {
        this.saveTimeStamp = saveTimeStamp;
    }

    public String getBirthday() {
        return birthday;
    }

    public void setBirthday(String birthday) {
        this.birthday = birthday;
    }

    public  JSONObject toJsonString(){
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("userId",userId);
            jsonObject.put("identify",identify);
            jsonObject.put("accountType",accountType);
            jsonObject.put("onlineTime",onlineTime);
            jsonObject.put("payMonthNum",payMonthNum);
            jsonObject.put("saveTimeStamp",saveTimeStamp);
            jsonObject.put("userName",userName);
            jsonObject.put("phone",phone);
            jsonObject.put("birthday",birthday);
            return jsonObject;
        } catch (JSONException e) {
           return null;
        }
    }

    public static User getUserFromJson(String jsonString){
        try {
            JSONObject jsonObject = new JSONObject(jsonString);
            String userId = jsonObject.getString("userId");
            String identify = jsonObject.getString("identify");
            int accountType = jsonObject.getInt("accountType");
            int onlineTime = jsonObject.getInt("onlineTime");
            int payMonthNum = jsonObject.getInt("payMonthNum");
            long saveTimeStamp = jsonObject.getLong("saveTimeStamp");
            String userName = jsonObject.getString("userName");
            String phone = jsonObject.getString("phone");
            String birthday = jsonObject.getString("birthday");

            User user =  new User(userId,identify,accountType,onlineTime,payMonthNum,
                    saveTimeStamp,userName,phone,birthday);
            return UserService.resetUserState(user);
        } catch (JSONException e) {
           return null;
        }
    }
}
