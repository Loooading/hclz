//
//  CustomViewController.h
//  HaoCLZ
//
//  Created by Loading on 15/6/9.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKSideSlipView.h"
#import "MenuView.h"
//#import "AppDelegate.h"
#import "LoginViewController.h"
//#import "NearByViewController.h"
#import "UserManageViewController.h"
//#import "OrderLIstViewController.h"
#import "GlobalDefine.h"


@interface CustomViewController : UIViewController

//@property (strong, nonatomic) MenuView *menu;
- (void)setNavBarHidden:(BOOL)isHidden;
//设置导航栏标题
- (void)setNavBarTitle:(NSString *)title;
-(void)addBackButton;
-(void)addMenuButton;
+(void)showMessage:(NSString *)message;
@end
