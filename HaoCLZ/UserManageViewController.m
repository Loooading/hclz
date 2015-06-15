//
//  UserManageViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/13.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "UserManageViewController.h"

@interface UserManageViewController ()

@end

@implementation UserManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    self.nickname_label.text = myDelegate.nickname;
    
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

- (IBAction)logout:(id)sender {
    [CustomViewController showMessage:@"已退出登录!"];
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    myDelegate.uid = nil;
    myDelegate.nickname = nil;
    myDelegate.phone = nil;
    myDelegate.password = nil;
    [self performSegueWithIdentifier:@"goToNearby" sender:nil];
    
}
@end
