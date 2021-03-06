//
//  Categories.h
//  Categories
//
//  Created by luowei on 15/8/11.
//  Copyright (c) 2015年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyKeyboardViewController;

@interface NSDictionary(Ini)

//解析Emoji表情ini文件字符串
+(NSDictionary *)dictFromEmoticonIni:(NSString *)iniString;

@end

@interface UIView (FindUIViewController)

//获得一个View的响应ViewController
- (UIViewController *)responderViewController;

- (MyKeyboardViewController *)responderKBViewController;

//获得指class类型的父视图
-(id)superViewWithClass:(Class)clazz;

@end

@interface UIView (Rotation)

//用于接收屏幕发生旋转消息
- (void)rotationToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end


@interface UIView (NoScrollToTop)

- (void)subViewNOScrollToTopExcludeClass:(Class)clazz;

@end


//更新外观
@interface UIView (updateAppearance)
- (void)updateAppearance;
@end
