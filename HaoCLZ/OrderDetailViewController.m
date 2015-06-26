//
//  OrderDetailViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/14.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderLIstViewController.h"
#import "UIImageView+WebCache.h"

@interface OrderDetailViewController ()

@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:NO];
    if (self.orderRequestType) {
        NSString *stringURL = [[NSString alloc] initWithFormat:@"http://%@", [_orderDetailInfo valueForKey:@"shop_logo"]];
        NSURL *imageUrl = [NSURL URLWithString:stringURL];
        [self.shop_image sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"icon"]];
    }
    self.date_label.text = [_orderDetailInfo valueForKey:@"date"];
    self.date1_label.text = [_orderDetailInfo valueForKey:@"date"];

    self.shop_name_label.text = [_orderDetailInfo valueForKey:@"shop_name"];
    if (!self.orderRequestType)
    {
        NSData *data = [[_orderDetailInfo valueForKey:@"foodAmount"] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *foodAmountArray =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSString *foodAmountString = @"";
        for (NSMutableDictionary *foodAmountDic in foodAmountArray) {
            
            NSString *foodNumberTmp = [[NSString alloc] initWithFormat:@"%@份", [foodAmountDic  valueForKey:@"food_num"]];
            foodAmountString = [foodAmountString stringByAppendingString:foodNumberTmp];
            foodAmountString = [foodAmountString stringByAppendingString:[foodAmountDic valueForKey:@"food_name"]];
            foodAmountString = [foodAmountString stringByAppendingString:@";"];
        }
        self.foodAmount_label.text = foodAmountString;
        self.shop_name_label.text = @"电子商城";
    }
    else{
        self.foodAmount_label.text = [_orderDetailInfo valueForKey:@"foodAmount"];
        self.shop_name_label.text = [_orderDetailInfo valueForKey:@"shop_name"];

    }

    self.shop_phone_label.text = [_orderDetailInfo valueForKey:@"shop_phone"];
    self.order_id_label.text = [NSString stringWithFormat:@"%@",[_orderDetailInfo valueForKey:@"order_id"]];
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    self.lianxiren_label.text = myDelegate.nickname;
    self.service_address_label.text = [_orderDetailInfo valueForKey:@"service_address"];
    self.phone_label.text = [_orderDetailInfo valueForKey:@"phone"];
    self.confirm_button.hidden = YES;
    self.delete_button.hidden = YES;

    NSUInteger orderState = [[_orderDetailInfo valueForKey:@"state"] intValue];
    NSString *stateInString;
    switch (orderState) {
        case 0:
            stateInString = @"未接单";
            self.delete_button.hidden = NO;
            break;
        case 1:
            stateInString = @"已接单";
            self.confirm_button.hidden = NO;
            break;
        case 2:
            stateInString = @"交易完成";
            break;
        case 3:
            stateInString = @"交易取消";
            break;
        default:
            stateInString = @"未知状态";
            break;
    }
    self.orderState_label.text = stateInString;

}

- (IBAction)comfirm:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要确认此订单吗?确认订单后交易完成!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    //设置UIAlertView的tag,与请求数据的类型相同.
    [alert setTag:0];
    [alert show];
//    [self changeOrder:0];
}

- (IBAction)deleOrder:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要删除此订单吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    //设置UIAlertView的tag,与请求数据的类型相同.
    [alert setTag:1];
    [alert show];
//    [self changeOrder:1];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
        if (buttonIndex == 0) {     // and they clicked OK.
            //通过alertView的tag得到请求类型
            [self changeOrder:[alertView tag]];
        }
}

//删除或确认订单,1为删除,0为确认
-(void) changeOrder:(NSUInteger) type
{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableDictionary *para = [[NSMutableDictionary alloc] init];
    
    [para setValue:myDelegate.uid forKey:@"uid"];
    NSString *path;
    if (type) {
        if (!self.orderRequestType) {
            path = [[NSString alloc] initWithFormat:@"/TakeOut/action/modify_corderUnvisible"];
            
        }
        else
        {
            path = [[NSString alloc] initWithFormat:@"/TakeOut/action/modify_orderUnvisible"];
            
        }
    }
    else
    {
        if (!self.orderRequestType) {
            path = [[NSString alloc] initWithFormat:@"/TakeOut/action/modify_confirmCOrder"];
            
        }
        else
        {
            path = [[NSString alloc] initWithFormat:@"/TakeOut/action/modify_confirmOrder"];
            
        }
        NSString *shop_id = [[NSString alloc]initWithFormat:@"%@",[self.orderDetailInfo valueForKey:@"shop_id"] ];
        [para setValue:shop_id forKey:@"shop_id"];

    }
 
    NSString *order_id = [[NSString alloc]initWithFormat:@"%@",[self.orderDetailInfo valueForKey:@"order_id"] ];
    [para setValue:order_id forKey:@"order_id"];
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"101.200.179.69:8080" customHeaderFields:nil];
    MKNetworkOperation *op = [engine operationWithPath:path params:para httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation){
        NSLog(@"respons string : %@", [operation responseString]);
        NSData *data = [operation responseData];
        NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if(![[resDic valueForKey:@"status"] intValue])
        {
            if(type == 1)
            {
                [CustomViewController showMessage:@"订单删除成功!"];
            }
            else{
                [CustomViewController showMessage:@"确认收货,交易完成!"];
            }
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            OrderLIstViewController *nyvc = [story instantiateViewControllerWithIdentifier:@"OrderLIstViewController"];
            nyvc.orderRequestType = self.orderRequestType;
            [self.navigationController pushViewController:nyvc animated:YES];
        }
        else{
            [CustomViewController showMessage:[resDic valueForKey:@"message"]];

        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError *err){
        NSLog(@"请求错误 : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
