//
//  ShopCarViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/11.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "ShopCarViewController.h"
#import "MBProgressHUD.h"

@interface ShopCarViewController ()<UITableViewDataSource, UITableViewDelegate>
{
//    float allPrice;
//    int foodNumber;
    NSMutableArray *shopCarDisplayList;
    MBProgressHUD *HUD;
}
@end

@implementation ShopCarViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *foodNumberText = [[NSString alloc] initWithFormat:@"%lu份美食", (unsigned long)self.foodNumber];
    self.foodNumberLabel.text = foodNumberText;
    
    NSString *totalPriceText = [[NSString alloc] initWithFormat:@"￥%.1f", self.totalPrice ];
    self.totalPriceLaber.text = totalPriceText;
    
    [self initTableViewData];
}

//初始化购物车列表,对传递过来的列表进行过滤处理,如果food_number为0,则不加入显示数据
-(void) initTableViewData{
    shopCarDisplayList = [[NSMutableArray alloc] init];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    //如果设置此属性则当前的view置于后台
    HUD.dimBackground = YES;
    
    //设置对话框文字
    HUD.labelText = @"努力加载中..";
    
    //显示对话框
    [HUD showAnimated:YES whileExecutingBlock:^{
        //对话框显示时需要执行的操作
        //        sleep(3);
        for (NSDictionary *dic in self.shopCarInfo) {
            NSString *food_number_cond = [dic valueForKey:@"food_number"];
            if (![food_number_cond isEqualToString:@"0"]) {
                [shopCarDisplayList addObject:dic];
            }
            [self.shopCarInfoTableView reloadData];
        }
    } completionBlock:^{
        //操作执行完后取消对话框
        [HUD removeFromSuperview];
        HUD = nil;
    }];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return shopCarDisplayList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer;
    ShopCarTableViewCell * cell ;
    cellIdentifer = @"ShopCarTableViewCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if(!cell)
    {
        cell = [[ShopCarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    NSDictionary *dic = shopCarDisplayList[indexPath.row];
    //食品名称
    cell.food_name.text = [dic valueForKey:@"food_name"];
    //购买数量
    cell.foodNumber.text = [dic valueForKey:@"food_number"];
    //食品单价
    cell.foodPrice.text = [[NSString alloc] initWithFormat:@"￥%@", [dic valueForKey:@"price"] ];
    //加按钮操作
    [cell.addButton addTarget:self action:@selector(addToShopCar:event:) forControlEvents:UIControlEventTouchUpInside];
    //减按钮操作
    [cell.minusButton addTarget:self action:@selector(minusFromShopCar:event:) forControlEvents:UIControlEventTouchUpInside];
    int num =  [cell.foodNumber.text intValue];
    if (num <= 0)
    {
        [cell.minusButton setEnabled:NO];
    }
    else{
        [cell.minusButton setEnabled:YES];
    }
    return cell;
}

//购物车增加食品
- (IBAction)addToShopCar:(id)sender event:(id)event{
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.shopCarInfoTableView];
    NSIndexPath *indexPath= [self.shopCarInfoTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath!= nil)
    {
        NSUInteger rowIndex = indexPath.row;
        NSDictionary *dic = [shopCarDisplayList objectAtIndex:rowIndex];
        float addPrice = [[dic valueForKey:@"price"] floatValue];
        self.totalPrice += addPrice;
        NSString *totalPrice = [[NSString alloc] initWithFormat:@"￥%.1f", self.totalPrice];
        self.totalPriceLaber.text = totalPrice;
    
        self.foodNumber += 1;
        self.foodNumberLabel.text = [[NSString alloc] initWithFormat:@"%lu份美食", (unsigned long)self.foodNumber];
        int num = [[shopCarDisplayList[rowIndex] valueForKey:@"food_number"] intValue];
        num += 1;
        //修改购物车表
        [shopCarDisplayList[rowIndex] setValue:[NSString stringWithFormat:@"%i",num] forKey:@"food_number"];
        [self.shopCarInfoTableView reloadData];
    }
}

//购物车减去食品
- (IBAction)minusFromShopCar:(id)sender event:(id)event{
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.shopCarInfoTableView];
    NSIndexPath *indexPath= [self.shopCarInfoTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath!= nil)
    {
        NSUInteger rowIndex = indexPath.row;
        NSDictionary *dic = [shopCarDisplayList objectAtIndex:rowIndex];
        float addPrice = [[dic valueForKey:@"price"] floatValue];
        self.totalPrice -= addPrice;
        NSString *totalPrice = [[NSString alloc] initWithFormat:@"￥%.1f", self.totalPrice];
        self.totalPriceLaber.text = totalPrice;
        
        self.foodNumber -= 1;
        self.foodNumberLabel.text = [[NSString alloc] initWithFormat:@"%lu份美食", (unsigned long)self.foodNumber];
        int num = [[shopCarDisplayList[rowIndex] valueForKey:@"food_number"] intValue];
        num -= 1;
        //修改购物车表
        [shopCarDisplayList[rowIndex] setValue:[NSString stringWithFormat:@"%i",num] forKey:@"food_number"];
        [self.shopCarInfoTableView reloadData];
    }
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSString *foodAmount = @"";
    //如果是普通订单,则不需要拼jsonArray,直接连接字符串
    if (self.foodRequestType) {
        for (NSMutableDictionary *shopCarDic in _shopCarInfo) {
            if (![[shopCarDic  valueForKey:@"food_number"] isEqualToString:@"0"]) {
                NSString *foodNumberTmp = [[NSString alloc] initWithFormat:@"%@份", [shopCarDic  valueForKey:@"food_number"]];
                foodAmount = [foodAmount stringByAppendingString:foodNumberTmp];
                foodAmount = [foodAmount stringByAppendingString:[shopCarDic valueForKey:@"food_name"]];
                foodAmount = [foodAmount stringByAppendingString:@";"];
            }
        }
    }
    //否则是商城订单,需要拼jsonArray串
    else{
        NSMutableString *foodAmountMutString = [[NSMutableString alloc] initWithString:@"["];
        for (NSMutableDictionary *shopCarDic in _shopCarInfo) {
            NSString *str1 = [shopCarDic valueForKey:@"food_number"];
            NSString *str2 = [shopCarDic valueForKey:@"food_id"];
            NSString *str3 = [shopCarDic valueForKey:@"food_name"];
            if (![str1 isEqualToString:@"0"]) {
                NSString *stringJsonArray = [NSString stringWithFormat:@"{\"food_num\":\"%@\",\"food_id\":\"%@\",\"food_name\":\"%@\"},", str1 ,str2, str3];
                [foodAmountMutString appendString:stringJsonArray];
            }
            
        }
        NSUInteger location = [foodAmountMutString length]-1;
        NSRange range = NSMakeRange(location, 1);
        // 将末尾逗号换成结束的"]}"
        [foodAmountMutString replaceCharactersInRange:range withString:@"]"];
        
        NSLog(@"jsonString = %@",foodAmountMutString);
        foodAmount = foodAmountMutString;

    }
    
    if ([segue.identifier isEqualToString:@"goToBalance"]) {
        BalanceViewController *bvc = segue.destinationViewController;;
        bvc.food_price = [[NSString alloc] initWithFormat:@"%.1f", self.totalPrice];
        bvc.foodAmount = foodAmount;
        bvc.shop_id = self.shop_id;
        bvc.shop_name = self.shop_name;
        bvc.shop_phone = self.shop_phone;
        bvc.shop_logo = self.shop_logo;
        bvc.deliver_charge = self.deliver_charge;
        bvc.foodRequestType = self.foodRequestType;
    }
}
- (IBAction)goToBalance:(id)sender {
    if (self.foodNumber == 0) {
        [CustomViewController showMessage:@"美食篮子已清空了!"];
        return;
    }
    else{
        [self performSegueWithIdentifier:@"goToBalance" sender:nil];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
