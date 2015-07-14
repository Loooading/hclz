//
//  RegisterSecondViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/13.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "RegisterSecondViewController.h"

@interface RegisterSecondViewController () <UITextFieldDelegate>

@end

@implementation RegisterSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Check Input And Register

- (IBAction)register:(id)sender{
    if ([self.nickname_textfield.text isEqualToString:@""] || [self.mobile_textfield.text isEqualToString:@""] || [self.email_textfield.text isEqualToString:@""]) {
        [CustomViewController showMessage:@"信息填写不完整,请重新填写!"];
        return;
    }
    if(![self isValidateEmail:self.email_textfield.text]){
        [CustomViewController showMessage:@"邮箱格式填写不正确,请重新填写!"];
        return;
    }
    
    if(![self validateMobile:self.mobile_textfield.text]){
        [CustomViewController showMessage:@"手机号格式填写不正确,请重新填写!"];
        return;
    }
    
    NSString *path = [[NSString alloc] initWithFormat:@"/TakeOut/action/user_register"];
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setValue:self.username forKey:@"userName"];
    [para setValue:self.password forKey:@"password"];
    [para setValue:self.mobile_textfield.text forKey:@"mobile"];
    [para setValue:self.email_textfield.text forKey:@"email"];
    //nickname 拉丁编码
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    NSString *nicknameString = [NSString stringWithCString:[self.nickname_textfield.text UTF8String] encoding:enc];
    NSLog(@"%@", nicknameString);
    [para setValue:nicknameString forKey:@"nickname"];

    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(![[resDic valueForKey:@"status"] intValue])
        {
            [CustomViewController showMessage:[resDic valueForKey:@"message"]];            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        else{
            [CustomViewController showMessage:[resDic valueForKey:@"message"]];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError *err){
        NSLog(@"请求错误 : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

//利用正则表达式验证邮箱
-(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
//利用正则表达式验证手机号
- (BOOL)validateMobile:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,154,157,158,159,182,183,184,187,188,170-9
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[0147-9]|8[23478]|7[0-9])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //点击键盘return,收起键盘
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - touchesBegan end edit

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
