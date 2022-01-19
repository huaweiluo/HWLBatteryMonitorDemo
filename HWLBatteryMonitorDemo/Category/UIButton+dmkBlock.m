//
//  UIButton+dmkBlock.m
//  HWLBatteryMonitorDemo
//
//  Created by jipengfei on 2022/1/18.
//

#import "UIButton+dmkBlock.h"
#import <objc/runtime.h>

#define dmk_eventBlockMethodPrefix              @"dmk_callActionBlock_"

@interface UIButton(dmkBlock)
@property (nonatomic, copy) NSDictionary *eventsActionBlockDic;
@end

@implementation UIButton(dmkBlock)

- (void)handleControlEvent:(UIControlEvents)event withBlock:(DMKControlEventsActionBlock)action {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:self.eventsActionBlockDic?:@{}];
    [dic setValue:action forKey:[self keyByEvent:event]];
    self.eventsActionBlockDic = [dic copy];
    
    SEL actionMethod = [self methodForEvent:event];
    [self addTarget:self action:actionMethod forControlEvents:UIControlEventTouchUpInside];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    if ([NSStringFromSelector(selector) hasPrefix:dmk_eventBlockMethodPrefix]) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@:@"];
    }
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = [invocation selector];
    NSString *selString = NSStringFromSelector(sel);
    NSInteger selStringLength = [selString length];
    NSInteger prefixLength = [dmk_eventBlockMethodPrefix length];
    
    if ([selString hasPrefix:dmk_eventBlockMethodPrefix] && selStringLength>=(prefixLength+2)) {
        NSString *controlEventString = [selString substringWithRange:NSMakeRange(prefixLength, (selStringLength-prefixLength-1))];
        UIControlEvents event = [controlEventString integerValue];
        SEL executedSel = @selector(callActionBlock:withEvent:);
        
        invocation.selector = executedSel;
        invocation.target = self;
        [invocation setArgument:(void*)&self atIndex:2]; // index从2开始,0,1被target 和 selector占用
        [invocation setArgument:(void*)&event atIndex:3];
        
        if([self respondsToSelector:executedSel]) {
            [invocation invokeWithTarget:self];
        }
    }
}

#pragma mark -
#pragma mark internal method
- (SEL)methodForEvent:(UIControlEvents)event {
    return NSSelectorFromString([NSString stringWithFormat:@"%@%lu:", dmk_eventBlockMethodPrefix, (unsigned long)event]);
}

- (NSString*)keyByEvent:(UIControlEvents)event {
    return [NSString stringWithFormat:@"%@", @(event)];
}

- (void)callActionBlock:(id)sender withEvent:(UIControlEvents)event {
    DMKControlEventsActionBlock action = [self.eventsActionBlockDic objectForKey:[NSString stringWithFormat:@"%@", @(event)]];
    if (action) {
        action(sender);
    }
}

#pragma mark -
#pragma mark property method
static char eventDicKey;

- (NSDictionary*)eventsActionBlockDic {
    return objc_getAssociatedObject(self, &eventDicKey);
}

- (void)setEventsActionBlockDic:(NSDictionary *)eventsActionBlockDic {
    objc_setAssociatedObject(self, &eventDicKey, eventsActionBlockDic?:@{}, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
