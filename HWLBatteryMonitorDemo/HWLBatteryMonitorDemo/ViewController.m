//
//  ViewController.m
//  HWLBatteryMonitorDemo
//
//  Created by jipengfei on 2021/6/3.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)dealloc {
    [self removeBatteryNotification];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    //** 后台执行setBatteryMonitoringEnabled,在iPhone8, ios11 上会导致battery电量值和充电状态监听失效 */
     dispatch_async(dispatch_get_global_queue(0, 0), ^{
         [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
     });
    
    [self registerBatteryNotification];
}

#pragma mark -
#pragma mark notification
- (void)registerBatteryNotification {
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelDidChange:) name:UIDeviceBatteryLevelDidChangeNotification object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryStateDidChangeNotification object:[UIDevice currentDevice] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        [self batteryStateDidChange:notification];
    }];
}

- (void)removeBatteryNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

- (void)batteryStateDidChange:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        // If monitoring is already enabled we dont enable it again
        if ( ![[UIDevice currentDevice] isBatteryMonitoringEnabled]) {
            [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        }

        if ( ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging)
            || ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateFull) ) {
            self.view.backgroundColor = [UIColor greenColor]; // 充电绿色
        }
        else {
            self.view.backgroundColor = [UIColor redColor]; // 非充电状态红色
        }
    });
}

- (void)batteryLevelDidChange:(NSNotification*)notification {
}

@end
