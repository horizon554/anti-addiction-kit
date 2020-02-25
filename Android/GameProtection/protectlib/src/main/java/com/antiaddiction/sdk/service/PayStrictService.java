package com.antiaddiction.sdk.service;

import com.antiaddiction.sdk.AntiAddictionKit;
import com.antiaddiction.sdk.entity.User;

import org.json.JSONException;
import org.json.JSONObject;

public class PayStrictService {

    public static JSONObject checkPayLimit(int num, User user){
        int strictType = 0; // 1限制 2提示
        String title = "健康消费提示";
        String desc = "";
        if(user == null){
            return null;
        }
        if(user.getAccountType() == AntiAddictionKit.USER_TYPE_CHILD){
            strictType = 1;
            desc = "根据国家相关规定，当前您无法使用充值相关功能。";
        }else if(user.getAccountType() == AntiAddictionKit.USER_TYPE_TEEN){
            if(num > AntiAddictionKit.getCommonConfig().getTeenPayLimit()){
                strictType = 1;
                desc = "根据国家相关规定，您本次付费金额超过规定上限，无法购买。请适度娱乐，理性消费。";
            }else{
                if((user.getPayMonthNum()  + num) > AntiAddictionKit.getCommonConfig().getTeenMonthPayLimit()){
                    strictType = 1;
                    desc = "根据国家相关规定，您当月的剩余可用充值额度不足，无法购买此商品。请适度娱乐，理性消费。";
                }
//                else {
//                    if (num + user.getPayMonthNum() > AntiAddictionKit.getCommonConfig().getTeenMonthPayLimit()) {
//                        strictType = 1;
//                        desc = "根据国家相关规定，您当月的剩余可用充值额度不足，无法购买此商品。请适度娱乐，理性消费";
//                    }
//                }
            }
        }else if(user.getAccountType() == AntiAddictionKit.USER_TYPE_YOUNG){
            if(num > AntiAddictionKit.getCommonConfig().getYoungPayLimit()){
                strictType = 1;
                desc = "根据国家相关规定，您本次付费金额超过规定上限，无法购买。请适度娱乐，理性消费。";
            }else{
                if((user.getPayMonthNum() + num) > AntiAddictionKit.getCommonConfig().getYoungMonthPayLimit()){
                    strictType = 1;
                    desc = "根据国家相关规定，您当月的剩余可用充值额度不足，无法购买此商品。请适度娱乐，理性消费。";
                }
//                else {
//                    if (num + user.getPayMonthNum() > AntiAddictionKit.getCommonConfig().getYoungMonthPayLimit()) {
//                        strictType = 1;
//                        desc = "根据国家相关规定，您当月的剩余可用充值额度不足，无法购买此商品。请适度娱乐，理性消费";
//                    }
//                }
            }
        }
        JSONObject response = new JSONObject();
        try {
            response.put("strictType",strictType);
            response.put("title",title);
            response.put("desc",desc);
        } catch (JSONException e) {
            return null;
        }
        return response;
    }
}
