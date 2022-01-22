//
//  UIButton+dmkBlock.h
//  HWLBatteryMonitorDemo
//
//  Created by jipengfei on 2022/1/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DMKControlEventsActionBlock)(id sender);

@interface UIButton(dmkBlock)
- (void)handleControlEvent:(UIControlEvents)event withBlock:(DMKControlEventsActionBlock)action;
- (void)removeHandleBlockByControlEvent:(UIControlEvents)event;
@end

NS_ASSUME_NONNULL_END
