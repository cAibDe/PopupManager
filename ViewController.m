#import "ViewController.h"
#import "NextViewController.h"
#import "PopupManager.h"
#import "PopupView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPopuoView) name:@"ShowPopuoView" object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    PopupView *popupViewFirst1 = [[PopupView alloc] initWithPopupPriority:5 message:@"等待的弹窗 优先级为5"];
    [PopupManager.sharedManager addPopupView:popupViewFirst1];
}
- (IBAction)buttonAction:(id)sender {
//    [self asyncTest];
    NextViewController *vc = [[NextViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)showPopuoView{
    PopupView *popupViewFirst2 = [[PopupView alloc] initWithPopupPriority:10 message:@"等待的弹窗 优先级为10"];
    [PopupManager.sharedManager addPopupView:popupViewFirst2];
}

- (void)asyncTest{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            PopupView *popupViewFirst1 = [[PopupView alloc] initWithPopupPriority:5 message:@"等待的弹窗 优先级为5"];
            [PopupManager.sharedManager addPopupView:popupViewFirst1];
        });
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            PopupView *popupViewFirst = [[PopupView alloc] initWithPopupPriority:1 message:@"第一个显示的弹窗"];
            [PopupManager.sharedManager addPopupView:popupViewFirst];
        });
    });
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            PopupView *popupViewFirst2 = [[PopupView alloc] initWithPopupPriority:10 message:@"等待的弹窗 优先级为10"];
            [PopupManager.sharedManager addPopupView:popupViewFirst2];
        });
    });
}

@end
