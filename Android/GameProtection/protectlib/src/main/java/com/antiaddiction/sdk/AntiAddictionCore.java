package com.antiaddiction.sdk;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;



import com.antiaddiction.sdk.dao.UserDao;
import com.antiaddiction.sdk.entity.User;
import com.antiaddiction.sdk.service.CountTimeService;
import com.antiaddiction.sdk.service.PayStrictService;
import com.antiaddiction.sdk.service.PlayLogService;
import com.antiaddiction.sdk.service.UserService;
import com.antiaddiction.sdk.utils.AesUtil;
import com.antiaddiction.sdk.utils.LogUtil;
import com.antiaddiction.sdk.utils.RexCheckUtil;
import com.antiaddiction.sdk.view.AccountLimitTip;
import com.antiaddiction.sdk.view.RealNameAndPhoneDialog;

import org.json.JSONException;
import org.json.JSONObject;


public class AntiAddictionCore {
    private static User currentUser;
    static AntiAddictionKit.AntiAddictionCallback protectCallBack;
    private static Activity activity;
    private static boolean inited = false;

    private static Handler mainHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage( Message msg) {
            int what = msg.what;
            switch (what){
                case AntiAddictionKit.CALLBACK_CODE_LOGIN_SUCCESS:
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_LOGIN_SUCCESS,"");
                    }
                    if(getCurrentUser().getAccountType() != AntiAddictionKit.USER_TYPE_ADULT){
                        startCountTimeService();
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT:
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT,"");
                    }
                    currentUser = null;
                    CountTimeService.changeLoginState(false);
                    break;
                case AntiAddictionKit.CALLBACK_CODE_PAY_LIMIT:
                    String reason = (String) msg.obj;
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_PAY_LIMIT,reason);
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS:
                    AntiAddictionPlatform.dismissCountTimePopByLoginStateChange();
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS,"");
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_REAL_NAME_FAIL:
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_REAL_NAME_FAIL,"");
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT:
                    String orderId = (String) msg.obj;
                    if( null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT,orderId);
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_TIME_LIMIT:
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_TIME_LIMIT,"");
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME:
                    String type = (String) msg.obj;
                    if( null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME,type);
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_CHAT_LIMIT:
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_CHAT_LIMIT,"");
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_CHAT_NO_LIMIT:
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_CHAT_NO_LIMIT,"");
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_SHOWN:
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_SHOWN,"");
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_DISMISS:
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_DISMISS,"");
                    }
                    break;
                case AntiAddictionKit.CALLBACK_CODE_USER_TYPE_CHANGED:
                    if(null != protectCallBack){
                        protectCallBack.onAntiAddictionResult(AntiAddictionKit.CALLBACK_CODE_USER_TYPE_CHANGED,"");
                    }
                    break;
            }
        }
    };

    static void init(Activity activity, AntiAddictionKit.AntiAddictionCallback protectCallBack) {
        LogUtil.logd("sdk init success");
        AntiAddictionCore.activity = activity;
        AntiAddictionCore.protectCallBack = protectCallBack;
        AntiAddictionPlatform.setActivity(activity);
        inited = true;
        checkDebug();
    }

    static void setAntiAddictionCallback(AntiAddictionKit.AntiAddictionCallback protectCallBack) {
        AntiAddictionCore.protectCallBack = protectCallBack;
    }

    public static OnResultListener getCallBack(){
        return new OnResultListener() {
            @Override
            public void onResult(int type, String msg) {
                Message message = mainHandler.obtainMessage();
                message.what = type;
                message.obj = msg;
                mainHandler.sendMessage(message);
            }
        };
    }

//现在只有登录用
    static void setCurrentUser(String userId, int userType) {
        LogUtil.logd(" setCurrentUser = " + userId + " type = " + userType );
        checkInited();
        if (null != userId) {
            //登录
            if(currentUser == null) {
                currentUser = UserDao.getUser(activity, userId);
                //本地未存储用户信息
                if (null == currentUser) {
                    currentUser = new User(userId);
                    currentUser.setAccountType(userType);
                }else{
                    if(!AntiAddictionKit.getFunctionConfig().getUseSdkRealName() && currentUser.getAccountType() != userType){
                        currentUser.setAccountType(userType);
                        resetUserState();
                    }
                }
                LogUtil.logd( "getUser info = " + getCurrentUser().toJsonString());
                checkUser();
            }else{
                if(!AntiAddictionKit.getFunctionConfig().getUseSdkRealName()) {
                    if (getCurrentUser().getUserId().equals(userId) && getCurrentUser().getAccountType()!= userType) {
                        resetUserInfo(userType);
                        getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_LOGIN_SUCCESS,"");
                    }
                }
            }
        }
    }

    static void updateUserType(int userType){
        checkInited();
        if (null != currentUser) {
            if(!AntiAddictionKit.getFunctionConfig().getUseSdkRealName()) {
                if (getCurrentUser().getAccountType() != userType) {
                    resetUserInfo(userType);
                }
            }
        }
    }

    static void onResume(){
        //checkInited();
        LogUtil.logd("onResume");
        if(getCurrentUser() != null && getCurrentUser().getAccountType() != AntiAddictionKit.USER_TYPE_ADULT){
            CountTimeService.onResume();
        }
    }

    static void onStop(){
        //checkInited();
        LogUtil.logd("onStop");
        if(getCurrentUser() != null && getCurrentUser().getAccountType() != AntiAddictionKit.USER_TYPE_ADULT){
            CountTimeService.onStop();
            AntiAddictionPlatform.dismissCountTimePop(false);
        }
    }

    static void onPaySuccess(int num){
        checkInited();
        LogUtil.logd("PaySuccess");
        if(getCurrentUser() != null){
            getCurrentUser().updatePayMonthNum(num);
        }
    }

    public static User getCurrentUser(){
        return currentUser;
    }

    /**
     * 检查用户付费限制，游戏付费前调用
     * @param num
     */
    static void checkPayLimit(final int num) {
        checkInited();
        if (!AntiAddictionKit.getFunctionConfig().getUseSdkPaymentLimit()) {
            getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT, "");
            return;
        }
        LogUtil.logd("checkPayLimit");
        if(getCurrentUser() != null){
            if(getCurrentUser().getAccountType() == AntiAddictionKit.USER_TYPE_UNKNOWN){
                if(AntiAddictionKit.getFunctionConfig().getUseSdkRealName()) {
                    RealNameAndPhoneDialog.openRealNameAndPhoneDialog(2, new OnResultListener() {
                        @Override
                        public void onResult(int type, String msg) {
                            if (type == AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS) {
                                getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_USER_TYPE_CHANGED,"");
                                checkPayInMainThread(num);
                            }else{
                               // getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_REAL_NAME_FAIL,"");
                                getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_PAY_LIMIT,"not real name");
                            }
                        }
                    });
                }else{
                    getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME,AntiAddictionKit.TIP_OPEN_BY_PAY_LIMIT);
                }
            }else{
                checkPayInMainThread(num);
            }
        }
    }

    static int checkCurrentPayLimit(int num){
        checkInited();
        if (!AntiAddictionKit.getFunctionConfig().getUseSdkPaymentLimit()) {
            return AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT;
        }else{
            if(getCurrentUser() != null) {
                if (getCurrentUser().getAccountType() == AntiAddictionKit.USER_TYPE_UNKNOWN) {
                    return AntiAddictionKit.CALLBACK_CODE_PAY_LIMIT;
                }else{
                    JSONObject response = PayStrictService.checkPayLimit(num, getCurrentUser());
                    if (null != response) {
                        try {
                            int strictType = response.getInt("strictType");
                            String title = response.getString("title");
                            String desc = response.getString("desc");
                            if (strictType == 1) { //消费限制
                                AccountLimitTip.showAccountLimitTip(AccountLimitTip.STATE_PAY_LIMIT, title, desc, 1, null);
                                return AntiAddictionKit.CALLBACK_CODE_PAY_LIMIT;
                            } else {
                                return AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT;
                            }
                        } catch (JSONException e) {
                            return AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT;
                        }
                    }else{
                        return AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT;
                    }
                }
            }else {
                return AntiAddictionKit.CALLBACK_CODE_PAY_LIMIT;
            }
        }
    }

    static void checkChatLimit(){
        checkInited();
        if(getCurrentUser() != null){
            if(getCurrentUser().getAccountType() <= AntiAddictionKit.USER_TYPE_UNKNOWN){
                if(AntiAddictionKit.getFunctionConfig().getUseSdkRealName()){
                    RealNameAndPhoneDialog.openRealNameAndPhoneDialog(2, new OnResultListener() {
                        @Override
                        public void onResult(int type, String msg) {
                            if (type == AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS) {
                                getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_USER_TYPE_CHANGED,"");
                                getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_CHAT_NO_LIMIT,"");
                            }else{
                               // getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_REAL_NAME_FAIL,"");
                                getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_CHAT_LIMIT,"not real name");
                            }
                        }
                    });
                }else{
                    getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME,AntiAddictionKit.TIP_OPEN_BY_CHAT_LIMIT);
                }
            }else{
                getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_CHAT_NO_LIMIT,"");
            }
        }
    }


    private static void checkPayInMainThread(final int num){
        if(getCurrentUser() != null && AntiAddictionPlatform.getActivity() != null){
            AntiAddictionPlatform.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    JSONObject response = PayStrictService.checkPayLimit(num, getCurrentUser());
                    if (null != response) {
                        try {
                            int strictType = response.getInt("strictType");
                            String title = response.getString("title");
                            String desc = response.getString("desc");
                            if (strictType == 1) { //消费限制
                                AccountLimitTip.showAccountLimitTip(AccountLimitTip.STATE_PAY_LIMIT, title, desc, 1, new OnResultListener() {
                                    @Override
                                    public void onResult(int type, String msg) {
                                        AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_PAY_LIMIT,"child or teen pay limit");
                                    }
                                });
                            } else {
                                getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT, "");
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                }
            });
        }
    }


    static void logout() {
        checkInited();
        saveUserInfo();
        AntiAddictionPlatform.dismissCountTimePop(true);
//        if(needCallback) {
        AntiAddictionCore.getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT, "");
//        }else{
//            CountTimeService.changeLoginState(false);
//        }

        LogUtil.logd("logout success");
    }

    static int getUserType(String userId){
        checkInited();
        if(currentUser == null){
            User user = UserDao.getUser(activity,userId);
            if(user == null){
                return -1;
            }else{
                return user.getAccountType();
            }
        }else{
            return currentUser.getAccountType();
        }
    }

    static void openRealNameDialog(){
        if(currentUser == null){
            return;
        }
        if(!AntiAddictionKit.getFunctionConfig().getUseSdkRealName()){
            getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME,"");
        }else {
            RealNameAndPhoneDialog.openRealNameAndPhoneDialog(2, new OnResultListener() {
                @Override
                public void onResult(int type, String msg) {
                    if(type == AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS){
                        getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_USER_TYPE_CHANGED,"");
                        getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS,"");
                    }else{
                        getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_REAL_NAME_FAIL,"");
                    }
                }
            });
        }
    }

    static String getSdkVersion(){
        return "1.0.2.2";
    }

    /**
     * 检查用户防沉迷状态
     */
    private static void checkUser() {
        JSONObject strictData = PlayLogService.checkUserState(getCurrentUser(),true);
        boolean needShowRealName = AntiAddictionKit.getFunctionConfig().getUseSdkRealName();
        if (null != strictData) {
            try {
                final int restrictType = strictData.getInt("restrictType");//0无限制 1 宵禁 2 时长限制
                final String title = strictData.optString("title");
                final String content = strictData.optString("description");
                final int remainTime = strictData.getInt("remainTime");
                if (restrictType == 0) {
                    getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_LOGIN_SUCCESS, "");
                } else {
                    if (restrictType == 1) {
                        if(remainTime <= 0) {
                            AccountLimitTip.showAccountLimitTip(AccountLimitTip.STATE_CHILD_ENTER_STRICT,
                                    title, content, 1, new OnResultListener() {
                                        @Override
                                        public void onResult(int type, String msg) {
                                            if (type == AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT) {
                                                logout();
                                            }
                                        }
                                    });
                        }else{
                            getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_LOGIN_SUCCESS, "");
                        }
                    } else if (restrictType == 2) { //游戏时间限制或提醒 未成年人
                        if (getCurrentUser().getAccountType() > AntiAddictionKit.USER_TYPE_UNKNOWN) {
                            if (remainTime <= 0) { //无游戏时间额度
                                AccountLimitTip.showAccountLimitTip( AccountLimitTip.STATE_CHILD_ENTER_STRICT,
                                        title, content, 1, new OnResultListener() {
                                            @Override
                                            public void onResult(int type, String msg) {
                                                if(type == AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT){
                                                    logout();
                                                }
                                            }
                                        });
                            } else {
//                                AccountLimitTip.showAccountLimitTip(AccountLimitTip.STATE_CHILD_ENTER_NO_LIMIT,
//                                        title, content, 1);
                                getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_LOGIN_SUCCESS, "");
                            }
                        } else { //游客
                            if (remainTime <= 0) { //无游戏时间额度
                                OnResultListener onResultListener = new OnResultListener() {
                                    @Override
                                    public void onResult(int type, String msg) {
                                        if(type == AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME){
                                            getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME,msg);
                                            return;
                                        }
                                        if(type != AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS){
                                            if(type == AntiAddictionKit.CALLBACK_CODE_REAL_NAME_FAIL){
                                               // getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_REAL_NAME_FAIL,"");
                                            }
                                            logout();
                                        }else{
                                            getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_LOGIN_SUCCESS,"");
                                            getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_USER_TYPE_CHANGED,"");
                                        }
                                    }
                                };
                                AccountLimitTip.showAccountLimitTip(AccountLimitTip.STATE_ENTER_LIMIT, title,
                                        content, onResultListener, 1,needShowRealName);
                            } else {
                                AccountLimitTip.showAccountLimitTip(AccountLimitTip.STATE_ENTER_NO_LIMIT, title,
                                        content, new OnResultListener() {
                                            @Override
                                            public void onResult(int type, String msg) {
                                                if (type == AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT) {
                                                    logout();
                                                } else {
                                                    if (type != 0) {
                                                        getCallBack().onResult(type, msg);
                                                    }
                                                    getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_LOGIN_SUCCESS, "");
                                                }
                                            }
                                        }, 2, needShowRealName);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_LOGIN_SUCCESS, "");
            }
        }
    }

    /**
     * 更新用户实名信息
     * @param name
     * @param identify
     * @param phone
     */
    public static void resetUserInfo(String name, String identify, String phone){
        if(getCurrentUser() != null){
            User user = getCurrentUser();
            user.setUserName(name);
            user.setIdentify(identify);
            user.setPhone(phone);
            //是否是邀请码
            if(identify.length() >= 15) {
                int age = RexCheckUtil.getAgeFromIdentify(identify);
                user.setAccountType(UserService.getUserTypeByAge(age));
                user.setBirthday(RexCheckUtil.getBirthdayFromIdentify(identify));
            }else{
                user.setAccountType(AntiAddictionKit.USER_TYPE_ADULT);
            }
            try {
                //RSA加密
//                String publicKey = AntiAddictionKit.Config.getRsaPublicString().length() == 0 ?
//                        RsaUtil.getBase64Encode(RsaUtil.generateRSAKeyPair().getPublic().getEncoded()):
//                        AntiAddictionKit.Config.getRsaPublicString();
//                user.setIdentify(RsaUtil.encryptData(user.getIdentify().getBytes(),RsaUtil.loadPublicKey(publicKey)));
//                user.setPhone(RsaUtil.encryptData(user.getPhone().getBytes(),RsaUtil.loadPublicKey(publicKey)));
                //AES加密
                String passwd = AntiAddictionKit.getCommonConfig().getEncodeString().length() > 0 ? AntiAddictionKit.getCommonConfig().getEncodeString() : "test";
                user.setIdentify(AesUtil.getEncrptStr( user.getIdentify(), passwd));
                user.setPhone(AesUtil.getEncrptStr(user.getPhone(), passwd));
                LogUtil.logd(" identify = " + AesUtil.getDecryptStr(user.getIdentify(),passwd));
            } catch (Exception e) {
                e.printStackTrace();
            }
            resetGameLimitInfo();
            saveUserInfo();
        }
    }

    /**
     * 通过渠道实名认证后调用
     * @param state
     */
    private static void resetUserInfo(int state){
        if(getCurrentUser() != null) {
            User user = getCurrentUser();
            user.setAccountType(state);
            if (state > AntiAddictionKit.USER_TYPE_UNKNOWN) {
                //getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS, "");
                //渠道实名认证不通知回调
                if(AntiAddictionKit.getFunctionConfig().getUseSdkRealName()) {
                    getCallBack().onResult(AntiAddictionKit.CALLBACK_CODE_USER_TYPE_CHANGED, "");
                }
            }
                resetGameLimitInfo();
                saveUserInfo();
//            }else{
//                checkUser(false);
//            }
        }

    }

    /**
     * 重要节点保存用户信息
     */
    public static void saveUserInfo(){
        if(getCurrentUser() != null){
            UserDao.saveUser(AntiAddictionPlatform.getActivity(),getCurrentUser());
        }
    }

    /**
     * 用户实名后更新状态信息
     */
    private static void resetGameLimitInfo(){
        if(getCurrentUser() != null){
            resetUserState();
            CountTimeService.changeLoginState(false);
            if(getCurrentUser().getAccountType() < AntiAddictionKit.USER_TYPE_ADULT){
                startCountTimeService();
            }

        }
    }

    private static void startCountTimeService(){
        if(!AntiAddictionKit.getFunctionConfig().getUseSdkOnlineTimeLimit()){
            return;
        }
        CountTimeService.changeLoginState(true);
    }

    private static void resetUserState(){
        if(getCurrentUser() != null){
            User user = getCurrentUser();
            user.setOnlineTime(0);
            user.setPayMonthNum(0);
        }
    }


    private static void checkInited(){
        if(!inited){
            LogUtil.loge("sdk not init");
            throw new IllegalStateException("sdk not initial");
        }
    }

    private static void checkDebug(){
        try {
            PackageInfo packageInfo = activity.getPackageManager().getPackageInfo("com.antiaddiction.debug",0);
            LogUtil.setIsDebug(packageInfo != null);
        } catch (PackageManager.NameNotFoundException e) {
            LogUtil.setIsDebug(false);
        }
    }

}
