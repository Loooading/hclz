//
//  BalanceViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/11.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "BalanceViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"



@interface BalanceViewController () <BMKGeoCodeSearchDelegate>
{
    BMKGeoCodeSearch *_searcher;
    NSString *_totalPrice;
}

@end

@implementation BalanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    //食品价格
    self.food_price_label.text = [[NSString alloc] initWithFormat:@"￥%@", self.food_price];
    //配送费
    self.deliver_charge_label.text = @"￥0";
    //总价
    float totalPricetmp = [self.food_price floatValue];
    _totalPrice = [NSString stringWithFormat:@"%.1f", totalPricetmp];
    self.total_price = [NSString stringWithFormat:@"￥%.1f", totalPricetmp];
    self.total_price_label.text = self.total_price;
    //下单人
    self.nick_name_label.text = myDelegate.nickname;
    //电话
    self.phone_label.text = myDelegate.phone;
    //初始化地理编码检索
    _searcher =[[BMKGeoCodeSearch alloc]init];
    _searcher.delegate = self;
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){myDelegate.latitude, myDelegate.longitude};
//    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){39.915, 116.404};

    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
//    [reverseGeoCodeSearchOption release];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fixedCompletion:) name:@"FixCompletionNontification" object:nil];

}

//信息修改完后,通过通知中心回传数据,接收到后执行,重新设置下单信息
-(void)fixedCompletion:(NSNotification *)notification{
    NSDictionary *theDate = [notification userInfo];
    NSString *nickname = [theDate valueForKey:@"nickname"];
    NSString *address = [theDate valueForKey:@"address"];
    NSString *phone = [theDate valueForKey:@"phone"];
    if (![nickname isEqualToString:@""]) {
        self.nick_name_label.text = nickname;
    }
    if (![address isEqualToString:@""]) {
        self.service_address_label.text = address;
    }
    if (![phone isEqualToString:@""]) {
        self.phone_label.text = phone;
    }
}

//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"%@", result.address);
        //显示反向地理编码检索信息
        self.service_address_label.text = result.address;
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
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


//提交订单
-(void)commitOrderToServer
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    NSString *path;
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setValue:myDelegate.uid forKey:@"uid"];
    [para setValue:self.shop_id forKey:@"shop_id"];
    [para setValue:self.shop_logo forKey:@"shop_logo"];
    [para setValue:_totalPrice forKey:@"total_price"];
    [para setValue:self.pay_state forKey:@"pay_state"];
    
    NSString *deliver_way = [[NSString alloc]initWithFormat:@"%li",(long)[self.segmentedControl selectedSegmentIndex]];
    [para setValue:deliver_way forKey:@"deliver_way"];
    [para setValue:self.shop_phone forKey:@"shop_phone"];
    
    //提交订单时须对中文进行latin编码转换
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    //如果是商城订单,则不需要传shop_name参数,否则编码latin后传参
    if (!self.foodRequestType) {
        path = [[NSString alloc] initWithFormat:@"/TakeOut/action/modify_corderAdd"];
    }
    else{
        path = [[NSString alloc] initWithFormat:@"/TakeOut/action/modify_orderAdd"];
        //shop_name   latin编码
        NSString *shop_nameString = [NSString stringWithCString:[self.shop_name UTF8String] encoding:enc];
        NSLog(@"%@", shop_nameString);
        [para setValue:shop_nameString forKey:@"shop_name"];
    }
    //foodAmount   latin编码
    NSString *foodAmountString = [NSString stringWithCString:[self.foodAmount UTF8String] encoding:enc];
    NSLog(@"%@", foodAmountString);
    //配送地址   latin编码
    NSString *serivce_addressString = [NSString stringWithCString:[self.service_address_label.text UTF8String] encoding:enc];
    NSLog(@"%@", serivce_addressString);
    //设置foodAmount 和 配送地址参数
    [para setValue:foodAmountString forKey:@"foodAmount"];
    [para setValue:serivce_addressString forKey:@"service_address"];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:hostName customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(![[resDic valueForKey:@"status"] intValue])
        {
            [CustomViewController showMessage:@"下单成功!"];
            [self performSegueWithIdentifier:@"goToNearby" sender:nil];
        }
        else{
            [CustomViewController showMessage:[resDic valueForKey:@"message"]];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError *err){
        NSLog(@"请求错误 : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];

}

- (IBAction)commitOrder:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"支付方式" message:@"请您选择支付方式" delegate:self cancelButtonTitle:@"支付宝支付" otherButtonTitles:@"线下支付", nil];
    //设置UIAlertView的tag,与请求数据的类型相同.
    [alert setTag:0];
    [alert show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //支付宝支付并提交订单
        [self payThoughAliPay];
    }
    if(buttonIndex == 1)
    {
        //线下支付,pay_state置0
        self.pay_state = @"0";
        [self commitOrderToServer];

    }
}
//通过支付宝支付,支付成功返回YES,不成功返回NO
-(void)payThoughAliPay
{
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088911994383085";
    NSString *seller = @"merben@vip.126.com";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAJRjmJESNojZ4YmoTkoYgBXQ7JTqxsR7cQdsLwj3t6hwQgmGqoYUo5w92zB+FWAH6Qh8nv5V6/2QQ8I1hzRjyC6Rm1DGpNTEzmyWeX6a1WeZYCyE3BlCrDNvCCzGAk0PvxIWfx7gMIfAgG1Ocu5TaQz31CVSgjxmBF9csXXH4nFfAgMBAAECgYApcH7k1I9CPIaNqODkNF9guE25cK89o7N2/TFNcdBqS59FhcQNWaovMd8KdcuGW+8qHZNRN7GFyEoD7GrrqIn4endmWOadAGTxZUfh1tM7R1zQlVT5Njp2BrlxY4PytVBqY850arMjNg+bjtN9YMvvUTuRHcojX2tz7HHFiRRNkQJBAMUFg8+0r2sKUI3srA0ASfT53Lguu9b2UnBbWx0B5qYAsR/0tqNzeQOIixN9FsOL+XHpXiRlfiXij+Tsz861XxsCQQDAzzGy3HsUh0triTnbKyprIiMfCsQg4bZYHmyZytpEqTSs5f6WUiqAKr9sWYOwS9sjEZpC2iyXJqjHnQIHBqcNAkAIRGj5iD1sImyq5+l4SjDQRMPMPrnHFWL0MAEswG2rPZAxJRWc2jWTvmEHmlIgNnlrHD3FDTUz5cPf+UfnBplNAkApxHiaq4KKJujiqb57yPUOcj2zesyT5vFuU2DpS/VOjG0Zy1UEUVZdn2UKXrXVWgllpmmJc+PW9ov3ef63cOx9AkEAlOwqIxOjGFYcF8RFI/t/yMk/p+c7ZeTopCmbyUncaEYeGf+vyjLzIwbYBC0w/531lF/UlSMRfX5BCuB52Jdbzw==";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    //partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    if (!self.foodRequestType) {
        //解析jsonArray
        NSData *data = [self.foodAmount dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *foodAmountArray =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *foodAmountString = @"";
        for (NSMutableDictionary *foodAmountDic in foodAmountArray) {
            NSString *foodNumberTmp = [[NSString alloc] initWithFormat:@"%@份", [foodAmountDic  valueForKey:@"food_num"]];
            foodAmountString = [foodAmountString stringByAppendingString:foodNumberTmp];
            foodAmountString = [foodAmountString stringByAppendingString:[foodAmountDic valueForKey:@"food_name"]];
            foodAmountString = [foodAmountString stringByAppendingString:@";"];
        }
        order.productDescription = foodAmountString;
        order.productName = @"美食商城"; //商品标题

    }
    else{
        order.productName = self.shop_name; //商品标题
        order.productDescription = self.foodAmount; //商品描述
    }
    order.amount = self.food_price; //商品价格
//    order.amount = @"0.1"; //商品价格

    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"HaoCLZ";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            NSString *resState = [resultDic valueForKey:@"resultStatus"];
            if ([resState isEqualToString:@"9000"]||[resState isEqualToString:@"8000"]) {
//                return YES;
                self.pay_state = @"1";
                [self commitOrderToServer];
            }
            else{
                [CustomViewController showMessage:@"支付错误!请重新支付或重新下单"];
            }
        }];

    }
}

- (const char *)UnicodeToISO88591:(NSString *)src{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    return [src cStringUsingEncoding:enc];
}
    
- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}
@end
