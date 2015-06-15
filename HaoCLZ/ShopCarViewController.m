//
//  ShopCarViewController.m
//  HaoCLZ
//
//  Created by Loading on 15/6/11.
//  Copyright (c) 2015年 liuhj. All rights reserved.
//

#import "ShopCarViewController.h"

@interface ShopCarViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation ShopCarViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *foodNumberText = [[NSString alloc] initWithFormat:@"%lu份美食", (unsigned long)self.foodNumber];
    self.foodNumberLabel.text = foodNumberText;
    
    NSString *totalPriceText = [[NSString alloc] initWithFormat:@"￥%.1f", self.totalPrice ];
    self.totalPriceLaber.text = totalPriceText;
    
    
}

-(void)checkLogin{
    AppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    if(!myDelegate.uid){
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShopCarViewController *lvc = [story instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController pushViewController:lvc animated:YES];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.shopCarInfo.count;
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
    NSDictionary *dic = self.shopCarInfo[indexPath.row];
    cell.food_name.text = [dic valueForKey:@"food_name"];
    cell.foodNumber.text = [dic valueForKey:@"food_number"];
    cell.foodPrice.text = [dic valueForKey:@"food_price"];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (self.foodRequestType) {
        for (NSMutableDictionary *shopCarDic in _shopCarInfo) {
            
            NSString *foodNumberTmp = [[NSString alloc] initWithFormat:@"%@份", [shopCarDic  valueForKey:@"food_number"]];
            foodAmount = [foodAmount stringByAppendingString:foodNumberTmp];
            foodAmount = [foodAmount stringByAppendingString:[shopCarDic valueForKey:@"food_name"]];
            foodAmount = [foodAmount stringByAppendingString:@";"];
        }
    }
    else{
        NSMutableString *foodAmountMutString = [[NSMutableString alloc] initWithString:@"["];
        for (NSMutableDictionary *shopCarDic in _shopCarInfo) {
            NSString *str1 = [shopCarDic valueForKey:@"food_number"];
            NSString *str2 = [shopCarDic valueForKey:@"food_id"];
            NSString *str3 = [shopCarDic valueForKey:@"food_name"];
            NSString *stringJsonArray = [NSString stringWithFormat:@"{\"food_num\":\"%@\",\"food_id\":\"%@\",\"food_name\":\"%@\"},", str1 ,str2, str3];
            [foodAmountMutString appendString:stringJsonArray];
        }
        NSUInteger location = [foodAmountMutString length]-1;
        NSRange range = NSMakeRange(location, 1);
        // 4. 将末尾逗号换成结束的]}
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
//        bvc.navigationController.title = @"提交懒单";
    }
}
@end
