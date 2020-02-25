
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using AntiAddiction.StandAlone;
using System;

/*
	version 1.0.0
 */

public class Demo : MonoBehaviour {
	public Action<int,string> onAntiAddictionResult;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	void OnApplicationPause(bool pauseStatus){
		if (pauseStatus)
		{
			AntiAddiction.StandAlone.AntiAddiction.onStop();

		}else
		{
			AntiAddiction.StandAlone.AntiAddiction.onResume();

		}
	}

	void OnGUI() {
		GUIStyle myButtonStyle = new GUIStyle(GUI.skin.button)
		{
			fontSize = 50
		};

		GUIStyle myLabelStyle = new GUIStyle(GUI.skin.label)
		{
			fontSize = 30
		};


		GUI.depth = 0;

		if (GUI.Button(new Rect(50, 200, 300, 80), "init", myButtonStyle))
		{
			onAntiAddictionResult += onAntiAddictionHandler;
			AntiAddiction.StandAlone.AntiAddiction.init(onAntiAddictionResult);
		}

		if (GUI.Button(new Rect(50, 330, 300, 80), "setUser", myButtonStyle))
		{
			AntiAddiction.StandAlone.AntiAddiction.setUser("123456",0);
		}

		if (GUI.Button(new Rect(50, 460, 380, 80), "checkPayLimit", myButtonStyle))
		{
			AntiAddiction.StandAlone.AntiAddiction.checkPayLimit(100);
		}

		if (GUI.Button(new Rect(50, 590, 300, 80), "paySuccess", myButtonStyle))
		{
			AntiAddiction.StandAlone.AntiAddiction.paySuccess(100);
		}

		if (GUI.Button(new Rect(50, 700, 380, 80), "checkChatLimit", myButtonStyle))
		{
			AntiAddiction.StandAlone.AntiAddiction.checkChatLimit();
		}

		if (GUI.Button(new Rect(50, 820, 300, 80), "config", myButtonStyle))
		{
			AntiAddictionConfig config = new AntiAddictionConfig.Builder ()
			.UseSdkRealName (true)
			.UseSdkPaymentLimit (true)
			.UseSdkOnlineTimeLimit(true)
			.ShowSwitchAccountButton (false)
			.Build ();

			AntiAddiction.StandAlone.AntiAddiction.fuctionConfig(config);
			// AntiAddiction.StandAlone.AntiAddiction.fuctionConfig(false,true,true);
		}

		if (GUI.Button(new Rect(50, 930, 300, 80), "getUserType", myButtonStyle))
		{
			int userType = AntiAddiction.StandAlone.AntiAddiction.getUserType("12345");
			Debug.Log("getUserType" + userType);
		}

		if (GUI.Button(new Rect(50, 1050, 380, 80), "openRealName", myButtonStyle))
		{
			AntiAddiction.StandAlone.AntiAddiction.openRealName();
		}

		if (GUI.Button(new Rect(50, 1150, 380, 80), "checkPayLimitSync", myButtonStyle))
		{
			int result = AntiAddiction.StandAlone.AntiAddiction.checkPayLimitSync(100);
			Debug.Log("checkPayLimitSync" + result);
		}
	}

	public void onAntiAddictionHandler (int resultCode,string msg){
		Debug.Log("onAntiAddictionHandler" + resultCode);
	}
}
