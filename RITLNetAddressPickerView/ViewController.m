//
//  ViewController.m
//  RITLNetAddressPickerView
//
//  Created by YueWen on 2018/4/20.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import "ViewController.h"
#import "RITLNetAddressPickerView.h"

@interface ViewController ()<RITLNetAddressPickerViewDelegate>

@property (nonatomic, strong) RITLNetAddressPickerView *addressPickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.addressPickerView = RITLNetAddressPickerView.new;
    self.addressPickerView.delegate = self;
    self.addressPickerView.provinceUrl = @"http://yun.qingnongwan.com/index.php?s=/project/sheng";
    self.addressPickerView.cityUrl = @"http://yun.qingnongwan.com/index.php?s=/project/shi";
    
}

- (void)addressPickerView:(RITLNetAddressPickerView *)pickerView
                 province:(nullable id<RITLNetAddressPickerItem>)province
                     city:(nullable id<RITLNetAddressPickerItem>)city
                   county:(nullable id<RITLNetAddressPickerItem>)county
{
    NSLog(@"province = %@,city = %@,county = %@",province.title,city.title,county.title);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addressDidTap:(id)sender {
    
    [self.addressPickerView showInViewController:self];
}

@end
