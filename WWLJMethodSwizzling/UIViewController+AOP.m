//
//  UIViewController+AOP.m
//  WWLJMethodSwizzling
//
//  Created by iShareme on 15/11/6.
//  Copyright © 2015年 iShareme. All rights reserved.
//

#import "UIViewController+AOP.h"
#import <objc/runtime.h>

@implementation UIViewController (AOP)
+ (void)load {
    
    NSLog(@"你可以在这里写一些appkey的注册");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        //更换方法的IMP
        swizzleMethod(class, @selector(viewDidLoad), @selector(aop_viewDidLoad));
        swizzleMethod(class, @selector(viewDidAppear:), @selector(aop_viewDidAppear:));
        swizzleMethod(class, @selector(viewWillAppear:), @selector(aop_viewWillAppear:));
        swizzleMethod(class, @selector(viewWillDisappear:), @selector(aop_viewWillDisappear:));
    });
}
void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)   {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
- (void)aop_viewDidAppear:(BOOL)animated {
    [self aop_viewDidAppear:animated];
}
-(void)aop_viewWillAppear:(BOOL)animated {
    [self aop_viewWillAppear:animated];
    NSLog(@"黑魔法=====视图将要出现");
#ifndef DEBUG
//    [MobClick beginLogPageView:NSStringFromClass([self class])];
#endif
}
-(void)aop_viewWillDisappear:(BOOL)animated {
    [self aop_viewWillDisappear:animated];
    NSLog(@"黑魔法=====视图将要消失");
#ifndef DEBUG
//    [MobClick endLogPageView:NSStringFromClass([self class])];
#endif
}
-(void)aop_viewDidLoad {
    [self aop_viewDidLoad];
    if ([self isKindOfClass:[UINavigationController class]]) {
        ///设置UINavigationController的一些属性,一个应用里面的UINavigationController基本是相同的
        UINavigationController *nav = (UINavigationController *)self;
        nav.navigationBar.translucent = NO;
        nav.navigationBar.barTintColor = [UIColor redColor];
        nav.navigationBar.tintColor = [UIColor whiteColor];
        NSDictionary *titleAtt = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        [[UINavigationBar appearance] setTitleTextAttributes:titleAtt];
        [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)forBarMetrics:UIBarMetricsDefault];
        //修改系统返回按钮字体大小
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSShadowAttributeName:[NSValue valueWithUIOffset:UIOffsetZero]};
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}
@end
