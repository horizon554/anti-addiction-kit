
//#import "AntiAddictionKit-Swift.h"
#import <AntiAddictionKit/AntiAddictionKit-Swift.h>
#import "AntiAddictioniOSWrapper.h"

@interface AntiAddictioniOSWrapper ()<AntiAddictionCallback>


@end

typedef void (*AntiAddictionDelegate)(int resultCode,const char* message);
AntiAddictionDelegate antiAddictionDelegate;


static AntiAddictioniOSWrapper *instance;
@implementation AntiAddictioniOSWrapper
+ (AntiAddictioniOSWrapper *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = nil;
        instance = [[AntiAddictioniOSWrapper alloc] init];
    });
    
    return instance;
}

#ifdef __cplusplus
extern "C" {
#endif
    
    void AntiAddictionInit(AntiAddictionDelegate delegate) {
        antiAddictionDelegate = delegate;
        [AntiAddictionKit init:[AntiAddictioniOSWrapper shareInstance]];
    }
    
    void AntiAddictionFunctionConfig(bool useSdkRealName,bool useSdkPaymentLimit,bool useSdkOnlineTimeLimit,bool showSwitchAccountButton) {
        Configuration *config = [AntiAddictionKit configuration];
        [config setUseSdkRealName:useSdkRealName];
        [config setUseSdkPaymentLimit:useSdkPaymentLimit];
        [config setUseSdkOnlineTimeLimit:useSdkOnlineTimeLimit];
        [config setShowSwitchAccountButton:showSwitchAccountButton];
        [AntiAddictionKit setConfiguration:config];

//        [AntiAddictionKit setFunctionConfig:useSdkRealName :useSdkPaymentLimit :useSdkOnlineTimeLimit];
    }
    
    void AntiAddictionLogin(const char *userId,int userType) {
        NSString *aaUserId = [NSString stringWithUTF8String:userId];
        [AntiAddictionKit login:aaUserId :userType];
    }
    
    void AntiAddictionLogout() {
        [AntiAddictionKit logout];
    }
    
    void AntiAddictionUpdateUserType(int userType) {
        [AntiAddictionKit updateUserType:userType];
    }
    
    int AntiAddictionGetUserType(const char *userId) {
        NSString *aaUserId = [NSString stringWithUTF8String:userId];
        return (int)[AntiAddictionKit getUserType:aaUserId];
    }
    
    void AntiAddictionCheckPayLimit(int amount){
        [AntiAddictionKit checkPayLimit:amount];
    }
    
    int AntiAddictionCheckCurrentPayLimit(int amount) {
        return [AntiAddictionKit checkCurrentPayLimit:amount];
    }
    
    void AntiAddictionPaySuccess(int amount) {
        [AntiAddictionKit paySuccess:amount];
    }
    
    void AntiAddictionCheckChatLimit() {
        [AntiAddictionKit checkChatLimit];
    }
    
    void AntiAddictionOpenRealName() {
        [AntiAddictionKit openRealName];
    }

#ifdef __cplusplus
}
#endif
                        
- (void)onAntiAddictionResult:(NSInteger)code :(NSString * _Nonnull)message {
    if (antiAddictionDelegate) {
        antiAddictionDelegate((int)code,message.UTF8String);
    }
}
                           
@end
                           
                           
