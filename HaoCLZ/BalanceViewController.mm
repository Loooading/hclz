//
//  BalanceViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/11.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "BalanceViewController.h"

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
- (IBAction)commitOrder:(id)sender {
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    NSString *path;
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setValue:myDelegate.uid forKey:@"uid"];
    [para setValue:self.shop_id forKey:@"shop_id"];
    [para setValue:self.shop_logo forKey:@"shop_logo"];
    [para setValue:_totalPrice forKey:@"total_price"];

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

- (const char *)UnicodeToISO88591:(NSString *)src{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin1);
    return [src cStringUsingEncoding:enc];
}
@end
