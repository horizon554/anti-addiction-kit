package com.seraph.gameprotection;

import androidx.appcompat.app.AppCompatActivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.antiaddiction.sdk.AntiAddictionKit;
import com.antiaddiction.sdk.AntiAddictionPlatform;


public class MainActivity extends AppCompatActivity implements View.OnClickListener {
    Button login,login2,pay,init_land,init_port,logout,chat,thirdInit,dialogFloat,pay2;
    TextView textView;
    AntiAddictionKit.AntiAddictionCallback protectCallBack;
    int payNum = 0;
    String userId = "userId1";
    BroadcastReceiver broadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            textView.setText("剩余： " + intent.getIntExtra("time",0) + " 秒");
        }
    };
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);
       AntiAddictionKit.getCommonConfig()
               .gusterTime( 30)
               .childCommonTime(20 * 60)
               .youngMonthPayLimit(200 * 100)
               .teenMonthPayLimit(150 * 100)
               .dialogBackground("#00ff00");

       AntiAddictionKit.getFunctionConfig()
               .showSwitchAccountButton(false)
               .useSdkOnlineTimeLimit(true);

        login = findViewById(R.id.login);
        login2 = findViewById(R.id.login2);
        pay = findViewById(R.id.pay);
        pay2 = findViewById(R.id.pay2);
        logout = findViewById(R.id.logout);
        init_land = findViewById(R.id.init_land);
        init_port = findViewById(R.id.init_port);
        textView = findViewById(R.id.tv_time);
        chat = findViewById(R.id.chat);
        thirdInit = findViewById(R.id.init_third);
        dialogFloat = findViewById(R.id.bt_float);

        login.setOnClickListener(this);
        login2.setOnClickListener(this);
        pay.setOnClickListener(this);
        pay2.setOnClickListener(this);
        logout.setOnClickListener(this);
        init_port.setOnClickListener(this);
        init_land.setOnClickListener(this);
        chat.setOnClickListener(this);
        thirdInit.setOnClickListener(this);
        dialogFloat.setOnClickListener(this);
        dialogFloat.setVisibility(View.GONE);

        login.setEnabled(false);
        login2.setEnabled(false);
        logout.setEnabled(false);
        pay.setEnabled(false);
        pay2.setEnabled(false);
        chat.setEnabled(false);
        protectCallBack = new AntiAddictionKit.AntiAddictionCallback() {
            @Override
            public void onAntiAddictionResult(int resultCode, String msg) {
                switch (resultCode){
                    case AntiAddictionKit.CALLBACK_CODE_SWITCH_ACCOUNT:
                        toast("logout success");
                        login.setEnabled(true);
                        login2.setEnabled(true);
                        pay.setEnabled(false);
                        pay2.setEnabled(false);
                        logout.setEnabled(false);
                        chat.setEnabled(false);
                        break;
                    case AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT:
                        toast(" pay no limit");
                        AntiAddictionKit.paySuccess(payNum);
                        break;
                    case AntiAddictionKit.CALLBACK_CODE_PAY_LIMIT:
                        toast("pay limit");
                         break;
                    case AntiAddictionKit.CALLBACK_CODE_REAL_NAME_SUCCESS:
                        toast("realName success");
                         break;
                    case AntiAddictionKit.CALLBACK_CODE_REAL_NAME_FAIL:
                        toast("realName fail");
                        break;
                    case AntiAddictionKit.CALLBACK_CODE_TIME_LIMIT:
                        toast("time limit ");
                        break;
                    case AntiAddictionKit.CALLBACK_CODE_OPEN_REAL_NAME:
                       toast("open realName");
                       //假设通过第三方实名成功
                       AntiAddictionKit.updateUserType(AntiAddictionKit.USER_TYPE_CHILD);
                       if(msg.equals(AntiAddictionKit.TIP_OPEN_BY_PAY_LIMIT)){
                           AntiAddictionKit.checkPayLimit(payNum);
                       }
                       //注意：如果这个过程中游戏处在付费流程中，此时应该再调用一次CheckPayLimit();
                       break;
                    case AntiAddictionKit.CALLBACK_CODE_CHAT_LIMIT:
                        toast("chat limit");
                        break;
                    case AntiAddictionKit.CALLBACK_CODE_CHAT_NO_LIMIT:
                        toast("chat no limit");
                        break;
                    case AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_DISMISS:
                        Log.d("config","AAK WINDOW DISMISS");
                        break;
                    case AntiAddictionKit.CALLBACK_CODE_AAK_WINDOW_SHOWN:
                        Log.d("config","AAK WINDOW SHOW");
                        break;
                    case AntiAddictionKit.CALLBACK_CODE_USER_TYPE_CHANGED:
                        toast("USER TYPE CHANGE");
                }
            }
        };
    }

    @Override
    protected void onResume() {
        super.onResume();
        AntiAddictionKit.onResume();
        LocalBroadcastManager.getInstance(this).registerReceiver(broadcastReceiver,new IntentFilter("time.click"));

    }

    @Override
    protected void onStop() {
        super.onStop();
        AntiAddictionKit.onStop();
        LocalBroadcastManager.getInstance(this).unregisterReceiver(broadcastReceiver);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        switch (id){
            case R.id.pay:
                payNum = 200 * 100;
                //AntiAddictionKit.checkPayLimit(30 * 100);
                int result = AntiAddictionKit.checkCurrentPayLimit(payNum);
               Toast.makeText(this, " result = " + result, Toast.LENGTH_LONG).show();
                break;
            case R.id.pay2:
                payNum = 120 * 100;
                AntiAddictionKit.checkPayLimit(120 * 100);
                break;
            case R.id.init_land:
                AntiAddictionKit.getFunctionConfig().useSdkRealName(true)
                        .useSdkOnlineTimeLimit(true);
                AntiAddictionKit.init(this,protectCallBack);
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                init_land.setEnabled(false);
                init_port.setEnabled(false);
                thirdInit.setEnabled(false);
                login.setEnabled(true);
                login2.setEnabled(true);
                break;
            case R.id.init_port:
                AntiAddictionKit.getFunctionConfig().useSdkRealName(true)
                        .useSdkOnlineTimeLimit(true);
                AntiAddictionKit.init(this,protectCallBack);
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                init_land.setEnabled(false);
                init_port.setEnabled(false);
                thirdInit.setEnabled(false);
                login.setEnabled(true);
                login2.setEnabled(true);
                break;
            case R.id.login:
                userId = "userid1";
                AntiAddictionKit.login("userid1",0);
                pay.setEnabled(true);
                pay2.setEnabled(true);
                logout.setEnabled(true);
                chat.setEnabled(true);
                login.setEnabled(false);
                login2.setEnabled(false);
                break;
            case R.id.login2:
                userId = "userid2";
                AntiAddictionKit.login("userid2",AntiAddictionKit.USER_TYPE_CHILD);
                pay.setEnabled(true);
                pay2.setEnabled(true);
                logout.setEnabled(true);
                chat.setEnabled(true);
                login.setEnabled(false);
                login2.setEnabled(false);
                break;
            case R.id.logout:
                AntiAddictionKit.logout();
                break;
            case R.id.chat:
                AntiAddictionKit.checkChatLimit();
                break;
            case R.id.init_third:
                AntiAddictionKit.getFunctionConfig().useSdkRealName(false)
                        .useSdkOnlineTimeLimit(true);
                AntiAddictionKit.init(this,protectCallBack);
                init_land.setEnabled(false);
                init_port.setEnabled(false);
                thirdInit.setEnabled(false);
                login.setEnabled(true);
                login2.setEnabled(true);
                break;
            case R.id.bt_float:
                AntiAddictionPlatform.showCountTimePop("测试","测试内容。。。。。。",30,1);
                break;

        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if(keyCode == KeyEvent.KEYCODE_BACK){
            System.exit(0);
            return true;
        }else {
            return super.onKeyDown(keyCode, event);
        }
    }

    void toast(String msg){
        Toast.makeText(this,msg,Toast.LENGTH_SHORT).show();
    }
}
