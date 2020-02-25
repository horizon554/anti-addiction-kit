package com.antiaddiction.sdk;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.support.v4.content.LocalBroadcastManager;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.CharacterStyle;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageButton;
import android.widget.PopupWindow;
import android.widget.TextView;


import com.antiaddiction.sdk.entity.User;
import com.antiaddiction.sdk.service.CountTimeService;
import com.antiaddiction.sdk.utils.LogUtil;
import com.antiaddiction.sdk.utils.Res;
import com.antiaddiction.sdk.utils.UnitUtils;
import com.antiaddiction.sdk.view.AccountLimitTip;
import com.antiaddiction.sdk.view.RealNameAndPhoneDialog;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Pattern;

public class AntiAddictionPlatform {
    public static final int SHOW_COUNT_TIME_POP = 100105;
    public static final int DISMISS_COUNT_TIME_POP = 100106;
    public static final int CHANGE_COUNT_TIME_POP = 100107;
    public static final int DISMISS_COUNT_TIME_POP_SIMPLE = 100108;

    //游戏内防沉迷时间倒计时提醒
    private static PopupWindow mCountTimePop;
    private static Timer countTimeTimer;
    private static volatile int currentTimerTime = 0;
    private static Activity activity;

    public static void setActivity(Activity activity){
        AntiAddictionPlatform.activity = activity;
    }
    public static Activity getActivity(){
        return activity;
    }



    /***
     *
     * @param seconds 剩余时长秒数
     * @param strict 限制规则   //1 宵禁 2 在线时长限制
     */
    public static void showCountTimePop(String title ,String desc, int seconds, int strict){
        LogUtil.logd("showCountTimePop title = " + title + " seconds = " + seconds + "strict = " + strict);
        if(AntiAddictionCore.getCurrentUser() == null || strict == 0){
            return;
        }
        //为避免显示冲突，优先已本地时间为准
        if(seconds > 0 && seconds <= 60 && mCountTimePop != null && mCountTimePop.isShowing() &&
                currentTimerTime > 0 && currentTimerTime <=60){
            return;
        }
        if(seconds > 0) {
            Message message = alert_mHandler.obtainMessage();
            message.arg1 = seconds;
            message.arg2 = strict;
            JSONObject content = new JSONObject();
            String showDesc = " ";
            try {
                if (strict == 2) {
                    //游客
                    if (AntiAddictionCore.getCurrentUser().getAccountType() == AntiAddictionKit.USER_TYPE_UNKNOWN){
                        if (seconds > 60) { //15min提示
                            showDesc = "您的游戏体验时间还剩余 15 分钟，登记实名信息后可深度体验。";
                        } else { //60倒计时
                            showDesc = "您的游戏体验时间还剩余 " + seconds +" 秒，登记实名信息后可深度体验。";
                        }
                    } else {//未成年人
                        if (seconds > 60) {
                            showDesc = "您今日游戏时间还剩余 15 分钟，请注意适当休息。";
                        } else {
                            showDesc = "您今日游戏时间还剩余 "+ seconds +" 秒，请注意适当休息。";
                        }
                    }
                }else if(strict == 1){ //宵禁
                    if (seconds > 60) {
                        showDesc = "距离健康保护时间还剩余 15 分钟，请注意适当休息。";
                    } else {
                        showDesc = "距离健康保护时间还剩余 "+ seconds +" 秒，请注意适当休息。";
                    }
                }
                content.put("desc", showDesc);
                content.put("title", title);
                content.put("finalDesc",desc);
            } catch (Exception e) {
                e.printStackTrace();
            }
            message.obj = content;
            message.what = SHOW_COUNT_TIME_POP;
            alert_mHandler.sendMessage(message);
        }else{
            currentTimerTime = seconds;
            dismissCountTimePop( title, desc);
        }
    }
    //onStop或logout或者重复登录
    public static void dismissCountTimePop(boolean isLogout){
        LogUtil.logd(" dismissCountTimePop isLogout= " + isLogout);
        Message message = alert_mHandler.obtainMessage();
        message.arg2 = isLogout ? 1 :0;
        message.what = DISMISS_COUNT_TIME_POP;
        alert_mHandler.sendMessage(message);
    }

    //游戏中通过改变账号状态触发
    public static void dismissCountTimePopByLoginStateChange(){
        User user = AntiAddictionCore.getCurrentUser();
        //用户已登录再次调用表明是升级账号或已通过实名认证
        if(user != null ){
            Message message = alert_mHandler.obtainMessage();
            message.arg1 = 1 ;
            message.what = DISMISS_COUNT_TIME_POP;
            alert_mHandler.sendMessage(message);
        }else{
            dismissCountTimePopSimple();
        }

    }

    //仅仅是关闭浮窗，例如当显示实名认证页面的时候
    public static void dismissCountTimePopSimple(){
        LogUtil.logd("dismissCountTimePopSimple");
        Message message = alert_mHandler.obtainMessage();
        message.what = DISMISS_COUNT_TIME_POP_SIMPLE;
        alert_mHandler.sendMessage(message);
    }

    //倒计时结束后操作或showCountTimePop传入的seconds为0
    private static void dismissCountTimePop(String title,String desc){
        Message message = alert_mHandler.obtainMessage();
        message.what = DISMISS_COUNT_TIME_POP;
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("title",title);
            jsonObject.put("desc",desc);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        message.obj = jsonObject;
        alert_mHandler.sendMessage(message);
    }

    private static void initCountTimePop(final String title, String content, int seconds, final String fianlDesc){
        if( null == mCountTimePop){
            mCountTimePop = new PopupWindow();
            View view = LayoutInflater.from(activity).inflate(Res.layout(getActivity(),"pop_count_time_tip"),null);
            GradientDrawable gradientDrawable = new GradientDrawable();
            gradientDrawable.setColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getPopBackground()));
            if(activity.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
                gradientDrawable.setCornerRadius(UnitUtils.dpToPx(getActivity(),8));
            }else{
                gradientDrawable.setCornerRadius(UnitUtils.dpToPx(getActivity(),16));
            }
            view.setBackground(gradientDrawable);
            mCountTimePop.setContentView(view);
            mCountTimePop.setOutsideTouchable(false);
            if(activity.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT){
                mCountTimePop.setWidth((int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,350,activity.getResources().getDisplayMetrics()));
                mCountTimePop.setHeight((int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,65,activity.getResources().getDisplayMetrics()));
            }else {
                mCountTimePop.setHeight((int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,41,activity.getResources().getDisplayMetrics()));
                mCountTimePop.setWidth((int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 520, activity.getResources().getDisplayMetrics()));
            }
        }else{
            if(mCountTimePop.isShowing()){
                mCountTimePop.dismiss();
            }
        }
        currentTimerTime = seconds;
        View view = mCountTimePop.getContentView();
        final TextView tv_content = (TextView) view.findViewById(Res.id(activity,"tv_pop_count_content"));
        tv_content.setTextColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getPopTextColor()));
        tv_content.setMovementMethod(LinkMovementMethod.getInstance());
        ImageButton ib_close = (ImageButton) view.findViewById(Res.id(activity,"ib_pop_count_close"));
        ib_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCountTimePop.dismiss();
            }
        });
        tv_content.setText(getSpannableString(content,false,seconds));
        if (seconds <= 60) {
            if (countTimeTimer == null) {
                countTimeTimer = new Timer();
                final TimerTask timerTask = new TimerTask() {
                    @Override
                    public void run() {
                        currentTimerTime --;
                        if(currentTimerTime >= 0) {
                            Message message = alert_mHandler.obtainMessage();
                            message.what = CHANGE_COUNT_TIME_POP;
                            message.arg1 = currentTimerTime;
                            alert_mHandler.sendMessage(message);
                        } else{
                            countTimeTimer.purge();
                            countTimeTimer.cancel();
                            countTimeTimer = null;
                            dismissCountTimePop(title,fianlDesc);
                        }
                    }
                };
                countTimeTimer.schedule(timerTask, 1000, 1000);
            }
        }
        int top = getActivity().getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT ? 100 : 40;
        mCountTimePop.showAtLocation(getActivity().getWindow().getDecorView(), Gravity.CENTER_HORIZONTAL | Gravity.TOP, 0,
                (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,top,getActivity().getResources().getDisplayMetrics()));
    }

    private static void changeCountTimePop(int seconds){
        if( null != mCountTimePop && mCountTimePop.isShowing()){
            try {
                View view = mCountTimePop.getContentView();
                final TextView tv_content = (TextView) view.findViewById(Res.id(getActivity(),"tv_pop_count_content"));
                tv_content.setText(getSpannableString(tv_content.getText().toString(),true,seconds));
            }catch (Exception e){
                e.printStackTrace();
            }
        }
    }

    private static SpannableStringBuilder getSpannableString(String content, boolean replaceNum, int seconds){
        if(content == null){
            return new SpannableStringBuilder("");
        }
        Pattern pattern = Pattern.compile("\\d+");
        String[] strArray = pattern.split(content);
        //这里注意numArray的第一个字符串为空，获取数字时需要从第二个开始
        String[] numArray = content.split("\\D+");
        if(numArray.length > 1 && replaceNum) {
            numArray[1] = seconds + "";
        }
        int length = 0;
        ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(Color.parseColor("#f14939"));
        ClickableSpan clickableSpan = new ClickableSpan() {
            @Override
            public void onClick(View widget) {
                AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_SHOWN,"");
                RealNameAndPhoneDialog.openRealNameAndPhoneDialog(2);
                mCountTimePop.dismiss();
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.parseColor("#ff6600"));
                ds.setUnderlineText(false);
            }
        };
        SpannableStringBuilder spannableStringBuilder = new SpannableStringBuilder();

        int strLength = strArray.length;
        for (int i = 0; i < strLength; i++) {
            int sublength = strArray[i].length();
            spannableStringBuilder.append(strArray[i]);
            //需要让"实名认证"可点击
            if( strArray[i].contains("登记实名信息")){
                int start = strArray[i].indexOf("登记实名信息");
                spannableStringBuilder.setSpan(clickableSpan,length + start,length + start + 6,
                        Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            }
            //让数字高亮
            if (numArray.length > i + 1) {
                int numLength = numArray[i + 1].length();
                spannableStringBuilder.append(numArray[i + 1]);
                spannableStringBuilder.setSpan(CharacterStyle.wrap(foregroundColorSpan), length + sublength,
                        length + sublength + numLength, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                length += sublength + numLength;
            } else {
                length += sublength;
            }
        }
        return spannableStringBuilder;
    }

    private static final Handler alert_mHandler = new Handler(Looper.getMainLooper()) {
        public void handleMessage(android.os.Message msg) {
            try {
                switch (msg.what) {
                    case SHOW_COUNT_TIME_POP:
                        int seconds = msg.arg1;
                        int strict = msg.arg2;
                        try {
                            JSONObject content = (JSONObject) msg.obj;
                            String title = content.getString("title");
                            String desc = content.getString("desc");
                            String finalDesc = content.getString("finalDesc");
                            //时长限制
                            // if (strict == 2) {
                            initCountTimePop(title, desc, seconds, finalDesc);
//                        } else if (strict == 1) { //宵禁
//                            AccountLimitTip.showAccountLimitTip(AccountLimitTip.STATE_CHILD_QUIT_TIP, title, desc, 1);
//                        }
                        }catch (Exception e){
                            e.printStackTrace();
                        }
                        break;
                    case DISMISS_COUNT_TIME_POP:
                        if (mCountTimePop != null && mCountTimePop.isShowing()) {
                            mCountTimePop.dismiss();
                        }
                        try {
                            if (countTimeTimer != null) {
                                //关闭定时器
                                countTimeTimer.purge();
                                countTimeTimer.cancel();
                                countTimeTimer = null;
                            }
                        }catch (Exception e){
                            e.printStackTrace();
                        }
                        boolean isLogout = msg.arg2 > 0;
                        boolean isBind = msg.arg1 > 0;
                        if(isBind){
                            try{
                                Intent intent = new Intent("xd.dismiss.account.limit");
                                intent.putExtra("state",AccountLimitTip.STATE_QUIT_TIP);
                                LocalBroadcastManager.getInstance(getActivity()).sendBroadcast(intent);
                            }catch (Exception e){
                                e.printStackTrace();
                            }
                        }
                            //将60s倒计时结果发送给后端
                            CountTimeService.sendGameEndTimeToServer(currentTimerTime, isBind, isLogout);


                        if(msg.obj == null){
                            return;
                        }
                        try {
                            JSONObject jsonObject = (JSONObject) msg.obj;
                            String titleInf = jsonObject.optString("title");
                            String contentInf = jsonObject.optString("desc");
                            User user = AntiAddictionCore.getCurrentUser();
                            if (user == null) {
                                return;
                            }
                            //弹出提示，停止计时
                            CountTimeService.onStop();
                            //未成年限制或宵禁
                            AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_TIME_LIMIT,"");
                            AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_SHOWN,"");
                            if (user.getAccountType() > AntiAddictionKit.USER_TYPE_UNKNOWN){
                                AccountLimitTip.showAccountLimitTip(AccountLimitTip.STATE_CHILD_QUIT_TIP, titleInf, contentInf, 2, new OnResultListener() {
                                    @Override
                                    public void onResult(int type, String msg) {
                                        if(type == AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT){
                                            AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_DISMISS,"");
                                            AntiAddictionCore.logout();
                                        }
                                    }
                                });
                            } else { //游客限制
                                if (!RealNameAndPhoneDialog.Real_Showing) {
                                    if (user.getAccountType() <= AntiAddictionKit.USER_TYPE_UNKNOWN){
                                        AccountLimitTip.showAccountLimitTip(AccountLimitTip.STATE_QUIT_TIP, titleInf, contentInf, 3, new OnResultListener() {
                                            @Override
                                            public void onResult(int type, String msg) {
                                                if(type == AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT){
                                                    AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_DISMISS,"");
                                                    AntiAddictionCore.logout();
                                                }else if(type == AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME){
                                                    AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_DISMISS,"");
                                                    AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME,msg);
                                                }else{
                                                    if(type == AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS){
                                                       // AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS,msg);
                                                        AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_DISMISS,"");
                                                         AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_USER_TYPE_CHANGED,msg);
                                                    }
                                                }
                                            }
                                        });
                                    }
                                } else {
                                    //通知实名认证页面禁用返回和关闭按钮
                                    Intent intent = new Intent("real_name.close_unable");
                                    LocalBroadcastManager.getInstance(getActivity()).sendBroadcast(intent);
                                }
                            }
                        }catch (Exception e){
                            e.printStackTrace();
                        }
                        break;
                    case CHANGE_COUNT_TIME_POP:
                        int changeSecond = msg.arg1;
                        changeCountTimePop(changeSecond);
                        break;
                    case DISMISS_COUNT_TIME_POP_SIMPLE:
                        if(mCountTimePop != null && mCountTimePop.isShowing()){
                            mCountTimePop.dismiss();
                        }
                        break;
                    default:
                        break;
                }
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
            }

        }
    };

    /**
     * @brief 退出登陆
     */
    public void logout() {
        AntiAddictionPlatform.dismissCountTimePop(true);
    }
}
