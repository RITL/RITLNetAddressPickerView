# RITLNetAddressPickerView

需要导入[Masonry](https://github.com/SnapKit/Masonry)、[YYModel](https://github.com/ibireme/YYModel)

使用网络请求进行地址选择的，支持省，市，区(县)的层次选择


由于选择器只支持网络加载，如需本地数据，请查看[LMLJDDwonToUpAddressPicker](https://github.com/liaodalin19903/LMLJDDwonToUpAddressPicker)


```
///Demo代码

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.addressPickerView = RITLNetAddressPickerView.new;
    self.addressPickerView.delegate = self;
    self.addressPickerView.dataSource = self;
    
    
    //只选择省，只赋值provinceUrl即可
    self.addressPickerView.provinceUrl = @"http://yun.qingnongwan.com/index.php?s=/project/sheng";
    //还需要选择市，赋值cityUrl
    self.addressPickerView.cityUrl = @"http://yun.qingnongwan.com/index.php?s=/project/shi";
    //如果需要区(县)，请将countyUrl赋值
    self.addressPickerView.countyUrl = nil;
}

#pragma mark - <RITLNetAddressPickerViewDelegate>

- (void)addressPickerView:(RITLNetAddressPickerView *)pickerView
                 province:(nullable id<RITLNetAddressPickerItem>)province
                     city:(nullable id<RITLNetAddressPickerItem>)city
                   county:(nullable id<RITLNetAddressPickerItem>)county
{
    NSLog(@"province = %@,city = %@,county = %@",province.title,city.title,county.title);
}

- (void)addressPickerViewWillDismiss:(RITLNetAddressPickerView *)pickerView
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

#pragma mark - <RITLNetAddressPickerViewDataSource>

/// 根据网络请求回来的数据，自行进行处理返回数据源格式的数据源方法
//- (NSArray <id<RITLNetAddressPickerItem>>*)addressPickerView:(RITLNetAddressPickerView *)pickerView response:(id)responseObject
//{
//
//}


/// 网络请求出现问题的回调
//- (void)addressPickerView:(RITLNetAddressPickerView *)pickerView error:(NSError *)error
//{
//
//}

```

![demo](https://github.com/RITL/RITLNetAddressPickerView/blob/master/RITLAddressPickerView/RITLNetAddressPickerView.gif)
