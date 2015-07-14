//
//  LoginViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/12.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];
    UIBarButtonItem *barBtn1=[[UIBarButtonItem alloc]initWithTitle:@"回家" style:UIBarButtonItemStylePlain target:self action:@selector(backTo)];
//    self.navigationItem.leftBarButtonItem=barBtn1;
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

- (IBAction)login:(id)sender {
    if ([self.username_textField.text isEqualToString:@""] || [self.password_textFiled.text isEqualToString:@""]) {
        [CustomViewController showMessage:@"信息填写不完整,请重新填写!"];
        return;
    }
    
    NSString *path = [[NSString alloc] initWithFormat:@"/TakeOut/action/user_login"];
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setValue:self.username_textField.text forKey:@"userName"];
    [para setValue:self.password_textFiled.text forKey:@"password"];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(![[resDic valueForKey:@"status"] intValue])
        {
            [CustomViewController showMessage:[resDic valueForKey:@"message"]];
            AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
            myDelegate.uid = [resDic valueForKey:@"uid"];
            myDelegate.nickname = [resDic valueForKey:@"nickname"];
            myDelegate.phone = [resDic valueForKey:@"phone"];
            myDelegate.password = [resDic valueForKey:@"password"];
            //保存用户数据到本地,记录登录状态
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[resDic valueForKey:@"uid"] forKey:@"uid"];
            [userDefaults setObject:[resDic valueForKey:@"nickname"] forKey:@"nickname"];
            [userDefaults setObject:[resDic valueForKey:@"phone"] forKey:@"phone"];
            [userDefaults setObject:[resDic valueForKey:@"password"] forKey:@"password"];
            [userDefaults synchronize];

            [self performSegueWithIdentifier:@"goToNearBy" sender:nil];

        }
        else{
            [CustomViewController showMessage:[resDic valueForKey:@"message"]];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError *err){
        NSLog(@"请求错误 : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
    
    
}
@end
