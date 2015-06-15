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

    self.food_price_label.text = [[NSString alloc] initWithFormat:@"￥%@", self.food_price];
    self.deliver_charge_label.text = [[NSString alloc] initWithFormat:@"￥%@", self.deliver_charge];
    float totalPricetmp = [self.deliver_charge floatValue] + [self.food_price floatValue];
    _totalPrice = [NSString stringWithFormat:@"%.1f", totalPricetmp];
    self.total_price = [NSString stringWithFormat:@"￥%.1f", totalPricetmp];
    self.total_price_label.text = self.total_price;
    self.nick_name_label.text = myDelegate.nickname;
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

}

//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"%@", result.address);
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

- (IBAction)commitOrder:(id)sender {
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    NSString *path;
    if (!self.foodRequestType) {
        path = [[NSString alloc] initWithFormat:@"/TakeOut/action/modify_corderAdd"];
    }
    else{
        path = [[NSString alloc] initWithFormat:@"/TakeOut/action/modify_orderAdd"];
    }
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    [para setValue:@"25" forKey:@"uid"];

    [para setValue:self.shop_id forKey:@"shop_id"];
    [para setValue:self.foodAmount forKey:@"foodAmount"];
    [para setValue:self.shop_logo forKey:@"shop_logo"];
    [para setValue:_totalPrice forKey:@"total_price"];
    [para setValue:self.service_address_label.text forKey:@"service_address"];
    NSString *deliver_way = [[NSString alloc]initWithFormat:@"%li",(long)[self.segmentedControl selectedSegmentIndex]];
    [para setValue:deliver_way forKey:@"deliver_way"];
    [para setValue:self.shop_phone forKey:@"shop_phone"];
    [para setValue:self.shop_name forKey:@"shop_name"];
    
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"101.200.179.69:8080" customHeaderFields:nil];
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
@end
