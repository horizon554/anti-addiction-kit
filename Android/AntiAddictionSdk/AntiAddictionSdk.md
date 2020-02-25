##<center>AntiAddictionSDK_v1.0.2（Android)对接文档</center>

###1.配置参数（采用默认值可跳过）
#### （1）功能性参数列表如下：

参数名称 | 参数类型 | 参数默认值 | 参数说明 
--- |--- |--- | ---
useSdkRealName | boolean | true | 是否使用 SDK 实名认证功能
useSdkPaymentLimit | boolean | true | 是否使用 SDK 付费限制
useSdkOnlineTimeLimit | boolean | true | 是否使用 SDK 在线时长限制
showSwitchAccountButton | boolean | true | 是否显示切换账号按钮

调用方式示例：

```
AntiAddictionKit.getFunctionConfig()
	 		.useSdkRealName(true)
     		.useSdkOnlineTimeLimit(true);
```
或直接传递三个对应参数（参数顺序：useRealName, usePaymentLimit, useOnlineTimeLimit)，用例如下：

```
AntiAddictionKit.resetFunctionConfig(true,true,true);

```

####（2）数据设置和外观参数
调用方式如下：

```
AntiAddictionKit.getCommonConfig()
			.gusterTime(3 *60)
			.dialogContentTextColor("#00ff00");

```
可设置的参数列表如下：

参数名称 | 参数类型 | 参数默认值 | 参数说明 
--- |--- |--- | ---
guestTime | int | 60 * 60 | 游客每日游戏时长，默认1小时，单位 秒
nightStrictStart | int | 22 * 60 * 60 |未成年宵禁起始时间，默认晚上10点，单位 秒
nightStrictEnd | int | 8 * 60 * 60 | 未成年宵禁截止时间，默认次日8点， 单位 秒
childCommonTime | int | 90 * 60 | 未成年人非节假日每日游戏时长，默认1.5小时，单位 秒
childHolidayTime | int | 3 * 60 * 60 | 未成年人节假日每日游戏时长，默认3小时，单位 秒
teenPayLimit | int | 50 * 10 * 10 | 未成年人（8-15岁）每日充值限额，默认50元，单位 分
teenMonthPayLimit | int | 300 * 10 * 10 | 未成年人（8-15岁）每月充值限额，默认300元，单位 分
youngPayLimit | int | 100 * 10 * 10 | 未成年人（16-17岁）每日充值限额，默认100元，单位 分
youngMonthPayLimit | int | 400 * 10 * 10 | 未成年人（16-17岁）每月充值限额，默认400元， 单位 分
dialogBackground | String | #ffffff | sdk弹窗背景颜色
dialogContentTextColor | String | #999999 | sdk弹框内容字体颜色
dialogTitleTextColor | String | #2b2b2b | 弹框标题字体颜色
dialogButtonBackground | String | #000000 |弹框按钮背景颜色
dialogButtonTextColor | String | #ffffff | 弹框按钮字体颜色
dialogEditTextColor | String | #000000 | 弹框输入框字体颜色
popBackground | String | #cc000000 | 倒计时浮窗背景颜色
popTextColor | String | #ffffff | 倒计时浮窗字体颜色
tipBackground | String | #ffffff | 提示浮窗背景颜色
tipTextColor | String | #000000 | 提示浮窗字体颜色
encodeString | String | test | 用户实名信息加密秘钥（AES）

###2.初始化
示例如下：

```
 AntiAddictionKit.init(activity,protectCallBack);

```
其中ProtectCallBack 为回调监听实例，具体创建方法如下：

```
protectCallBack = new AntiAddictionKit.AntiAddictionCallback() {
            @Override
            public void onAntiAddictionResult(int resultCode, String msg) {
             switch (resultCode){
                    case AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT:
           			 ···
            }
 }

```
回调中会返回对应的回调类型和信息，sdk 中主要应用的如下：
<a name="callback"></a>

回调类型 | 类型值 |  触发条件 | 附带信息
--- | --- | --- | ---
CALLBACK\_CODE\_LOGIN\_SUCCESS | 500 | 登录通过，当游戏调用 login 后用户完成登录流程 | 无
CALLBACK\_CODE\_SWITCH_ACCOUNT | 1000 | 切换账号，当用户因防沉迷机制受限时，登录认证失败或选择切换账号时会触发 | 无
CALLBACK\_CODE\_USER\_TYPE\_CHANGED | 1500 | 用户类型变更，通过SDK完成实名会触发 | 无
CALLBACK\_CODE\_REAL\_NAME\_SUCCESS | 1010 | 实名成功，仅当游戏主动调用 openRealName 方法时，如果成功会触发 | 无
CALLBACK\_CODE\_REAL\_NAME\_FAIL | 1015 | 实名失败，仅用游戏主动调用 openRealName 方法时，如果用户取消会触发 | 无
CALLBACK\_CODE\_PAY\_NO\_LIMIT | 1020 | 付费不受限，sdk检查用户付费无限制时触发| 无
CALLBACK\_CODE\_PAY\_LIMIT | 1025 | 付费受限，付费受限触发,包括游客未实名或付费额达到限制等 | 触发原因
CALLBACK\_CODE\_TIME\_LIMIT | 1030 | 时间受限，未成年人或游客游戏时长已达限制，通知游戏 | 无
CALLBACK\_CODE\_OPEN\_REAL\_NAME | 1060 | 打开实名窗口，需要游戏通过其他方式完成用户实名时触发 | 触发原因提示，包括 "PAY\_LIMIT","CHAT_LIMIT"等
CALLBACK\_CODE\_CHAT\_NO\_LIMIT | 1080 | 聊天无限制，用户已通过实名，可进行聊天 | 无
CALLBACK\_CODE\_CHAT\_LIMIT | 1090 | 聊天限制，用户未通过实名，不可进行聊天 | 无
CALLBACK\_CODE\_AAT\_WINDOW\_SHOWN | 2000 | 额外弹窗显示，当用户操作触发额外窗口显示时通知游戏 | 无
CALLBACK\_CODE\_AAK\_WINDOW\_DISMISS | 2500 | 额外弹窗显示，额外窗口消失时通知游戏 



####注意：关于 "USER\_TYPE\_CHANGED" 的回调，触发时机可能不唯一，当用户在付费或其他需要实名的时候，完成实名过程都会触发相应回调，所以不建议在这两个回调中做UI相关或任何阻塞线程的事情。

###3.设置用户信息
<a name ="update_user"></a>

相关接口参数说明:

用户相关参数 | 类型 | 说明
--- | --- | ---
userId | `String` | 用户的唯一标识
userType | `Int` | 用户实名类型

userType 可选参数如下：

<a name="登录类型"></a>

参数 | 参数值 | 参数说明
--- | --- | ---
USER\_TYPE\_UNKNOWN | 0 | 依赖SDK获取实名信息或第三方获取的信息为未实名
USER\_TYPE\_CHILD | 1 | 未成年人（8岁以下）
USER\_TYPE\_TEEN | 2 | 未成年人（8-16岁）
USER\_TYPE\_YOUNG | 3 | 未成年人（16-17岁）
USER\_TYPE\_ADULT | 4 | 成年人

####（1）登录
登录接口应只在游戏登录过程中、登出后以及收到回调 [”SWITCH\_ACCOUNT"](#callback) 时调用。示例如下:

```
 AntiAddictionKit.login("userid1",0);
```
第一个参数为 userId , 第二个参数为 userType , 具体类型值参考 [上表](#登录类型) 。

<a name="更新用户类型"></a>

####（2）更新用户类型
当游戏通过第三方实名后，需要将实名信息更新到 SDK 中，具体示例如下：

```
AntiAddictionKit.updateUserType(1);

```	 
接口参数为 userType ,具体参考 [上表](#登录类型) 。

####（3）登出
当用户在游戏内点击登出或退出账号时调用该接口，调用示例如下：

```
AntiAddictionKit.logout();

```
###4.付费
游戏在收到用户的付费请求后，调用 SDK 的对应接口来判断当前用户的付费行为是否被限制，示例如下：

```
 AntiAddictionKit.checkPayLimit(100);

```
接口参数表示付费的金额，单位为分。当用户可以发起付费时，SDK 会调用回调 [PAY\_NO\_LIMIT](#callback) 通知游戏,否则调用 [PAY\_LIMIT](#callback);   
当用户完成付费行为时，游戏需要通知 SDK ，更新用户状态，示例如下：

```
 AntiAddictionKit.paySuccess(100);

```
参数为本次充值的金额，单位为分。

#####注意：如果用户在付费过程中需要打开第三方页面进行实名，实名完成后，游戏除了要调用 "updateUserType" [更新用户类型](#更新用户类型) , 还需再次调用 " checkPayLimit " 接口才能收到 [是否付费限制] (#callback) 的回调。

###5.聊天
游戏在需要聊天时，调用 SDK 接口判断当前用户是否实名，示例如下：

```
 AntiAddictionKit.checkChatLimit();
```
当用户可以聊天时， SDK 会通过聊天回调 [CHAT\_NO\_LIMIT](#callback) 来通知游戏，否则就会去实名。如果此时需要打开第三方实名页，SDK 会调用 [OPEN\_REAL\_NAME](#callback) 回调，否则打开 SDK 的实名页面，如果实名失败就会调用[CHAT\_LIMIT](#callback) 回调，否则调用 [CHAT\_NO\_LIMIT](#callback)。
#####注意：如果用户在判断聊天限制过程中需要打开第三方页面进行实名，实名完成后，游戏除了要调用 "updateUserType" [更新用户信息](#更新用户类型) , 还需再次调用 " checkChatLimit " 接口才能收到 [是否聊天限制] (#callback) 的回调。

###6.时长统计
为保证用户的时长统计准确，游戏需要在运行的主 Activity 的方法中调用如下接口，示例如下：

```
 	@Override
    protected void onResume() {
        super.onResume();
        AntiAddictionKit.onResume();
    }

    @Override
    protected void onStop() {
        super.onStop();
        AntiAddictionKit.onStop();
    }

```

###7.获取用户类型
SDK 初始化后，游戏可以获取 SDK 内保存的用户类型信息。如果游戏之前已设置过用户,会返回该用户的类型信息，否则会返回 -1 ，调用示例如下：

```
AntiAddictionKit.getUserType("userId"); 
```
参数是用户的唯一标识字符串，正常返回值参考[登录类型](#登录类型)。

###8.打开实名窗口
设置用户信息后，游戏可调用此接口打开实名窗口，示例如下：

```
AntiAddictionKit.openRealName();
```
调用后结果会通过[实名相关回调](#callback)返回。