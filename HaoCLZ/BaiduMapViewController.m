//
//  BaiduMapViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/16.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "BaiduMapViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "AppDelegate.h"
#import "FoodViewController.h"

@interface BaiduMapViewController () <BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    BMKMapView *_mapView;
    BMKLocationService *_locService;
    NSUInteger _selectedIndex;
}
@end

@implementation BaiduMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavRightButton];
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view.
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _mapView.centerCoordinate =myDelegate.userLoc.location.coordinate;
    self.view = _mapView;
    
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.f];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;

    for (int i = 0; i < self.shopList.count; i++) {
        NSMutableDictionary *shop = [self.shopList[i] valueForKey:@"shops"];
        float log = [[shop valueForKey:@"longitude"] floatValue];
        float lat = [[shop valueForKey:@"latitude"] floatValue];

        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        coor.latitude = lat;
        coor.longitude = log;
        annotation.coordinate = coor;
        annotation.title = [shop valueForKey:@"shop_name"];
        annotation.subtitle = @"戳我进入店铺哦!";
        [_mapView addAnnotation:annotation];
    }
}

-(void)addNavRightButton{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"定位" style:UIBarButtonItemStyleBordered target:self action:@selector(startLocate)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)startLocate{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    //启动LocationService
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}
// Override
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示.
        return newAnnotationView;
    }
    return nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;

}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
//    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"当前位置%f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
    
    _mapView.centerCoordinate = userLocation.location.coordinate;
    
    CLLocationCoordinate2D loc = [userLocation.location coordinate];
    
    //放大地图到自身的经纬度位置。
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(loc, BMKCoordinateSpanMake(0.1f,0.1f));
    BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    [_mapView setRegion:adjustedRegion animated:YES];
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"mapToShowFood");
    BMKPointAnnotation *ann = view.annotation;
    _selectedIndex = [_mapView.annotations indexOfObject:ann];
    [self performSegueWithIdentifier:@"mapToShowFood" sender:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"mapToShowFood"]) {
        FoodViewController *fv = segue.destinationViewController;
        NSDictionary *shopInfo = self.shopList[_selectedIndex];
        NSString *string_shop_id = [[NSString alloc] initWithFormat:@"%@",[[shopInfo valueForKey:@"shops"] valueForKey:@"shop_id"]];
        fv.shop_id = string_shop_id;
        fv.shop_name = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_name"];
        fv.shop_phone = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_phone"];
        NSString *shop_logo_url = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_logo"];
        NSString *pic_name = [shop_logo_url substringFromIndex:40];
        fv.shop_logo = pic_name;
        fv.deliver_charge = [[shopInfo valueForKey:@"shops"] valueForKey:@"deliver_charge"];
        NSString *title = [[shopInfo valueForKey:@"shops"] valueForKey:@"shop_name"];
        fv.navigationItem.title = title;
    }
}


@end
