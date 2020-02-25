package com.antiaddiction.sdk.service;

import android.content.Context;
import android.util.Log;



import com.antiaddiction.sdk.AntiAddictionCore;
import com.antiaddiction.sdk.AntiAddictionPlatform;
import com.antiaddiction.sdk.entity.User;
import com.antiaddiction.sdk.utils.LogUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

public class CountTimeService {
    private final static String TAG = "XDCountTimeServer";
    private static boolean hasLogin = false;
    private static Timer timer;
    private static Timer tipTimer;
    private static TimerTask timerTask;
    private static TimerTask tipTimerTask;
    //倒计时当前时间，由于本地倒计时后，游戏可能会回到后台，此时该时间停止计时
    private static long tipTime = 0L;//单位为秒
    private static boolean timerHasStarted = false;
    private static int limit_strict = 0; //限制类型 0 无限制 1 宵禁 2 限制时长
    private static String tipContent;
    private static String tipTitle;
    private static Long startTimestamp;
    private static long firstResumeSendTime = 0;
    //记录上一次启动倒计时的时间戳，避免在计时期间用户切换到后台，暂停与后端时间同步,导致后端停止计时，下次请求时间错误，可能弹多次窗口
    private static volatile long lastStartTimerTime = 0;
    //当触发倒计时期间向后端发送时间戳时，定时器发送下一次起始时间需要修改
    private static volatile long lastSendGameTimeStamp = 0;
    private static boolean hasStartTipTimer = false;


    private static void initTimeTask() {
        timerTask = null;
        timerTask = new TimerTask() {
            @Override
            public void run() {
                try {
                    //判断是否是第一次发
                    long currentTime = new Date().getTime();
                    if (Math.abs(currentTime - firstResumeSendTime) <= 20) {
                        logInfo(" send first time to server for updateState");
                        //上次倒计时用掉的时间
                        long diff = lastStartTimerTime - tipTime;
                        diff = diff > 0 ? diff : 0;
                        long beginTimeStamp = currentTime / 1000 - diff;
                        if (startTimestamp != null && startTimestamp > 0) {
                            beginTimeStamp = startTimestamp;
                        }
                        lastStartTimerTime = tipTime;
                        sendGameTimeToServer(beginTimeStamp, beginTimeStamp + diff,false);
                    } else {
                        if (startTimestamp == null || startTimestamp <= 0) {
                            startTimestamp = -1L;
                        }
                        //由于在一些计时点已经发过时间了，所以定时器可能再次发送时，不到2分钟，所以这里判断上次发送后
                        //距离两分钟还剩多少时间
                        long diff = 0;
                        if (lastSendGameTimeStamp > startTimestamp) {
                            diff = lastSendGameTimeStamp - startTimestamp;
                            startTimestamp = lastSendGameTimeStamp;
                        }

                        Long endTime = startTimestamp + 2 * 60 - diff;
                        lastStartTimerTime = tipTime;
                        logInfo(" send time to server from timeTask");
                        sendGameTimeToServer(startTimestamp, endTime,false);
                        startTimestamp = endTime;
                    }
                   // lastStartTimerTime = tipTime;

                } catch (Exception e) {
                    logInfo("timerTask get error = " + e);
                    e.printStackTrace();
                }
            }
        };
    }

    public static void changeLoginState(boolean loginState) {
        logInfo(" changeLoginState = " + loginState);
        hasLogin = loginState;
        if (loginState) {
            onResume();
        } else {
            onStop();
            lastStartTimerTime = 0;
            tipTime = 0;
        }
    }

    public static void onResume() {
        logInfo(" onResume");

        if (hasLogin && !timerHasStarted) {
            startTimer();
            //记录开始发送时间戳，判断发送游戏时间时，是第一次发还是2分钟间隔后发的
            //利用第一次发送的结果更新本地限制相关状态
            firstResumeSendTime = new Date().getTime();
            startTimestamp = firstResumeSendTime;
        }

    }

    public static void onStop() {
        logInfo(" onStop");
        try {
            if (timerHasStarted) {
                stopTimer();
            }
            if (timer != null) {
                timer.cancel();
            }
            timer = null;
            //关闭倒计时
            stopTipTimer();
        } catch (Exception e) {
            logInfo(" onStop has exception = " + e.getMessage());
        }
    }

    /**
     * 游戏登录成功或进入前台开始定时发送时间戳
     */
    public static void startTimer() {
        logInfo(" start timer");
        if (hasLogin) {
            if (null == timer) {
                timer = new Timer();
            }
            initTimeTask();
            try {
                timerHasStarted = true;
                timer.schedule(timerTask, 0, 2 * 60 * 1000);
            } catch (Exception e) {
                logInfo(" startTimer error = " + e.getMessage());
            }
        }
    }

    private static Context getContext() {
        return AntiAddictionPlatform.getActivity().getApplicationContext();
    }

    /**
     * 用户登出或进入后台，停止计时器操作
     */
    public static void stopTimer() {
        logInfo(" stop timer");
        try {
            timerHasStarted = false;
            if (null != timerTask) {
                timerTask.cancel();
                timerTask = null;
            }
            if (null != timer) {
                timer.purge();
            }
        } catch (Exception e) {
            logInfo(" stop timer error = " + e);
        }
    }


    //60s倒计时结束后通知服务端,包括退到后台和登出
    public static void sendGameEndTimeToServer(int seconds, boolean isBind, boolean isLogout) {
        logInfo(" sendGameEndTimeToServer seconds = " + seconds + " isLogout = " +
                isLogout + " lastStartTimerTime = " + lastStartTimerTime + " tipTime= " +
                tipTime);
        //从小于2分钟倒计时开始到现在用了多长时间
        long time = tipTime == -1 ? (lastStartTimerTime - seconds) : (lastStartTimerTime - tipTime);
        if (isLogout || (lastStartTimerTime > 0 && tipTime == -1 && seconds <= 0)) {
            long currentTime = new Date().getTime() / 1000;
            if (startTimestamp == null || startTimestamp < 0) {
                startTimestamp = currentTime - time;
            }
            if(time > 0) {
                lastSendGameTimeStamp = startTimestamp + time;
                sendGameTimeToServer(startTimestamp, startTimestamp + time, isLogout);
            }
            tipTime = 0;
            lastStartTimerTime = tipTime;
        } else if (isBind) {
            //重新计时
            changeLoginState(false);
            changeLoginState(true);
        } else {
            tipTime = tipTime == -1 ? seconds : tipTime;
        }
    }

    /**
     * 发送游戏时间到服务器
     *
     * @param startTime
     * @param endTime
     */
    private static void sendGameTimeToServer(final Long startTime, final Long endTime,boolean isLogout) {
        logInfo(" start sendGameTimeToServer startTime = " + startTime + " endTime = " + endTime);
        User user = AntiAddictionCore.getCurrentUser();
        if (user == null) {
            return;
        }
        JSONObject response = PlayLogService.handlePlayLog(startTime, endTime, user);
        if (null != response && response.has("remainTime") && !isLogout) {
            try {
                //1 宵禁 2 在线时长限制
                int restrictType = response.getInt("restrictType");
                String description = response.getString("description");
                int remainTime = response.getInt("remainTime");
                String title = response.getString("title");
                limit_strict = restrictType;
                if (restrictType > 0) {
                    tipTitle = title;
                    tipContent = description;
//                                        if (restrictType == 1) {
//                                            XDPlatform.showCountTimePop(description, title, remainTime, 1);
//                                        } else {
                    setTimerForTip(remainTime);
//                                        }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
}


    private static void startTipTimer() {
        try {
            if (tipTime > 0 && limit_strict > 0) {
                if (tipTimer == null) {
                    tipTimer = new Timer();
                }
                if (tipTimerTask == null) {
                    tipTimerTask = new TimerTask() {
                        @Override
                        public void run() {
                            tipTime -= 1;
                            int type = (tipTime >= 15 * 60 || (15 * 60 - tipTime) <= 2) ? 1 : 0;
                            if ((type == 1 && tipTime <= 15 * 60) || tipTime <= 60) {
                                int seconds = type == 1 ? 15 * 60 : (int) tipTime;

                                //关键时间点同步时间15min , 60s
                                long diff = lastStartTimerTime - tipTime;
                                //如果在发送timer周期内（2分钟内）同步一下时间
                                if (diff < 2 * 60) {
                                    logInfo(" send time to server from tipTimerTask");
                                    sendGameTimeToServer(startTimestamp, startTimestamp + diff,false);
                                    lastSendGameTimeStamp = startTimestamp + diff;
                                    lastStartTimerTime = tipTime;
                                }
                                AntiAddictionPlatform.showCountTimePop(tipTitle, tipContent, seconds, limit_strict);
                                if (type == 0) {
                                    tipTime = -1;
                                }
                                tipTimer.purge();
                                tipTimer.cancel();
                                tipTimer = null;
                                tipTimerTask = null;
                                hasStartTipTimer = false;
                            }
                        }
                    };
                }
                tipTimer.schedule(tipTimerTask, 1000, 1000);
                hasStartTipTimer = true;
            } else {
                if (limit_strict > 0) {
                    stopTipTimer();
                    tipTime = -1;
                    AntiAddictionPlatform.showCountTimePop(tipTitle, tipContent, 0, limit_strict);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            logInfo("startTipTimer get error = " + e);
        }

    }

    private static void stopTipTimer() {
        try {
            if (null != tipTimerTask) {
                tipTimerTask.cancel();
                tipTimerTask = null;
            }
            if (null != tipTimer) {
                tipTimer.purge();
                tipTimer.cancel();
                tipTimer = null;
            }
            hasStartTipTimer = false;
        } catch (Exception e) {
            e.printStackTrace();
            logInfo(" stop tipTimer get error = " + e);
        }
    }

    private static void setTimerForTip(final int min) {
        logInfo(" setTimerForTip min = " + min + " tipTime = " + tipTime + " hasStart = " + hasStartTipTimer);
        try {
            if ((tipTime >= 0 && ((min > 60 && min <= 3 * 60) || min == 0)) || (min <= 17 * 60 && min > 15 * 60)) { //准备触发60秒或15分钟倒计时
                //重置倒计时
                tipTime = min;
                lastStartTimerTime = min;
                if (!hasStartTipTimer) {
                    startTipTimer();
                }
            } else {
                //倒计时60s中途退到后台可能的情况
                if (!hasStartTipTimer && min > 0 && min <= 60) {
                    tipTime = -1;
                    lastStartTimerTime = min;
                    AntiAddictionPlatform.showCountTimePop(tipTitle, tipContent, min, limit_strict);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            logInfo(" set tipTimer error = " + e);
        }
    }


    private static void logInfo(String message) {
        LogUtil.logd("CountTimeService " + message);
    }


}
