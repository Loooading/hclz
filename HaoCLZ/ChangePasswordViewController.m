//
//  ChangePasswordViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/13.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "ChangePasswordViewController.h"

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)changePass:(id)sender {
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    
    if([self.newpass_label.text isEqualToString:@""] || [self.newpasscheck_label.text isEqualToString:@""]){
        [CustomViewController showMessage:@"请输入新的密码并确认!"];
        return;
    }
    
    NSString *newPass = self.newpass_label.text;
    NSString *newPassCheck = self.newpasscheck_label.text;
    if (![newPass isEqualToString:newPassCheck]) {
        [CustomViewController showMessage:@"两次输入的密码不相同!"];
        return;
    }
    
    NSString *path = [[NSString alloc] initWithFormat:@"/TakeOut/action/user_changePassword"];
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setValue:self.newpass_label.text forKey:@"new_password"];
    [para setValue:myDelegate.uid forKey:@"uid"];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"101.200.179.69:8080" customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(![[resDic valueForKey:@"status"] intValue])
        {
            [CustomViewController showMessage:[resDic valueForKey:@"message"]];
            [self.navigationController popViewControllerAnimated:YES];
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
