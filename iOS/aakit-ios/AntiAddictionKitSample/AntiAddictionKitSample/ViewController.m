

#import "ViewController.h"
#import "ButtonViewCell.h"
@import AntiAddictionKit;

static NSString *const cellReuseIdentifier = @"buttonCollectionViewCell";

static NSString *const onlineTimeNotificationName = @"NSNotification.Name.totalOnlineTime";

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AntiAddictionCallback>
@property (strong, nonatomic) UICollectionView *actionsView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *guideButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *callbackLabel;

@property (assign, nonatomic) BOOL isSdkInitialized;

@end

@implementation ViewController

// MARK: - Life Cycle, UI Settings
- (BOOL)isLandscape {
    return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self addNotificationListener];
    
    self.isSdkInitialized = NO;
    
    //显示切换账号按钮
    AntiAddictionKit.configuration.showSwitchAccountButton = YES;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:onlineTimeNotificationName object:nil];
}

- (void)setupUI {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    _actionsView = [[UICollectionView alloc] initWithFrame:[self actionsViewRect] collectionViewLayout:flowLayout];
    [self.view addSubview:_actionsView];
    _actionsView.backgroundColor = UIColor.clearColor;
    _actionsView.delegate = self;
    _actionsView.dataSource = self;
    _actionsView.alwaysBounceVertical = YES;
    _actionsView.alwaysBounceHorizontal = YES;
    _actionsView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
    [_actionsView registerClass:[ButtonViewCell self] forCellWithReuseIdentifier:cellReuseIdentifier];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
    // NSString *appBuildVersion = [infoDic objectForKey:@"CFBundleVersion"];
    _nameLabel.text = [NSString stringWithFormat:@"防沉迷单机版演示应用 %@", appVersion];
}

- (CGRect)actionsViewRect {
    if ([self isLandscape]) {
        return CGRectMake(40, 40, self.view.frame.size.width-80, self.view.frame.size.height - 80);
    } else {
        return CGRectMake(0, 80, self.view.frame.size.width, self.view.frame.size.height - 160);
    }
}

- (CGSize)buttonSize {
    return CGSizeMake(150, 60);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    _actionsView.frame = [self actionsViewRect];
    
    [super traitCollectionDidChange:previousTraitCollection];
}

// MARK: - Notification
- (void)addNotificationListener {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showUserOnlineTimeWithNote:) name:onlineTimeNotificationName object:nil];
}

- (void)showUserOnlineTimeWithNote:(NSNotification *)note {
     NSNumber *time = [note.userInfo objectForKey:@"totalOnlineTime"];
    NSString *userId = [note.userInfo objectForKey:@"userId"];
    if (time) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.timeLabel.text = [NSString stringWithFormat:@"用户[%@]游戏时长 %ld 秒", userId, (long)[time integerValue]];
        });
    }
}



// MARK: - UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self buttonArray].count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self buttonSize];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ButtonViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    if (![cell isKindOfClass:[ButtonViewCell class]]) {
        return [UICollectionViewCell new];
    }
    cell.textLabel.text = [[self buttonArray] objectAtIndex:indexPath.item][0];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectorName = (NSString *)([self buttonArray][indexPath.item][1]);
    SEL selector = NSSelectorFromString(selectorName);
    // 避免直接使用`[self performSelector:selector];`而出现的 warning
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
}

// MARK: - AAKit Delegate
- (void)onAntiAddictionResult:(NSInteger)code :(NSString *)message {
    if (@available(iOS 10.0, *)) {
        [[UINotificationFeedbackGenerator new] notificationOccurred:UINotificationFeedbackTypeSuccess];
    }
    self.callbackLabel.text = [NSString stringWithFormat:@"[AAKit Callback]\n%@", message];
}

// MARK: - Actions
- (NSArray *)buttonArray {
    return @[
        @[@"功能配置（可选）：实名/付费/时长）", @"configSdkFunctions"],
        @[@"时长配置（可选）", @"configSdkTimeLimit"],
        @[@"初始化✅", @"initSdk"],
        @[@"登录用户\n（id，type）", @"login"],
        @[@"退出登录", @"logout"],
        @[@"更新用户类型\n（type）", @"updateUserType"],
        @[@"获取用户类型\n（id）", @"getUserType"],
        @[@"申请支付（单位分）购买前调用", @"checkPayLimit"],
        @[@"已支付（单位分）购买成功后调用", @"paySuccess"],
        @[@"检查能否聊天", @"gameCheckChatLimit"],
        @[@"打开实名登记\n(登录后可用)", @"openRealName"],
//        @[@"生成证件号，6小时有效（已复制）", @"generateIDCode"],
        @[@"杀掉应用", @"killApp"]
    ];
}

- (void)killApp {
    exit(0);
}

- (void)configSdkFunctions {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SDK配置选项" message:@"配置防沉迷SDK\n0不开启，不填或非0默认开启" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"实名开关 0=关闭";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"付费限制开关 0=关闭";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"游戏时长控制开关 0=关闭";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        BOOL isRealnameOpen  = ![[alert.textFields objectAtIndex:0].text isEqualToString:@"0"];
         BOOL isPaymentLimitOpen  = ![[alert.textFields objectAtIndex:1].text isEqualToString:@"0"];
         BOOL isTimeLimitOpen  = ![[alert.textFields objectAtIndex:2].text isEqualToString:@"0"];
        
        [AntiAddictionKit setFunctionConfig:isRealnameOpen :isPaymentLimitOpen :isTimeLimitOpen];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)configSdkTimeLimit {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"防沉迷总时长配置" message:@"使用方法跟sdk配置按钮类似\n\n不填即使用默认值，\n请填写【正整数】（单位秒）\n例如游客20s 15s 10s，\n\n请确保：总时长>首次浮窗>倒计时时间，\n\n要么都填，要么都不填，否则可能出错！\n填错出现问题请杀掉App重试！" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"游客每日时长，默认3600s";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"未成年节假日时长，默认10800s";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"未成年非假日时长，默认5400s";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"首次浮窗提醒时间，默认剩900s";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"倒计时浮窗提醒时间，默认剩60s";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([[alert.textFields objectAtIndex:0].text intValue] > 0) {
            AntiAddictionKit.configuration.guestTotalTime = [[alert.textFields objectAtIndex:0].text intValue];
        }
        if ([[alert.textFields objectAtIndex:1].text intValue] > 0) {
            AntiAddictionKit.configuration.minorHolidayTotalTime = [[alert.textFields objectAtIndex:1].text intValue];
        }
        if ([[alert.textFields objectAtIndex:2].text intValue] > 0) {
          AntiAddictionKit.configuration.minorCommonDayTotalTime = [[alert.textFields objectAtIndex:2].text intValue];
        }
        if ([[alert.textFields objectAtIndex:3].text intValue] > 0) {
            AntiAddictionKit.configuration.firstAlertTipRemainTime = [[alert.textFields objectAtIndex:3].text intValue];
        }
        if ([[alert.textFields objectAtIndex:4].text intValue] > 0) {
            AntiAddictionKit.configuration.countdownAlertTipRemainTime = [[alert.textFields objectAtIndex:4].text intValue];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)initSdk {
    [AntiAddictionKit init:self];
    
    self.isSdkInitialized = YES;
    
    self.callbackLabel.text = @"游戏初始化成功";
}

- (BOOL)checkInitStatus {
    if (!self.isSdkInitialized) {
        if (@available(iOS 10.0, *)) {
            [[UINotificationFeedbackGenerator new] notificationOccurred:UINotificationFeedbackTypeWarning];
        }
        self.callbackLabel.text = @"请先初始化SDK！！！";
        return NO;
    }
    return YES;
}

- (void)login {
    if (![self checkInitStatus]) { return; }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录用户" message:@"\n账号ID = 任意字符串\n账号类型 = 数字\n\n0 = 未知（未实名）\n1 = 7岁及以下\n2 = 8-15岁\n3 = 16-17岁\n4 = 18岁及以上\n其他值 = 默认未知0" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.placeholder = @"账号ID";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"账号类型";
    }];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *userId  = alert.textFields.firstObject.text;
        NSInteger userType = [alert.textFields[1].text integerValue];
        if (!userId || userId.length == 0) {
            userId = @"";
        }
        [AntiAddictionKit login:userId :userType];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callbackLabel.text = [NSString stringWithFormat:@"用户[%@]已登录", userId];
        });
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:purchaseAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)updateUserType {
    if (![self checkInitStatus]) { return; }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"更新用户类型" message:@"账号类型 = 数字\n\n0 = 未知（未实名）\n1 = 7岁及以下\n2 = 8-15岁\n3 = 16-17岁\n4 = 18岁及以上\n其他值 = 默认未知0" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"账号类型";
    }];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSInteger userType = [alert.textFields.firstObject.text integerValue];
        [AntiAddictionKit updateUserType:userType];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callbackLabel.text = [NSString stringWithFormat:@"用户类型已更新为%ld", userType];
        });
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:purchaseAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)logout {
    if (![self checkInitStatus]) { return; }
    [AntiAddictionKit logout];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callbackLabel.text = @"用户已退出登录";
    });
}

- (void)checkPayLimit {
    if (![self checkInitStatus]) { return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请求购买道具（单位分=0.01元）" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"请输入支付金额（单位分）";
    }];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:@"支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSInteger money = [alert.textFields.firstObject.text integerValue];
        [AntiAddictionKit checkPayLimit:money];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:purchaseAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)paySuccess {
    if (![self checkInitStatus]) { return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已经购买道具（单位分=0.01元）" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"请输入支付金额（单位分）";
    }];
    UIAlertAction *purchaseAction = [UIAlertAction actionWithTitle:@"支付" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSInteger money = [alert.textFields.firstObject.text integerValue];
        [AntiAddictionKit paySuccess:money];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:purchaseAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)gameCheckChatLimit {
    if (![self checkInitStatus]) { return; }
    [AntiAddictionKit checkChatLimit];
}

- (void)getUserType {
    if (![self checkInitStatus]) { return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"获取用户类型" message:@"-1：未知\n0：未实名\n1：0-7\n2：8-15\n3：16-17\n4：18+" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeURL;
        textField.placeholder = @"请输入用户id";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *userId = alert.textFields.firstObject.text;
        NSInteger userType = [AntiAddictionKit getUserType:userId];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.callbackLabel.text = [NSString stringWithFormat:@"用户[%@]类型=%ld", userId, (long)userType];
        });
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)openRealName {
    if (![self checkInitStatus]) { return; }
    [AntiAddictionKit openRealName];
}

- (void)generateIDCode {
#if DEBUG
    NSString *code = [AntiAddictionKit generateIDCode];
    if (code && code.length > 0) {
        self.callbackLabel.text = code;
        UIPasteboard.generalPasteboard.string = code;
    }
#endif
}

@end
