//
//  RegisterViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/12.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController () <UITextFieldDelegate>

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"取消注册" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissView)];
    //    leftButton.tintColor=[UIColor colorWithRed:129/255.0 green:129/255.0  blue:129/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = leftButton;

    [self generateCode];
}

-(void) dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Generate Validate Code

- (void)generateCode {
    for (UIView *view in self.generatedCode_label.subviews) {
        [view removeFromSuperview];
    }
    // @{
    // @name 生成背景色
    float red = arc4random() % 100 / 100.0;
    float green = arc4random() % 100 / 100.0;
    float blue = arc4random() % 100 / 100.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:0.2];
    [self.generatedCode_label setBackgroundColor:color];
    // @} end 生成背景色
    
    // @{
    // @name 生成文字
    const int count = 5;
    char data[count];
    for (int x = 0; x < count; x++) {
        int j = '0' + (arc4random_uniform(75));
        if((j >= 58 && j <= 64) || (j >= 91 && j <= 96)){
            --x;
        }else{
            data[x] = (char)j;
        }
    }
    NSString *text = [[NSString alloc] initWithBytes:data
                                              length:count encoding:NSUTF8StringEncoding];
    self.validateCode = text;
    // @} end 生成文字
    
    CGSize cSize = [@"S" sizeWithFont:[UIFont systemFontOfSize:16]];
    int width = self.generatedCode_label.frame.size.width / text.length - cSize.width;
    int height = self.generatedCode_label.frame.size.height - cSize.height;
    CGPoint point;
    float pX, pY;
    for (int i = 0, count = text.length; i < count; i++) {
        pX = arc4random() % width + self.generatedCode_label.frame.size.width / text.length * i - 1;
        pY = arc4random() % height;
        point = CGPointMake(pX, pY);
        unichar c = [text characterAtIndex:i];
        UILabel *tempLabel = [[UILabel alloc]
                              initWithFrame:CGRectMake(pX, pY,
                                                       self.generatedCode_label.frame.size.width / 4,
                                                       self.generatedCode_label.frame.size.height)];
        tempLabel.backgroundColor = [UIColor clearColor];
        
        // 字体颜色
        float red = arc4random() % 100 / 100.0;
        float green = arc4random() % 100 / 100.0;
        float blue = arc4random() % 100 / 100.0;
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        
        NSString *textC = [NSString stringWithFormat:@"%C", c];
        tempLabel.textColor = color;
        tempLabel.text = textC;
        [self.generatedCode_label addSubview:tempLabel];
    }
    
    // 干扰线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    for(int i = 0; i < count; i++) {
        red = arc4random() % 100 / 100.0;
        green = arc4random() % 100 / 100.0;
        blue = arc4random() % 100 / 100.0;
        color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        pX = arc4random() % (int)self.generatedCode_label.frame.size.width;
        pY = arc4random() % (int)self.generatedCode_label.frame.size.height;
        CGContextMoveToPoint(context, pX, pY);
        pX = arc4random() % (int)self.generatedCode_label.frame.size.width;
        pY = arc4random() % (int)self.generatedCode_label.frame.size.height;
        CGContextAddLineToPoint(context, pX, pY);
        CGContextStrokePath(context);
    }
    return;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"registerSecondStep"]) {
        RegisterSecondViewController *rsvc = segue.destinationViewController;
        rsvc.username = self.userName_textField.text;
        rsvc.password = self.password_textField.text;
    }
}

#pragma mark - Refresh Validate Code

- (IBAction)refreshValidateCode:(id)sender {
    [self generateCode];
}
#pragma mark - Check Input

- (IBAction)registerDetermin:(id)sender {
    
    if ([self.userName_textField.text isEqualToString:@""] || [self.password_textField.text isEqualToString:@""] || [self.checkPassword_textField.text isEqualToString:@""] || [self.validateCode_textField.text isEqualToString:@""]) {
        [CustomViewController showMessage:@"信息填写不完整,请重新填写!"];
        return;

    }
    
    NSString *inputCodeString = [self.validateCode_textField.text uppercaseString];
    if (![inputCodeString isEqualToString:[self.validateCode uppercaseString]]) {
        [CustomViewController showMessage:@"验证码错误,请重新输入!"];
        return;
    }
    
    NSString *firstInputPasswordString = self.password_textField.text;
    NSString *secondInputPasswordString = self.checkPassword_textField.text;
    if (![firstInputPasswordString isEqualToString:secondInputPasswordString]) {
        [CustomViewController showMessage:@"两次输入密码不同,请确认后重新输入!"];
        return;
    }
    
    [self performSegueWithIdentifier:@"registerSecondStep" sender:nil];
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

@end
