# 防沉迷 AntiAddictionSDK 对接文档
AntiAddictionSDK 是为了应对最新防沉迷政策而编写的一个集实名登记、防沉迷时长限制、付费限制三部分功能的组件，方便国内游戏团队快速接入游戏实现防沉迷功能从而符合政策规定。

## 1.接入SDK
导入AntiAddictionForUnity1.0.0.unitypackage

### 1.1 iOS
最低支持系统版本iOS8.0

**手动引入动态库文件**

1. 修改 Xcode 工程的 `BuildSettings` 的 `Always Embed Swift Standard Libraries` 为 `Yes`，即`始终引入 Swift 标准库`，避免 App 启动时报错（无法找到 Swift标准库之类）。
2. 添加依赖库libc++.tbd

### 1.2 Android
最低支持安卓版本5.0。


## 2.接口文档
安卓和iOS分别有默认的防沉迷时长和外观默认值，如需修改，请查看对应平台文档或代码。

**以下使用需要SDK命名空间下**

```
namespace AntiAddiction.StandAlone
```

### 2.1 功能配置（采用默认值可跳过）
#### （1）功能配置参数列表如下：

 功能配置参数 |类型|默认值|说明 
--- |--- |--- | ---
useSdkRealName | bool | true | 是否使用 SDK 实名登记功能
useSdkPaymentLimit | bool | true | 是否使用 SDK 付费限制
useSdkOnlineTimeLimit | bool | true | 是否使用 SDK 在线时长限制

调用方式示例：

```
/*
	配置SDK
	useSdkRealName：是否使用SDK内部实名				默认true
	useSdkPaymentLimit：是否开启支付限制	 			默认true
	useSdkOnlineTimeLimit：是否开启在线时长限制	   默认true 
 */
public static void fuctionConfig(bool useSdkRealName,bool useSdkPaymentLimit,bool useSdkOnlineTimeLimit)
```

**也可以使用配置类AntiAddictionConfig配置SDK,类中配置更齐全**


调用方式示例：

```
AntiAddictionConfig config = new AntiAddictionConfig.Builder ()
.UseSdkRealName (true)
.UseSdkPaymentLimit (true)
.UseSdkOnlineTimeLimit(true)
.ShowSwitchAccountButton (false)		// 是否显示切换账号按钮
.Build ();

AntiAddiction.StandAlone.AntiAddiction.fuctionConfig(config);
```


### 2.初始化

初始化SDK并设置回调，初始化方法接收Action作为回调

示例如下：

```
// 定义回调Action
public Action<int,string> onAntiAddictionResult;

public void onAntiAddictionHandler (int resultCode,string msg){
	Debug.Log("onAntiAddictionHandler" + resultCode);
}
// 设置回调
onAntiAddictionResult += onAntiAddictionHandler;
AntiAddiction.StandAlone.AntiAddiction.init(onAntiAddictionResult);
```

回调中会返回对应的回调类型码 resultCode 和相应信息 message：

回调类型 | 参数值 |  触发条件 | 附带信息
--- | --- | --- | ---
CALLBACK\_CODE\_ENTER\_SUCCESS | 500 | 登录通过，当用户登录过程中通过防沉迷限制时会触发 | 无
CALLBACK\_CODE\_SWITCH_ACCOUNT | 1000 | 切换账号，当用户因防沉迷机制受限时，选择切换账号时会触发 | 无
CALLBACK\_CODE\_REAL\_NAME\_SUCCESS | 1010 | 实名成功，通过SDK或第三方完成实名会触发 | 无
CALLBACK\_CODE\_REAL\_NAME\_FAIL | 1015 | 实名失败，实名取消或失败会触发 | 无
CALLBACK\_CODE\_PAY\_NO\_LIMIT | 1020 | 付费不受限，sdk检查用户付费无限制时触发| 无
CALLBACK\_CODE\_PAY\_LIMIT | 1025 | 付费受限，付费受限触发,包括游客未实名或付费额达到限制等 | 触发原因
CALLBACK\_CODE\_TIME\_LIMIT | 1030 | 时间受限，未成年人或游客游戏时长已达限制，通知游戏 | 无
CALLBACK\_CODE\_OPEN\_REAL\_NAME | 1060 | 打开实名窗口，需要游戏通过其他方式完成用户实名时触发 | 触发原因提示，包括 "PAY\_LIMIT","CHAT_LIMIT"等
CALLBACK\_CODE\_CHAT\_NO\_LIMIT | 1080 | 聊天无限制，用户已通过实名，可进行聊天 | 无
CALLBACK\_CODE\_CHAT\_LIMIT | 1090 | 聊天限制，用户未通过实名，不可进行聊天 | 无
CALLBACK\_CODE\_USER\_TYPE\_CHANGED | 1500 | 用户类型变更，通过SDK完成实名会触发 | 无
CALLBACK\_CODE\_AAT\_WINDOW\_SHOWN | 2000 | 额外弹窗显示，当用户操作触发额外窗口显示时通知游戏 | 无
CALLBACK\_CODE\_AAK\_WINDOW\_DISMISS | 2500 | 额外弹窗显示，额外窗口消失时通知游戏 

####注意：关于 "USER\_TYPE\_CHANGED" 的回调，触发时机可能不唯一，当用户在付费或其他需要实名的时候，完成实名过程都会触发相应回调，所以不建议在这两个回调中做UI相关或任何阻塞线程的事情。


### 3.设置用户信息

相关接口参数说明:

用户相关参数 | 类型 | 说明
--- | --- | ---
userId | `String` | 用户的唯一标识
userType | `Int` | 用户实名类型



<a name="用户类型"></a>

用户类型 | 参数值 | 说明
--- | --- | ---
USER\_TYPE\_UNKNOWN | 0 | 依赖SDK获取实名信息或第三方获取的信息为未实名
USER\_TYPE\_CHILD | 1 | 通过第三方获取，值为未成年人（8岁以下）
USER\_TYPE\_TEEN | 2 | 通过第三方获取，值为未成年人（8-16岁）
USER\_TYPE\_YOUNG | 3 | 通过第三方获取，值为未成年人（16-17岁）
USER\_TYPE\_ADULT | 4 | 通过第三方获取，值为成年人（18岁及以上）

#### 3.1登录

登录接口应只在游戏登录过程中、登出后以及收到回调 ”SWITCH_ACCOUNT" 时调用。

调用示例：

```
AntiAddiction.StandAlone.AntiAddiction.login("12345",4);
```
该接口中共有两个参数，第一个是用户的唯一标识，类型为字符串，第二个代表当前用户的类型.参考上表

#### 3.2更新用户信息
当游戏通过第三方实名后，需要将实名信息更新到 SDK 中，接口参数为 userType ,具体参考 上表 。

具体示例如下：

```
AntiAddiction.StandAlone.AntiAddiction.udpateUserType(4);
```

#### 3.3登出
当用户在游戏内点击登出或退出账号时调用该接口。

调用示例如下：

```
AntiAddiction.StandAlone.AntiAddiction.logout();
```


### 4.付费
游戏在收到用户的付费请求后，调用 SDK 的对应接口来判断当前用户的付费行为是否被限制，示例如下：

```
AntiAddiction.StandAlone.AntiAddiction.checkPayLimit(100);
```

接口参数表示付费的金额，单位为分（例如1元道具=100分）。当用户可以发起付费时，SDK 会调用回调 [PAY\_NO\_LIMIT](#回调类型) 通知游戏,否则调用 [PAY\_LIMIT](#回调类型);   
当用户完成付费行为时，游戏需要通知 SDK ，更新用户状态，示例如下：

```
AntiAddiction.StandAlone.AntiAddiction.paySuccess(100);
```
参数为本次充值的金额，单位为分。

##### 注意：如果用户在付费过程中需要打开第三方页面进行实名，实名完成后，游戏除了要调用 "setUser" [更新用户信息](#设置用户信息) , 还需再次调用 " checkPayLimit " 接口才能收到 [是否付费限制] (#回调类型) 的回调。

### 5.聊天
游戏在需要聊天时，调用 SDK 接口判断当前用户是否实名，示例如下：

```
 AntiAddiction.StandAlone.AntiAddiction.checkChatLimit();
```
当用户可以聊天时， SDK 会通过聊天回调 [CHAT\_NO\_LIMIT](#回调类型) 来通知游戏，否则就会去实名。如果此时需要打开第三方实名页，SDK 会调用 [OPEN\_REAL\_NAME](#回调类型) 回调，否则打开 SDK 的实名页面，如果实名失败就会调用[CHAT\_LIMIT](#回调类型) 回调，否则调用 [CHAT\_NO\_LIMIT](#回调类型)。

##### 注意：如果用户在判断聊天限制过程中需要打开第三方页面进行实名，实名完成后，游戏除了要调用 "setUser" [更新用户信息](#update_user) , 还需再次调用 " checkChatLimit " 接口才能收到 [是否聊天限制](#回调类型) 的回调。

### 6.时长统计
如果步骤一配置的 useSdkOnlineTimeLimit = true，则 sdk 会根据当前政策主动限制游戏时长，反之不会限制用户游戏时长。

安卓平台需要注意，在unity的OnApplicationPause调用onResume和onStop方法

示例如下：

```
void OnApplicationPause(bool pauseStatus){
	if (pauseStatus)
	{
		AntiAddiction.StandAlone.AntiAddiction.onStop();

	}else
	{
		AntiAddiction.StandAlone.AntiAddiction.onResume();

	}
}
```


### 7.获取用户类型
SDK 初始化后，游戏可以获取 SDK 内保存的用户类型信息。如果游戏之前已设置过用户，会返回该用户的正常类型信息（0，1，2，3，4），否则返回 -1。调用示例如下：

```
int userType = AntiAddiction.StandAlone.AntiAddiction.getUserType("12345");

```
参数是用户的唯一标识字符串，返回值参考[用户类型](#用户类型)。

###8.打开实名窗口
设置用户信息后，游戏可调用此接口打开实名窗口，示例如下：

```
AntiAddiction.StandAlone.AntiAddiction.openRealName();
```
调用后结果会通过[实名相关回调](#callback)返回。
