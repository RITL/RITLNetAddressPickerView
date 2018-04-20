//
//  RITLNetAddressPickerView.m
//  RITLNetAddressPickerView
//
//  Created by YueWen on 2018/4/20.
//  Copyright © 2018年 YueWen. All rights reserved.
//
#import "RITLNetAddressPickerView.h"
#import "RITLNetAddressPickerCell.h"
#if __has_include(<YYModel/YYModel.h>)
#import <YYModel.h>
#else
#import "YYModel.h"
#endif
#import <RITLKit.h>
#import <objc/runtime.h>

#pragma mark - Default Item

/// 默认的数据类
@interface RITLNetAddressPickerItem : NSObject <RITLNetAddressPickerItem>
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@end

@implementation RITLNetAddressPickerItem

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{@"identifier" : @"id",
             @"title"      : @"name"
             };
}


@end

#pragma mark - UITableView Extension

@interface UITableView (NWAddressPickerView)

@property (nonatomic, copy) NSString *ad_titleLabelKey;
@property (nonatomic, copy) NSString *ad_dataKey;
@property (nonatomic, copy) NSString *ad_requestKey;

/// 负责联动的tableView
@property (nonatomic, weak, nullable) UITableView *associateTableView;
@property (nonatomic, copy) NSString *associateItemName;

@end

@implementation UITableView (NWAddressPickerView)

- (NSString *)ad_dataKey
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAd_dataKey:(NSString *)ad_dataKey
{
    objc_setAssociatedObject(self, @selector(ad_dataKey), ad_dataKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)ad_requestKey
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAd_requestKey:(NSString *)ad_requestKey
{
    objc_setAssociatedObject(self, @selector(ad_requestKey), ad_requestKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)ad_titleLabelKey
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAd_titleLabelKey:(NSString *)ad_titleLabelKey
{
    objc_setAssociatedObject(self, @selector(ad_titleLabelKey), ad_titleLabelKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UITableView *)associateTableView
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAssociateTableView:(UITableView *)associateTableView
{
    objc_setAssociatedObject(self, @selector(associateTableView), associateTableView, OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)associateItemName
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAssociateItemName:(NSString *)associateItemName
{
    objc_setAssociatedObject(self, @selector(associateItemName), associateItemName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


#pragma mark -



#pragma mark - PickerView

#define NWAddressPickerSelectedColor [UIColor colorWithRed:(6)/255.0 green:(193)/255.0 blue:(174)/255.0 alpha:(1)]

@interface RITLNetAddressPickerView()<UITableViewDelegate,UITableViewDataSource>

/// 底部视图
@property (nonatomic, strong) UIView * contentView;

/// 顶部搭载标题等操作的视图
@property (nonatomic, strong) UIView *topView;
/// 关闭的按钮
@property (nonatomic, strong) UIButton *closeButton;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 确定的按钮
@property (nonatomic, strong) UIButton *sureButton;

/// 选择的按钮
@property (nonatomic, strong) UILabel *provinceButton;
@property (nonatomic, strong) UILabel *cityButton;
@property (nonatomic, strong) UILabel *countyButton;

/// 模拟横线
@property (nonatomic, strong) UIView *lineView;

/// 底部搭载tableView的滚动视图
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UITableView *provincesTableView;
@property (nonatomic, strong) UITableView *citiesTableView;
@property (nonatomic, strong) UITableView *countiesTableView;

@property (nonatomic, assign) CGFloat headHeight; // 默认88


#pragma mark - 数据
/// 所有的省份
@property (nonatomic, copy)NSArray<id<RITLNetAddressPickerItem>> *provinces;
/// 所有的城市
@property (nonatomic, copy)NSArray<id<RITLNetAddressPickerItem>> *cities;
/// 所有的县/区
@property (nonatomic, copy)NSArray<id<RITLNetAddressPickerItem>> *counties;

///选择
@property (nonatomic, strong) id<RITLNetAddressPickerItem> sel_province;
@property (nonatomic, strong) id<RITLNetAddressPickerItem> sel_city;
@property (nonatomic, strong) id<RITLNetAddressPickerItem> sel_county;


#pragma mark - 记录的viewController
@property (nonatomic, weak, nullable) UIViewController *visableViewController;

@end

@implementation RITLNetAddressPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:UIScreen.mainScreen.bounds]) {
        
        [self buildDatas];
        [self buildSubviews];
    }
    
    return self;
}


- (void)buildDatas
{
    /// 数据源清空
    _provinces = @[];
    _cities = @[];
    _counties = @[];
    
    _provinceUrl = @"";
    _cityUrl = @"";
    _countyUrl = @"";
    
    _numberOfRow = 7;
    _rowHeight = 44;
    _headHeight = 88;
    
    _method = @"GET";
}


- (void)buildSubviews
{
    self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
    [self addUIControlHandlerTarget:self action:@selector(dismiss)];
    
    self.contentView = ({
        
        UIView *view = [UIView new];
        view.backgroundColor = UIColor.whiteColor;
        
        view.ritl_size = CGSizeMake(UIScreen.mainScreen.ritl_width, _numberOfRow * _rowHeight);
        view.ritl_originPoint = CGPointMake(0, self.ritl_height);
        
        view;
    });
    
    ///标题以及响应按钮
    self.closeButton = ({
        
        UIButton *view = [UIButton new];
        view.adjustsImageWhenHighlighted = false;
        view.backgroundColor = [UIColor whiteColor];
        [view setImage:@"picker_cancelButton".ritl_image forState:UIControlStateNormal];
        [view addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        view.ritl_size = CGSizeMake(44, 44);
        view.ritl_originPoint = CGPointMake(0, 0);
        
        view;
    });
    
    self.sureButton = ({
        
        UIButton *view = [UIButton new];
        view.adjustsImageWhenHighlighted = false;
        view.backgroundColor = [UIColor whiteColor];
        view.titleLabel.font = RITLUtilityFont(RITLFontPingFangSC_Regular, 14);
        [view setTitle:@"确定" forState:UIControlStateNormal];
        [view setTitleColor:NWAddressPickerSelectedColor forState:UIControlStateNormal];
        
        view.ritl_size = @[@60,@40].ritl_size;
        view.ritl_originPoint = @[@(self.ritl_width - 60),@2].ritl_point;
        
        view;
    });
    
    [self.sureButton addTarget:self action:@selector(submit) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = ({
        
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor whiteColor];
        label.text = @"请选择地址";
        label.font = RITLUtilityFont(RITLFontPingFangSC_Regular, 15);;
        label.textColor = RITLColorSimpleFromIntRBG(51);
        
        label.ritl_size = @[@100,@44].ritl_size;
        [label sizeToFit];
        label.center = @[@(self.ritl_width / 2.0),@22].ritl_point;
        
        label;
    });
    
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.closeButton];
    [self.contentView addSubview:self.sureButton];
    [self.contentView addSubview:self.titleLabel];
    
    /// 省市的标签
    self.provinceButton = ({
        
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = true;
        label.font = RITLUtilityFont(RITLFontPingFangSC_Regular, 14);
        label.textColor = NWAddressPickerSelectedColor;
        label.text = @"请选择";
        [label addUIControlHandlerTarget:self action:@selector(titleButtonsDidClick:)];
        
        label.ritl_size = @[@60,@40].ritl_size;
        label.ritl_originPoint = @[@0,@44].ritl_point;
        
        label;
    });
    
    self.cityButton = ({

        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = true;
        label.font = RITLUtilityFont(RITLFontPingFangSC_Regular, 14);
        label.textColor = NWAddressPickerSelectedColor;
        label.text = @"请选择";
        label.hidden = true;
        [label addUIControlHandlerTarget:self action:@selector(titleButtonsDidClick:)];
        
        label.ritl_size = @[@60,@40].ritl_size;
        label.ritl_originPoint = @[@80,@44].ritl_point;
        
        label;
    });

    self.countyButton = ({
        
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = true;
        label.font = RITLUtilityFont(RITLFontPingFangSC_Regular, 14);
        label.textColor = NWAddressPickerSelectedColor;
        label.text = @"请选择";
        label.hidden = true;
        [label addUIControlHandlerTarget:self action:@selector(titleButtonsDidClick:)];
        
        label.ritl_size = @[@60,@40].ritl_size;
        label.ritl_originPoint = @[@160,@44].ritl_point;
        
        label;
    });
    
    self.lineView = ({
        
        UIView *view = [UIView new];
        view.backgroundColor = RITLColorSimpleFromIntRBG(242);
        
        view.ritl_size = @[@(self.ritl_width),@1].ritl_size;
        view.ritl_originPoint = @[@0,@(_headHeight)].ritl_point;
        
        view;
    });
    
    self.contentView.ritl_view.add(self.provinceButton).add(self.cityButton).add(self.countyButton);
    [self.contentView addSubview:self.lineView];
    
    /// 滚动视图
    self.contentScrollView = ({
        
        UIScrollView *view = [UIScrollView new];
        view.backgroundColor = UIColor.whiteColor;
        view.pagingEnabled = true;
        
        view.ritl_size = @[@(self.ritl_width),@(self.rowHeight * self.numberOfRow)].ritl_size;
        view.ritl_originPoint = @[@0,@(self.lineView.ritl_maxY)].ritl_point;
        
        view.contentSize = @[@(self.ritl_width * 3),@(view.ritl_height)].ritl_size;

        view;
    });
    
    self.provincesTableView = ({
        
        UITableView *view = [UITableView new];
        view.backgroundColor = UIColor.whiteColor;
        view.ad_dataKey = @"provinces";
        view.ad_titleLabelKey = @"provinceButton";
        view.ad_requestKey = self.provinceUrl;
        view.associateItemName = @"sel_province";
        view.estimatedRowHeight = 0;
        view.frame = self.contentScrollView.bounds;
        
        [view registerClass:RITLNetAddressPickerCell.class forCellReuseIdentifier:NSStringFromClass(RITLNetAddressPickerCell.class)];
        
        view.tableFooterView = UIView.new;
        
        view;
    });
    
    
    self.citiesTableView = ({
        
        UITableView *view = [UITableView new];
        view.backgroundColor = UIColor.whiteColor;
        view.tableFooterView = UIView.new;
        view.ad_dataKey = @"cities";
        view.ad_titleLabelKey = @"cityButton";
        view.ad_requestKey = self.cityUrl;
        view.associateItemName = @"sel_city";
        view.estimatedRowHeight = 0;
        
        [view registerClass:RITLNetAddressPickerCell.class forCellReuseIdentifier:NSStringFromClass(RITLNetAddressPickerCell.class)];
        
        view.frame = self.contentScrollView.bounds;
        view.ritl_originX = self.contentScrollView.ritl_width * 1;
        
        view;
    });
    
    
    self.countiesTableView = ({
        
        UITableView *view = [UITableView new];
        view.backgroundColor = UIColor.whiteColor;
        view.tableFooterView = UIView.new;
        view.ad_dataKey = @"counties";
        view.ad_titleLabelKey = @"countyButton";
        view.ad_requestKey = self.countyUrl;
        view.associateItemName = @"sel_county";
        view.estimatedRowHeight = 0;
        
        [view registerClass:RITLNetAddressPickerCell.class forCellReuseIdentifier:NSStringFromClass(RITLNetAddressPickerCell.class)];
        
        view.frame = self.contentScrollView.bounds;
        view.ritl_originX = self.contentScrollView.ritl_width * 2;
        
        view;
    });
    
    [self.contentView addSubview:self.contentScrollView];
    self.contentScrollView.ritl_view
    .add(self.provincesTableView)
    .add(self.citiesTableView)
    .add(self.countiesTableView);
    
    self.provincesTableView.dataSource = self.citiesTableView.dataSource = self.countiesTableView.dataSource = self;
    self.provincesTableView.delegate = self.citiesTableView.delegate = self.countiesTableView.delegate = self;
    
    //设置关联tableView
    self.provincesTableView.associateTableView = self.citiesTableView;
    self.citiesTableView.associateTableView = self.countiesTableView;
    
    //更新高度
    [self updateContentViewSize];
}


- (void)submit
{
    //如果需要省份
    if (!self.provinceUrl.isEmpty && !self.sel_province) {
        
        [self dismiss];  return;
    }
    
    //如果需要选择城市
    if (!self.cityUrl.isEmpty && !self.sel_city) {
        
        [self dismiss]; return;
    }
    
    //如果需要选择区/县
    if (!self.countyUrl.isEmpty && !self.sel_county) {
        
        [self dismiss]; return;
    }
    
    if ([self.delegate respondsToSelector:@selector(addressPickerView:province:city:county:)]) {
        
        [self.delegate addressPickerView:self province:self.sel_province city:self.sel_city county:self.sel_county];
    }
    
    [self dismiss];
}


#pragma mark - 省市标签

- (void)titleButtonsDidClick:(UIButton *)sender
{
    //进行切换
    if ([sender isEqual:self.provinceButton]) {//点击省
        
        [self.contentScrollView setRitl_contentOffSetX:0 animated:true];
        
    }else if([sender isEqual:self.cityButton]){//点击城市
        
        [self.contentScrollView setRitl_contentOffSetX:self.contentScrollView.ritl_width animated:true];
        
    }else if([sender isEqual:self.countyButton]){//点击区/县
        
        [self.contentScrollView setRitl_contentOffSetX:(self.contentScrollView.ritl_width * 2) animated:true];
    }
}

#pragma mark - setter

- (void)setRowHeight:(CGFloat)rowHeight
{
    if (rowHeight == _rowHeight) { return; }
    
    _rowHeight = rowHeight;
    [self updateContentViewSize];
}


- (void)setNumberOfRow:(NSInteger)numberOfRow
{
    if (numberOfRow == _numberOfRow) { return; }
    
    _numberOfRow = numberOfRow;
    [self updateContentViewSize];
}



- (void)updateContentViewSize
{
    self.contentView.ritl_height = _numberOfRow * _rowHeight + _headHeight;
    
    if (RITL_iPhoneX) {
        
        self.contentView.ritl_height += RITL_iPhoneXDistance;
    }
}


- (void)setProvinceUrl:(NSString *)provinceUrl
{
    if ([provinceUrl isEqualToString:_provinceUrl]) { return; }
    
    _provinceUrl = provinceUrl;
    self.provincesTableView.ad_requestKey = provinceUrl;
    [self updateContentScrollViewSize];
}


- (void)setCityUrl:(NSString *)cityUrl
{
    if ([cityUrl isEqualToString:_cityUrl]) { return; }
    
    _cityUrl = cityUrl;
    self.citiesTableView.ad_requestKey = cityUrl;
    [self updateContentScrollViewSize];
}


- (void)setCountyUrl:(NSString *)countyUrl
{
    if ([countyUrl isEqualToString:_countyUrl]) { return; }
    
    _countyUrl = countyUrl;
    self.countiesTableView.ad_requestKey = countyUrl;
    [self updateContentScrollViewSize];
}


- (void)updateContentScrollViewSize
{
    BOOL isExist = (self.provinceUrl && !self.provinceUrl.isEmpty);
    
    if (isExist) {//如果省存在
        
        self.contentScrollView.ritl_contentSizeWidth = self.ritl_width;
        
    }else { return; }
    
    isExist = (self.cityUrl && !self.countyUrl.isEmpty);
    
    if(isExist){//如果城市存在
        
        self.contentScrollView.ritl_contentSizeWidth = self.ritl_width * 2;
        
    }else { return; }
    
    if(self.countyUrl && !self.countyUrl.isEmpty){//如果区或者县存在
        
        self.contentScrollView.ritl_contentSizeWidth = self.ritl_width * 3;
    }
}

#pragma mark - Show or dimiss

- (void)show
{
    if (self.provinces.count == 0) {//只有不存在数据的时候，才开始请求数据
        //默认开始请求省的数据
        [self requestDataWithParamters:@{} tableView:self.provincesTableView];
    }
    
    //获得keyWindows
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];//追加
    
    //进行动画
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.contentView.ritl_originY = self.ritl_height - self.contentView.ritl_height;
        
    } completion:^(BOOL finished) {
        
        //
    }];
}


- (void)showInViewController:(UIViewController *)viewController
{
    self.visableViewController = viewController;
    [self show];
}


- (void)dismiss
{
    //获得keyWindows
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    if (![keyWindow.subviews containsObject:self]) {
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(addressPickerViewWillDismiss:)]) {
        
        [self.delegate addressPickerViewWillDismiss:self];
    }

    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        self.contentView.ritl_originPoint = CGPointMake(0,self.ritl_height);
        
    } completion:^(BOOL finished) {
        
        //重置
        self.provinceButton.text = self.cityButton.text = self.countyButton.text =@"请选择";
        self.cityButton.hidden = self.countyButton.hidden = true;
        self.sel_province = self.sel_city = self.sel_county = nil;//清空数据
        self.provincesTableView.ritl_contentOffSetY = self.citiesTableView.ritl_contentOffSetY = self.countiesTableView.ritl_contentOffSetY = 0;
        
        [self removeFromSuperview];
    }];
}


- (void)dealloc
{
    NSLog(@"[%@] is dealloc",NSStringFromClass(self.class));
}


#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray <id<RITLNetAddressPickerItem>> *items = [self valueForKey:tableView.ad_dataKey];
    
    return items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RITLNetAddressPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(RITLNetAddressPickerCell.class) forIndexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获得item
    id <RITLNetAddressPickerItem> item = [[self valueForKey:tableView.ad_dataKey] objectAtIndex:indexPath.row] ;
    
    RITLNetAddressPickerCell *pickerCell = (RITLNetAddressPickerCell *)cell;
    pickerCell.addressName.text = item.title;
    
}
#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获得数据源
    id<RITLNetAddressPickerItem>item = [[self valueForKey:tableView.ad_dataKey] objectAtIndex:indexPath.row];

    //获得关联标签
    ((UILabel *)[self valueForKey:tableView.ad_titleLabelKey]).text = item.title;
    
    //进行关联赋值
    [self setValue:item forKey:tableView.associateItemName];

    //进行数据的重置
    [self restoreTitleLabelWithSelectedTableView:tableView indexPath:indexPath];
}


/// 进行数据重置
- (void)restoreTitleLabelWithSelectedTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    UITableView *associateTableView = tableView.associateTableView;
    
    //滑动基数
    NSInteger scrollScale = [tableView isEqual:self.provincesTableView] ? 1 : 2;

    //获得选中的id
    NSString *identifier = [[self valueForKey:tableView.associateItemName] identifier];
    
    //获得Url
    NSString *url = associateTableView.ad_requestKey;
    
    //获得标签
    UILabel *nameLabel = [self valueForKey:associateTableView.ad_titleLabelKey];
    
    if (!url || url.isEmpty) {//如果url不存在
        nameLabel.hidden = true;//不显示关联子地区的标签
    }else {
        nameLabel.hidden = false;
        [self requestDataWithParamters:@{@"id":identifier} tableView:associateTableView];
        [self.contentScrollView setRitl_contentOffSetX:self.contentScrollView.ritl_width * scrollScale
                                              animated:true];
    }
}




#pragma mark - Networking

/// 请求数据
- (void)requestDataWithParamters:(NSDictionary *)parameters tableView:(UITableView *)tableView
{
    if (!tableView) { return; }
    
    NSString *url = tableView.ad_requestKey;
    NSString *dataKey = tableView.ad_dataKey;
    
    __block NSMutableString *paramterString = [NSMutableString string];
    
    //进行参数调整
    if (parameters && parameters.allKeys.count > 0) {
        
        [parameters.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [paramterString appendFormat:@"&%@=%@",obj,parameters[obj]];
        }];
        
        [paramterString deleteCharactersInRange:NSMakeRange(0, 1)];//进行切割
        
        if ([self.method isEqualToString:@"POST"]) {}
        else if([self.method isEqualToString:@"GET"]){
            [paramterString insertString:@"&" atIndex:0];//进行拼接
            url = [url stringByAppendingString:paramterString];
        }else {
            return;//不支持其他的请求方式
        }
    }
    
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url.ritl_url];
    request.HTTPMethod = self.method;
    
    //如果是POST
    if ([self.method isEqualToString:@"POST"]) {
        request.HTTPBody = [paramterString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // error
        if (error) {
            if ([self.dataSource respondsToSelector:@selector(addressPickerView:error:)]) {
                [self.dataSource addressPickerView:self error:error];
            }else if (self.requestErrorHandler) {
                self.requestErrorHandler(error);
            } return;
        }
        
        //数据处理
        dispatch_async(dispatch_get_main_queue(), ^{//主线程
            
            if ([self.dataSource respondsToSelector:@selector(addObserver:selector:name:object:)]) {
                [self setValue:[self.dataSource addressPickerView:self response:data] forKey:dataKey]; return;
            } else if (self.requestDataHandler) {
                [self setValue:self.requestDataHandler(data) forKey:dataKey]; return;
            }else{//按照默认方式
                
                NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                Class modelClass = RITLNetAddressPickerItem.class;
                
                if (self.customItemClass) { modelClass = self.customItemClass; }
                [self setValue:[NSArray yy_modelArrayWithClass:modelClass json:jsonData] forKey:dataKey];
            }
            
            [tableView reloadData];//刷新界面
        });
    }];
    
    [dataTask resume];
}


@end
