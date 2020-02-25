using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Runtime.InteropServices;
using AOT;

/*
	version 1.0.0
 */
namespace AntiAddiction.StandAlone
{

	public enum AntiAddictionUserType : int{
		USER_TYPE_UNKNOWN = 0,			// 依赖SDK获取实名信息或第三方获取的信息为未实名
		USER_TYPE_CHILD = 1,			// 通过第三方获取，值为未成年人（8岁以下
		USER_TYPE_TEEN = 2,				// 通过第三方获取，值为未成年人（8-16岁）
		USER_TYPE_YOUNG = 3,			// 通过第三方获取，值为未成年人（16-17岁）
		USER_TYPE_ADULT = 4,			// 通过第三方获取，值为成年人
	};

	public enum CallbackCode : int{
			CALLBACK_CODE_ENTER_SUCCESS = 500,				// 登录通过，当用户登录过程中通过防沉迷限制时会触发
			CALLBACK_CODE_SWITCH_ACCOUNT = 1000,			// 切换账号，当用户因防沉迷机制受限时，选择切换账号时会触发
			CALLBACK_CODE_REAL_NAME_SUCCESS = 1010,			// 实名成功，通过SDK或第三方完成实名会触发
			CALLBACK_CODE_REAL_NAME_FAIL = 1015,			// 实名失败，实名取消或失败会触发
			CALLBACK_CODE_PAY_NO_LIMIT = 1020,				// 付费不受限，sdk检查用户付费无限制时触发
			CALLBACK_CODE_PAY_LIMIT = 1025,					// 付费受限，付费受限触发,包括游客未实名或付费额达到限制等
			CALLBACK_CODE_TIME_LIMIT = 1030,				// 时间受限，未成年人或游客游戏时长已达限制，通知游戏
			CALLBACK_CODE_OPEN_REAL_NAME = 1060,			// 打开实名窗口，需要游戏通过其他方式完成用户实名时触发
			CALLBACK_CODE_CHAT_NO_LIMIT = 1080,				// 聊天无限制，用户已通过实名，可进行聊天
			CALLBACK_CODE_CHAT_LIMIT = 1090,				// 聊天限制，用户未通过实名，不可进行聊天
			CALLBACK_CODE_AAT_WINDOW_SHOWN = 2000,			// 额外弹窗显示，当用户操作触发额外窗口显示时通知游戏
		};

	public class AntiAddiction:MonoBehaviour {

		private static AndroidJavaClass AntiAddictionClass;
		private delegate void AntiAddictionDelegate(int resultCode,string message);
		private static Action<int,string> antiAddictionResult;
		[AOT.MonoPInvokeCallbackAttribute(typeof(AntiAddictionDelegate))]
		static void antiAddictionCallback (int resultCode,string message) {
			antiAddictionResult(resultCode,message);
		}

		/*
			初始化
			onAntiAddictionResult:接收回调
		 */
		public static void init(Action<int,string> onAntiAddictionResult) {
			#if UNITY_IOS && !UNITY_EDITOR
				antiAddictionResult = onAntiAddictionResult;
				AntiAddictionInit(antiAddictionCallback);
			#elif UNITY_ANDROID && !UNITY_EDITOR
				AndroidJavaClass playerClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
				AndroidJavaObject activityObject = playerClass.GetStatic<AndroidJavaObject>("currentActivity");
				AntiAddictionClass = new AndroidJavaClass ("com.antiaddiction.sdk.AntiAddictionKit");
				AntiAddictionClass.CallStatic ("init", activityObject, new AntiAddictionHandler(onAntiAddictionResult));
			#else
			#endif
		}

		/*
			配置SDK
			useSdkRealName：是否使用SDK内部实名				默认true
			useSdkPaymentLimit：是否开启支付限制	 			默认true
			useSdkOnlineTimeLimit：是否开启在线时长限制	   默认true 
		 */
		public static void fuctionConfig(bool useSdkRealName,bool useSdkPaymentLimit,bool useSdkOnlineTimeLimit) {
			#if UNITY_IOS && !UNITY_EDITOR
				AntiAddictionFunctionConfig(useSdkRealName,useSdkPaymentLimit,useSdkOnlineTimeLimit,true);
			#elif UNITY_ANDROID && !UNITY_EDITOR
				AntiAddictionClass.CallStatic ("resetFunctionConfig", useSdkRealName, useSdkPaymentLimit,useSdkOnlineTimeLimit);
			#else
			#endif
		}

		/*
			配置SDK
			AntiAddictionConfig 配置
		 */
		public static void fuctionConfig(AntiAddictionConfig config) {
			#if UNITY_IOS && !UNITY_EDITOR
				AntiAddictionFunctionConfig(config.useSdkRealName,config.useSdkPaymentLimit,config.useSdkOnlineTimeLimit,config.showSwitchAccountButton);
			#elif UNITY_ANDROID && !UNITY_EDITOR
				if (AndroidJavaClass == null)
				{
					AntiAddictionClass = new AndroidJavaClass ("com.antiaddiction.sdk.AntiAddictionKit");
				}
				AntiAddictionClass.CallStatic<AndroidJavaObject> ("getFunctionConfig")
								.Call<AndroidJavaObject>("useSdkRealName",config.useSdkRealName)
								.Call<AndroidJavaObject>("useSdkPaymentLimit",config.useSdkPaymentLimit)
								.Call<AndroidJavaObject>("useSdkOnlineTimeLimit",config.useSdkOnlineTimeLimit)
								.Call<AndroidJavaObject>("showSwitchAccountButton",config.showSwitchAccountButton);
			#else
			#endif
		}
		
		/*
			配置用户信息，登录登出或用户信息改变时调用
			userId：用户ID
			userType：用户类型，见枚举
		 */
		public static void setUser(string userId,int userType) {
			#if UNITY_IOS && !UNITY_EDITOR
				AntiAddictionSetUser(userId,userType);
			#elif UNITY_ANDROID && !UNITY_EDITOR
				AntiAddictionClass.CallStatic ("setUser", userId, userType);
			#else
			#endif
		}

		/*
			获取用户信息，返回值参考用户类型，异常情况返回-1
			userId：用户ID
		 */
		public static int getUserType(string userId) {
			#if UNITY_IOS && !UNITY_EDITOR
				return AntiAddictionGetUserType(userId);
			#elif UNITY_ANDROID && !UNITY_EDITOR
				return AntiAddictionClass.CallStatic<int> ("getUserType", userId);
			#else
				return 0;
			#endif
		}

		/*
			检查是否能支付,结果以回调返回
			price：商品价格，单位分
		 */
		public static void checkPayLimit(int price) {
			#if UNITY_IOS && !UNITY_EDITOR
				AntiAddictionCheckPayLimit(price);
			#elif UNITY_ANDROID && !UNITY_EDITOR
				AntiAddictionClass.CallStatic ("checkPayLimit", price);
			#else
			#endif
		}

		/*
			支付成功以后通知SDK结果
			price：商品价格，单位分
		 */
		public static void paySuccess(int price) {
			#if UNITY_IOS && !UNITY_EDITOR
				AntiAddictionPaySuccess(price);
			#elif UNITY_ANDROID && !UNITY_EDITOR
				AntiAddictionClass.CallStatic ("paySuccess", price);
			#else
			#endif
		}

		/*
			检查是否能聊天,结果以回调返回
		 */
		public static void checkChatLimit() {
			#if UNITY_IOS && !UNITY_EDITOR
				AntiAddictionCheckChatLimit();
			#elif UNITY_ANDROID && !UNITY_EDITOR
				AntiAddictionClass.CallStatic ("checkChatLimit");
			#else
			#endif
		}

		/*
			打开实名窗口
		 */	
		public static void openRealName () {
			#if UNITY_IOS && !UNITY_EDITOR
				AntiAddictionOpenRealName();
			#elif UNITY_ANDROID && !UNITY_EDITOR
				AntiAddictionClass.CallStatic ("openRealName");
			#else
			#endif
		}

		/*
			检查是否能支付,结果同步返回，可能会阻塞线程
			price：商品价格，单位分
		 */
		public static int checkPayLimitSync(int price) {
			#if UNITY_IOS && !UNITY_EDITOR
				return 1020;
			#elif UNITY_ANDROID && !UNITY_EDITOR
				return AntiAddictionClass.CallStatic<int> ("checkCurrentPayLimit", price);
			#else
				return 1020;
			#endif
		}

		public static void onResume() {
			#if UNITY_IOS && !UNITY_EDITOR
			#elif UNITY_ANDROID && !UNITY_EDITOR
				if (AndroidJavaClass)
				{
					AntiAddictionClass.CallStatic ("onResume");
				}
			#else
			#endif
		}

		public static void onStop() {
			#if UNITY_IOS && !UNITY_EDITOR
			#elif UNITY_ANDROID && !UNITY_EDITOR
				if (AndroidJavaClass == null)
				{
					AntiAddictionClass.CallStatic ("onStop");
				}
			#else
			#endif
		}

		#if UNITY_IOS && !UNITY_EDITOR
        [DllImport("__Internal")]
        private static extern void AntiAddictionInit(AntiAddictionDelegate antiDelegate);

        [DllImport("__Internal")]
        private static extern void AntiAddictionFunctionConfig(bool useSdkRealName,bool useSdkPaymentLimit,bool useSdkOnlineTimeLimit,bool showSwitchAccountButton);

        [DllImport("__Internal")]
        private static extern void AntiAddictionSetUser(string userId,int userType);

		[DllImport("__Internal")]
        private static extern int AntiAddictionGetUserType(string userId);

		[DllImport("__Internal")]
        private static extern void AntiAddictionCheckPayLimit(int amount);

		[DllImport("__Internal")]
        private static extern void AntiAddictionPaySuccess(int amount);

		[DllImport("__Internal")]
        private static extern void AntiAddictionCheckChatLimit();

		[DllImport("__Internal")]
        private static extern void AntiAddictionOpenRealName();

		#endif
	}

	class AntiAddictionHandler:AndroidJavaProxy {
		Action<int,string> onAntiAddictionResult;
		public AntiAddictionHandler(Action<int,string> onAntiAddictionResult): base("com.antiaddiction.sdk.AntiAddictionKit$AntiAddictionCallback") {    
		this.onAntiAddictionResult = onAntiAddictionResult;
		}

		public override AndroidJavaObject Invoke(string methodName, object[] args) {
			if (methodName.Equals("onAntiAddictionResult"))
			{
				onAntiAddictionResult((int)args[0],(string)args[1]);
			}
			
			return null;
		}

	}

}



