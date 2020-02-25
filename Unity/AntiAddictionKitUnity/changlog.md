###2020-02-13  （1.0.2）

1.修复安卓主动调用实名界面时线程问题
2.修复iOS成年人账号调用登录漏发enter回调问题

###2020-02-11  （1.0.1）

1.修改setUser接口为login,updateUser,logout三个接口
2.添加用户信息改变和SDK窗口消失回调


###2020-01-21  （1.0.0）

1.添加配置类AntiAddictionConfig，可调用接口

public static void fuctionConfig(AntiAddictionConfig config)

配置SDK功能。

文件变更：

1.新增AntiAddictionConfig.cs

###2020-01-20  （1.0.0）

1.添加回调CALLBACK_CODE_ENTER_SUCCESS，表示可以进入游戏

2.添加回调CALLBACK_CODE_AAT_WINDOW_SHOWN，表示SDK窗口弹出

具体说明见文档


###2020-01-17  （1.0.0）

1.初始版本1.0.0
