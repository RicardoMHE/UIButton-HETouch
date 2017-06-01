//
//  UIButton+HETouch.m
//  AXCF
//
//  Created by Ricardo_M_HE on 2017/3/8.
//  Copyright © 2017年 Ricardo_M_HE. All rights reserved.
//

#import "UIButton+HETouch.h"
#import <objc/runtime.h>

#define DEFAULT_INTERVAL .5  //默认时间间隔

@interface UIButton ()
/**
 是否忽视重复点击, YES - 忽视重复点击 NO - 不忽视重复点击
 */
@property (nonatomic, assign) BOOL isIgnoreEvent;

@end

@implementation UIButton (HETouch)

#pragma mark -
#pragma mark - load, 交换响应的点击方法
+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 1. 获取系统的方法
        SEL selSystem = @selector(sendAction:to:forEvent:);
        Method methodSystem = class_getInstanceMethod(self, selSystem);
        // 2. 获取自定义的方法
        SEL selCustom = @selector(heSendAction:to:forEvent:);
        Method methodCustom = class_getInstanceMethod(self, selCustom);
        // 3. 添加一个覆盖父类的实现,但不会取代现有的实现类, 返回是否成功
        BOOL isAdd = class_addMethod(self, selSystem, method_getImplementation(methodCustom), method_getTypeEncoding(methodCustom));
        // 4. 判断是要完全替换原有的方法, 还是只是交换两个方法的实现
        if (isAdd) {
            // 替换原来的方法
            class_replaceMethod(self, selCustom, method_getImplementation(methodSystem), method_getTypeEncoding(methodSystem));
        } else {
            // 交换两个方法的实现
            method_exchangeImplementations(methodSystem, methodCustom);
        }
        
    });

}

#pragma mark -
#pragma mark - 自定义方法, 用于替换系统的sendAction:to:forEvent: 方法
- (void)heSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    
    // 1. 判断对象类型
    if ([NSStringFromClass(self.class) isEqualToString:@"UIButton"]) {
        
        // 2. 赋值间隔时间
        self.he_timeInterval = self.he_timeInterval == 0 ? DEFAULT_INTERVAL : self.he_timeInterval;
        
        // 3. 判断是否需要忽视重复点击
        if (self.isIgnoreEvent) return;
        // 4. 判断是否间隔时间大于0, 大于0的时候在经过间隔时间之后设置isIgnoreEvent的值为NO(不忽视点击, 就是允许重复点击)
        if (self.he_timeInterval > 0) {
            [self performSelector:@selector(changeIgnoreState) withObject:self afterDelay:self.he_timeInterval];
        }
        
    }
    
    // 5. 设置忽视重复点击(当重复点击的时候就会执行 if (self.isIgnoreEvent) return; )
    self.isIgnoreEvent = YES;
    // 6. 由于交换了方法的实现, 所以以下的方法其实是 sendAction:to:forEvent:
    [self heSendAction:action to:target forEvent:event];
  
}

#pragma mark -
#pragma mark 改变忽视重复点击状态
- (void)changeIgnoreState {
    [self setIsIgnoreEvent:NO];
}

#pragma mark -
#pragma mark - he_timeInterval的setter, getter
- (void)setHe_timeInterval:(NSTimeInterval)he_timeInterval {
    objc_setAssociatedObject(self, @selector(he_timeInterval), @(he_timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)he_timeInterval {
    /*
     _cmd 代表本方法的SEL, 就是 @selector(he_timeInterval)
     objc_getAssociatedObject(self, _cmd) 返回的是id类型, 需要类型转换
     */
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

#pragma mark -
#pragma mark - he_timeInterval的setter, getter
- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent {
    objc_setAssociatedObject(self, @selector(isIgnoreEvent), @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isIgnoreEvent {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

@end
