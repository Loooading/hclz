//
//  AppDelegate.m
//  HaoCLZ
//
//  Created by Loading on 15/6/8.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>


@interface AppDelegate () <BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate>


@end

@implementation AppDelegate
{
    UIWindow *window;
    UINavigationController *navigationController;
    BMKMapManager* _mapManager;
    BMKGeoCodeSearch *_searcher;
    BMKLocationService *_locService;
    NSString *trackViewURL;
//    double _latitude;
//    double _longitude;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //通过本地UserDefault判断是否登录
    [self onCheckVersion];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",[userDefaults objectForKey:@"nickname"]);
    if(![[[userDefaults objectForKey:@"uid"] stringValue] isEqualToString:@""])
    {
        self.nickname = [userDefaults objectForKey:@"nickname"];
        self.uid = [userDefaults objectForKey:@"uid"];
        self.phone = [userDefaults objectForKey:@"phone"];
        self.password = [userDefaults objectForKey:@"password"];
    }

    // Override point for customization after application launch.
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"h6sa8pYPTg5hXoTzocm14pgG"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.f];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
    
    //初始化地理编码检索
    _searcher =[[BMKGeoCodeSearch alloc]init];
    _searcher.delegate = self;
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.latitude, self.longitude};
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
    
    // Add the navigation controller's view to the window and display.
//    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"%@", result.address);
//        self.service_address_label.text = result.address;
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    //NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    self.latitude = userLocation.location.coordinate.latitude;
    self.longitude = userLocation.location.coordinate.longitude;
    self.userLoc = userLocation;
    [_locService stopUserLocationService];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [BMKMapView willBackGround];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [BMKMapView didForeGround];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)onCheckVersion
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    //CFShow((__bridge CFTypeRef)(infoDic));
    NSString *currentVersion = [infoDic objectForKey:@"CFBundleVersion"];
    
    NSString *URL = @"http://itunes.apple.com/cn/lookup?id=1013689152";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSString *results = [[NSString alloc] initWithBytes:[recervedData bytes] length:[recervedData length] encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [self dictionaryWithJsonString:results];
    NSArray *infoArray = [dic objectForKey:@"results"];
    if ([infoArray count]) {
        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
        NSString *lastVersion = [releaseInfo objectForKey:@"version"];
        
        if (![lastVersion isEqualToString:currentVersion]) {
            trackViewURL = [releaseInfo objectForKey:@"trackViewUrl"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，请前往更新" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alert.tag = 10000;
            [alert show];
        }
//        else
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            alert.tag = 10001;
//            [alert show];
//        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==10000) {
        if (buttonIndex==0) {
            NSURL *url = [NSURL URLWithString:trackViewURL];
            [[UIApplication sharedApplication]openURL:url];
        }
    }
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
//    //跳转支付宝钱包进行支付，处理支付结果
//    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
//        NSLog(@"result = %@",resultDic);
//    }];
//    
//    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
//        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
//            NSLog(@"result = %@",resultDic);
//        }];
//    }
//    return YES;
    //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开 发包
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      NSLog(@"result = %@",resultDic);
                                                  }]; }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    return YES;
}

@end
