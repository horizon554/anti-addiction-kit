package com.antiaddiction.sdk.view;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.support.v4.content.LocalBroadcastManager;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.style.CharacterStyle;
import android.text.style.ForegroundColorSpan;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;



import com.antiaddiction.sdk.AntiAddictionPlatform;
import com.antiaddiction.sdk.AntiAddictionKit;
import com.antiaddiction.sdk.OnResultListener;
import com.antiaddiction.sdk.utils.Res;
import com.antiaddiction.sdk.utils.UnitUtils;

import java.util.regex.Pattern;

public class AccountLimitTip extends BaseDialog implements View.OnClickListener {
    //游客第一次进入游戏提示或进入游戏时长未到60分钟提示
    public final static int STATE_ENTER_NO_LIMIT = 0;
    //游客进入游戏时时长已满60分钟
    public final static int STATE_ENTER_LIMIT = 1;
    //游客在游戏中已满60分钟体验提示
    public final static int STATE_QUIT_TIP = 2;
    //游客付费时，实名信息为空
    public final static int STATE_PAY_TIP = 3;
    //未成年进入游戏时宵禁时间或游戏时间额度用完
    public final static int STATE_CHILD_ENTER_STRICT = 4;
    //未成年游戏中进入宵禁时间或游戏时间额度用完
    public final static int STATE_CHILD_QUIT_TIP = 5;
    //未成年游戏中付费或付费额度用完
    public final static int STATE_PAY_LIMIT = 6;
    //未成年人进入游戏时还有剩余时长
    public final static int STATE_CHILD_ENTER_NO_LIMIT = 7;
    //身份证信息无效，但有游戏时间
    public final static int STATE_INVALID_IDENTIFY_NO_LIMIT = 8;
    //身份信息无效，且没有游戏时间
    public final static int STATE_INVALID_IDENTIFY_LIMIT = 9;

    private static boolean IS_SHOWING = false;

    private Button bt_real;
    private Button bt_quit;
    private Button bt_enter;
    private LinearLayout ll_container,ll_switch;

    private TextView tv_content;
    private TextView tv_title;
    private TextView tv_switch;
    private String title;
    private String content;
    private int strict;
    private int state;
    //是否显示实名认证页面，如果渠道提供，则只调用回调
    private boolean needShowRealName = true;
    //付费实名认证回调
    private OnResultListener onResultListener;
    //通过其他窗口请求关闭
    private BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            int cancelState = intent.getIntExtra("state",AccountLimitTip.STATE_CHILD_ENTER_STRICT);
            if(state == cancelState && isShowing()) {
                dismiss();
            }
        }
    };
    public AccountLimitTip(Context context, int state,  String title, String content, int strict, OnResultListener onResultListener) {
        super(context);
        this.state = state;
        this.content = content == null ? "" : content;
        this.strict = strict;
        this.title = title;
        this.onResultListener = onResultListener;
        setOnShowListener(new DialogInterface.OnShowListener() {
            @Override
            public void onShow(DialogInterface dialog) {
                IS_SHOWING = true;
                LocalBroadcastManager.getInstance(getContext()).registerReceiver(broadcastReceiver,new IntentFilter("xd.dismiss.account.limit"));
            }
        });
        setOnDismissListener(new DialogInterface.OnDismissListener() {
            @Override
            public void onDismiss(DialogInterface dialog) {
                IS_SHOWING = false;
                LocalBroadcastManager.getInstance(getContext()).unregisterReceiver(broadcastReceiver);
            }
        });
    }

    public AccountLimitTip(Context context, int state, String title, String content, OnResultListener onResultListener, int strict,boolean needShowRealName) {
        this(context, state, title, content, strict,onResultListener);
        this.needShowRealName = needShowRealName;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(Res.layout(getContext(),"dialog_limit_tip"));
        setCancelable(false);

        //getWindow().setWindowAnimations(Res.style("dialogWindowAnim"));
        ll_container = (LinearLayout) findViewById("ll_tip_container");
        bt_real = (Button) findViewById("bt_guest_tip_real");
        bt_enter = (Button) findViewById("bt_guest_tip_enter");
        ll_switch = (LinearLayout) findViewById("ll_guest_tip_switch");
        bt_quit = (Button) findViewById("bt_guest_tip_quit");
        tv_content = (TextView) findViewById("tv_guest_tip_content");
        tv_title = (TextView) findViewById("tv_guest_tip_title");
        tv_switch = (TextView) findViewById("tv_switch");
        tv_switch.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);

        bt_real.setOnClickListener(this);
        bt_enter.setOnClickListener(this);
        bt_quit.setOnClickListener(this);
        ll_switch.setOnClickListener(this);

//        if(getContext().getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
//            resetLayoutParams(state);
//        }
        resetDialogStyle();

        tv_title.setText(title == null ? "健康游戏提示" : title);
        tv_content.setText(convertString(this.content));

        if(state == STATE_ENTER_LIMIT){
            //   bt_quit.setVisibility(View.GONE);
            bt_enter.setVisibility(View.GONE);
        }else if(state == STATE_ENTER_NO_LIMIT){
            bt_quit.setVisibility(View.GONE);
          //  ll_switch.setVisibility(View.GONE);
        }else if(state == STATE_QUIT_TIP){
          //  ll_switch.setVisibility(View.GONE);
            bt_enter.setVisibility(View.GONE);
        }else if(state == STATE_PAY_TIP){
            // tv_title.setText("健康消费提醒");
            ll_switch.setVisibility(View.GONE);
            bt_quit.setVisibility(View.GONE);
        }else if(state == STATE_CHILD_ENTER_STRICT){
            bt_real.setVisibility(View.GONE);
            bt_enter.setVisibility(View.GONE);
        }else if(state == STATE_CHILD_QUIT_TIP){
            bt_real.setVisibility(View.GONE);
         //   ll_switch.setVisibility(View.GONE);
            bt_enter.setVisibility(View.GONE);
        }else if(state == STATE_PAY_LIMIT){
            bt_enter.setText("返回游戏");
            bt_real.setVisibility(View.GONE);
            ll_switch.setVisibility(View.GONE);
            bt_quit.setVisibility(View.GONE);
        }else if(state == STATE_CHILD_ENTER_NO_LIMIT){
            ll_switch.setVisibility(View.GONE);
            bt_quit.setVisibility(View.GONE);
            bt_real.setVisibility(View.GONE);
        }else if(state == STATE_INVALID_IDENTIFY_NO_LIMIT){
            bt_quit.setVisibility(View.GONE);
            ll_switch.setVisibility(View.GONE);
        }else if(state == STATE_INVALID_IDENTIFY_LIMIT){
            bt_enter.setVisibility(View.GONE);
        }
        if(!AntiAddictionKit.getFunctionConfig().getShowSwitchAccountButton()){
            ll_switch.setVisibility(View.GONE);
        }

        tv_title.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                tv_title.setText(tv_title.getText() + " V" + AntiAddictionKit.getSdkVersion());
                return false;
            }
        });
    }

    private void resetLayoutParams(int state){
        int buttonNum = 0;
        if(state != STATE_CHILD_QUIT_TIP && state != STATE_PAY_LIMIT && state != STATE_CHILD_ENTER_NO_LIMIT){
            buttonNum = 1;
        }
        ViewGroup.LayoutParams layoutParams = tv_content.getLayoutParams();
        layoutParams.height = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                130 - buttonNum * 32,getContext().getResources().getDisplayMetrics());
        tv_content.setLayoutParams(layoutParams);
        tv_content.requestLayout();
    }

    private void resetDialogStyle(){
        GradientDrawable gradientDrawable = new GradientDrawable();
        gradientDrawable.setColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getDialogBackground()));
        gradientDrawable.setCornerRadius(UnitUtils.dpToPx(getContext(),8));
        ll_container.setBackground(gradientDrawable);

        tv_title.setTextColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getDialogTitleTextColor()));
        tv_content.setTextColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getDialogContentTextColor()));

        GradientDrawable buttonDrawable = new GradientDrawable();
        buttonDrawable.setCornerRadius(UnitUtils.dpToPx(getContext(),17));
        buttonDrawable.setColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getDialogButtonBackground()));
        bt_real.setBackground(buttonDrawable);
        bt_real.setTextColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getDialogButtonTextColor()));
        bt_enter.setBackground(buttonDrawable);
        bt_enter.setTextColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getDialogButtonTextColor()));

        GradientDrawable quitDrawable = new GradientDrawable();
        quitDrawable.setCornerRadius(UnitUtils.dpToPx(getContext(),17));
        quitDrawable.setStroke(UnitUtils.dpToPx(getContext(),1),Color.parseColor(AntiAddictionKit.getCommonConfig().getDialogButtonBackground()));
        quitDrawable.setColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getDialogButtonTextColor()));
        bt_quit.setTextColor(Color.parseColor(AntiAddictionKit.getCommonConfig().getDialogButtonBackground()));
        bt_quit.setBackground(quitDrawable);

    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if( id == Res.id(getContext(),"bt_guest_tip_real")){
            //通知游戏，打开渠道实名认证页面
            if(!needShowRealName){
                String type = AntiAddictionKit.TIP_OPEN_BY_ENTER_NO_LIMIT;
                if(state == STATE_ENTER_LIMIT){
                    type =AntiAddictionKit.TIP_OPEN_BY_ENTER_LIMIT;
                }else if(state == STATE_QUIT_TIP){
                    type = AntiAddictionKit.TIP_OPEN_BY_TIME_LIMIT;
                }
               callResultListener(AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME,type);
                dismiss();
                return;
            }
            if(state != STATE_QUIT_TIP && state != STATE_CHILD_QUIT_TIP) {
                RealNameAndPhoneDialog.openRealNameAndPhoneDialog(new OnResultListener() {
                    @Override
                    public void onResult(int code, String desc) {
                        //实名认证结果回调
                      callResultListener(code,desc);
                    }
                }, strict, new RealNameAndPhoneDialog.BackPressListener() {
                    @Override
                    public void onBack() {
                        if (onResultListener != null) {
                            showAccountLimitTip(state, title, content, onResultListener, strict,needShowRealName);
                        } else {
                            showAccountLimitTip(state, title, content, strict,null);
                        }
                    }
                });
            }else{
                //游客在游戏过程中时长额度用完，进入实名认证不显示关闭和返回
                RealNameAndPhoneDialog.openRealNameAndPhoneDialog(3,new OnResultListener() {
                    @Override
                    public void onResult(int code, String desc) {
                       callResultListener(code, desc);
                    }
                });
            }
            dismiss();
        }else if( id == Res.id(getContext(),"ll_guest_tip_switch")){
            callResultListener(AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT,"");
            dismiss();
        }else if( id == Res.id(getContext(),"bt_guest_tip_quit")){
            System.exit(0);
        }else if( id == Res.id(getContext(),"bt_guest_tip_enter")){
            //if( null != onResultListener) {
                //游客登录时，游戏时间额度未用完
                if(state == STATE_ENTER_NO_LIMIT || state == STATE_CHILD_ENTER_NO_LIMIT) {
                    callResultListener(0,"");
                }else if(state == STATE_PAY_LIMIT || state == STATE_PAY_TIP){//未成年人付费限制
                    callResultListener(AntiAddictionKit.CALLBACK_CODE_PAY_LIMIT,"");
                }
          //  }
            dismiss();
        }
    }

    private SpannableStringBuilder convertString(String content){
        if(content == null || content.length() == 0){
            return new SpannableStringBuilder("");
        }else if(content.contains("#")){
            SpannableStringBuilder spannableStringBuilder = new SpannableStringBuilder();
            String[] strArray = content.split("#");
            int length = strArray.length;
            int currentLength = 0;
            int hightlightIndex = 1;
            ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(Color.parseColor("#f14939"));
            for(int i = 0; i< length; i++){
                String str = strArray[i];
                spannableStringBuilder.append(str);
                if(hightlightIndex == i ){
                    hightlightIndex += 2;
                    spannableStringBuilder.setSpan(CharacterStyle.wrap(foregroundColorSpan),currentLength,
                            currentLength + str.length(),Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                }
                currentLength += str.length();
            }
            return spannableStringBuilder;
        }
        Pattern pattern = Pattern.compile("\\d+");
        String[] strArray = pattern.split(content);
        //这里注意numArray的第一个字符串为空，获取数字时需要从第二个开始
        String[] numArray = content.split("\\D+");
        int length = 0;
        ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(Color.parseColor("#f14939"));
        SpannableStringBuilder spannableStringBuilder = new SpannableStringBuilder();
        int strLength = strArray.length;
        for( int i = 0; i < strLength; i++){
            int sublength = strArray[i].length();
            spannableStringBuilder.append(strArray[i]);
            if(numArray.length > i + 1) {
                int numLength = numArray[i + 1].length();
                spannableStringBuilder.append(numArray[i + 1]);
                spannableStringBuilder.setSpan(CharacterStyle.wrap(foregroundColorSpan), length + sublength,
                        length + sublength + numLength, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                length += sublength + numLength;
            }else{
                length += sublength;
            }
        }
        return spannableStringBuilder;
    }

    private void callResultListener(int code,String msg){
        if(onResultListener != null){
            onResultListener.onResult(code,msg);
        }
    }

    public static void showAccountLimitTip(final int state, final String title, final String content, final int strict, final OnResultListener onResultListener){
        if(!AccountLimitTip.IS_SHOWING || state == STATE_QUIT_TIP || state == STATE_CHILD_QUIT_TIP) {
            if(AccountLimitTip.IS_SHOWING){
                Intent intent = new Intent("xd.dismiss.account.limit");
                intent.putExtra("state",AccountLimitTip.STATE_PAY_LIMIT);
                LocalBroadcastManager.getInstance(AntiAddictionPlatform.getActivity()).sendBroadcast(intent);
            }
           AntiAddictionPlatform.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        AccountLimitTip accountLimitTip = new AccountLimitTip(AntiAddictionPlatform.getActivity(),
                                state, title, content, strict,onResultListener);
                        accountLimitTip.show();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });
        }
    }

    public static void showAccountLimitTip(final int state, final String title, final String content, final OnResultListener onResultListener, final int strict, final boolean needShowRealName){
        if(!AccountLimitTip.IS_SHOWING) {
            AntiAddictionPlatform.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        AccountLimitTip accountLimitTip = new AccountLimitTip(AntiAddictionPlatform.getActivity(),
                                state, title, content, onResultListener, strict,needShowRealName);
                        accountLimitTip.show();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });
        }
    }
}
