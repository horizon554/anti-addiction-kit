
#import "GuideViewController.h"

@interface GuideViewController ()
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;


@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView.text = @"使用步骤：\n\nApp启动\n\n1.配置sdk功能（可选）\n\n⇩\n\n2.配置用户时长（可选）\n\n⇩\n\n3.初始化sdk（必选！！！）\n\n⇩\n\n4.设置用户setUser\n（id不能为空，空=退出登录）\n\n\n\n\n\n生成证件号功能，仅 DEBUG 打包测试可用";
    
    [self.closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
