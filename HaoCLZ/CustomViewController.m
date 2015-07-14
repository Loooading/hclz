//
//  CustomViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/9.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "CustomViewController.h"
#import "NearByViewController.h"
#import "OrderLIstViewController.h"
#import "DSFoodViewController.h"
#import "MyFavoriteViewController.h"
#import "AboutUsViewController.h"

@interface CustomViewController ()
{
    JKSideSlipView *_sideSlipView;
//    UINavigationBar *_navBar;
//    UINavigationItem *_navItem;
}


@end

@implementation CustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _sideSlipView = [[JKSideSlipView alloc]initWithSender:self];
    _sideSlipView.backgroundColor = [UIColor redColor];
//    _sideSlipView.frame = CGRectMake(0, 0, 0, 0);
    MenuView *menu = [MenuView menuView];
    [menu didSelectRowAtIndexPath:^(id cell, NSIndexPath *indexPath) {
        NSInteger row = indexPath.row;
        NSString *viewControllerId;
        switch (row) {
            case 0:
            {
                NSLog(@"NearByViewController");
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                NearByViewController *nyvc = [story instantiateViewControllerWithIdentifier:@"NearByViewController"];
                [self.navigationController pushViewController:nyvc animated:YES];
            }
                break;
            case 1:
            {
                
                NSLog(@"OrderLIstViewController");
                AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
                if (!myDelegate.uid) {
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    LoginViewController *lvc = [story instantiateViewControllerWithIdentifier:@"LoginViewController"];
                    [self.navigationController pushViewController:lvc animated:YES];
                }
                else{
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                OrderLIstViewController *nyvc = [story instantiateViewControllerWithIdentifier:@"OrderLIstViewController"];
                    nyvc.orderRequestType = 1;
                [self.navigationController pushViewController:nyvc animated:YES];
                }
            }
                break;
            case 2:
            {
                NSLog(@"DSFoodViewController");
                
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                DSFoodViewController *nyvc = [story instantiateViewControllerWithIdentifier:@"DSFoodViewController"];
                [self.navigationController pushViewController:nyvc animated:YES];
                
            }
                break;
            case 3:
            {
                
                NSLog(@"OrderLIstViewController");
                AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
                if (!myDelegate.uid) {
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    LoginViewController *lvc = [story instantiateViewControllerWithIdentifier:@"LoginViewController"];
                    [self.navigationController pushViewController:lvc animated:YES];
                }
                else{
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    OrderLIstViewController *nyvc = [story instantiateViewControllerWithIdentifier:@"OrderLIstViewController"];
                    nyvc.orderRequestType = 0;
                    [self.navigationController pushViewController:nyvc animated:YES];
                }
            }
                break;
            case 4:
            {
                AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
                if (!myDelegate.uid) {
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    LoginViewController *lvc = [story instantiateViewControllerWithIdentifier:@"LoginViewController"];
                    [self.navigationController pushViewController:lvc animated:YES];
                }
                else{
                    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    MyFavoriteViewController *nyvc = [story instantiateViewControllerWithIdentifier:@"MyFavoriteViewController"];
                    [self.navigationController pushViewController:nyvc animated:YES];
                }
            }
                break;
            case 5:
            {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                AboutUsViewController *lvc = [story instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
                [self.navigationController pushViewController:lvc animated:YES];
            }
                break;
            default:
                break;
        }
        
        [_sideSlipView hide];
    }];
    menu.items = @[@{@"title":@"周边美食",@"imagename":@"zbms"},@{@"title":@"我的订单",@"imagename":@"order"},@{@"title":@"美食商城",@"imagename":@"meishi"},@{@"title":@"商城订单",@"imagename":@"order"},@{@"title":@"我的收藏",@"imagename":@"fav"},@{@"title":@"关于我们",@"imagename":@"aboutus"}];
    menu.tag = 1000;
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    if(myDelegate.uid){
        [menu.userManage_button setTitle:myDelegate.nickname forState:UIControlStateNormal];
        [menu.userManage_button addTarget:self action:@selector(showUserMan) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [menu.userManage_button setTitle:@"未登录" forState:UIControlStateNormal];
        [menu.userManage_button addTarget:self action:@selector(goTologin) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_sideSlipView setContentView:menu];
    [self.view addSubview:_sideSlipView];
}

-(void)showUserMan{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserManageViewController *umvc = [story instantiateViewControllerWithIdentifier:@"UserManageViewController"];
    [self showSideSlipView];
    [self.navigationController pushViewController:umvc animated:YES];

}

-(void)goTologin{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *lvc = [story instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self showSideSlipView];
    [self.navigationController pushViewController:lvc animated:YES];
}


-(void) addMenuButton{
    //创建一个左边按钮
    UIImage *imgNormal = [UIImage imageNamed:@"leftnavbuttonimg"];
    UIButton *butt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [butt setImage:imgNormal forState:UIControlStateNormal];
    [butt addTarget:self action:@selector(showSideSlipView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:butt];

//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"菜单" style:UIBarButtonItemStyleBordered target:self action:@selector(showSideSlipView)];
    self.navigationItem.leftBarButtonItem = rightButton;
}

-(void)addBackButton{
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(popFrontView)];
    self.navigationItem.backBarButtonItem = backItem;
}

-(void)popFrontView
{
    [self.navigationController popViewControllerAnimated:NO];
}

//隐藏导航栏
- (void)setNavBarHidden:(BOOL)isHidden{
    [self.navigationController.navigationBar setHidden:isHidden];
}
//设置导航栏标题
- (void)setNavBarTitle:(NSString *)title{

}

+(void)showMessage:(NSString *)message
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    showview.frame = CGRectMake((window.bounds.size.width - LabelSize.width - 20)/2, window.bounds.size.height - 300, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:1.5 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}

//显示侧滑菜单
- (void)showSideSlipView{
    [_sideSlipView switchMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
