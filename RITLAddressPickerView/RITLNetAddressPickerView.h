//
//  RITLNetAddressPickerView.h
//  NongWanCloud
//
//  Created by YueWen on 2018/4/17.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RITLNetAddressPickerView;


/// 作为数据源必须实现的协议
@protocol RITLNetAddressPickerItem <NSObject>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *title;

@end



@protocol RITLNetAddressPickerViewDelegate<NSObject>

@optional


/// 获取的数据
- (void)addressPickerView:(RITLNetAddressPickerView *)pickerView
                 province:(nullable id<RITLNetAddressPickerItem>)province
                     city:(nullable id<RITLNetAddressPickerItem>)city
                   county:(nullable id<RITLNetAddressPickerItem>)county;


- (void)addressPickerViewWillDismiss:(RITLNetAddressPickerView *)pickerView;

@end


@protocol RITLNetAddressPickerViewDataSource<NSObject>

@optional

/// 返回数据的自定义返回
- (NSArray <id<RITLNetAddressPickerItem>>*)addressPickerView:(RITLNetAddressPickerView *)pickerView response:(id)responseObject;


/// 请求出现错误
- (void)addressPickerView:(RITLNetAddressPickerView *)pickerView error:(NSError *)error;

@end

/// 网络请求的地址选择,不支持本地数据，依赖YYModel,AFNetworking
@interface RITLNetAddressPickerView : UIView

/// 默认为GET(POST)
@property (nonatomic, copy) NSString *method;

/// key
@property (nonatomic, strong, nullable) id key;

@property (nonatomic, weak, nullable)id<RITLNetAddressPickerViewDelegate>delegate;
/// 数据源
@property (nonatomic, weak, nullable)id<RITLNetAddressPickerViewDataSource>dataSource;

#pragma mark - 数据源

/// 身份的url
@property (nonatomic, copy, nullable)NSString *provinceUrl;
/// 城市的url,赋值前保证provinceUrl
@property (nonatomic, copy, nullable)NSString *cityUrl;
/// 县/区的url,赋值前保证cityUrl
@property (nonatomic, copy, nullable)NSString *countyUrl;


/// 所有的省份
@property (nonatomic, copy, readonly)NSArray<id<RITLNetAddressPickerItem>> *provinces;
/// 所有的城市
@property (nonatomic, copy, readonly)NSArray<id<RITLNetAddressPickerItem>> *cities;
/// 所有的县/区
@property (nonatomic, copy, readonly)NSArray<id<RITLNetAddressPickerItem>> *counties;

#pragma mark - 自定义

/// 自定义的数据对象
@property (nonatomic, strong, nullable) Class<RITLNetAddressPickerItem> customItemClass;

/// 
@property (nonatomic, assign) CGFloat rowHeight;  // 默认 44
@property (nonatomic, assign) NSInteger numberOfRow;  // 默认7


#pragma mark - 数据处理

/// 如果存在自己的数据结构,使用该方法返回数据,网络请求的数据进行自定义处理的block
@property (nonatomic, copy, nullable)NSArray<id<RITLNetAddressPickerItem>>*(^requestDataHandler)(_Nullable id responseObject);

/// 网络请求出现问题的block
@property (nonatomic, copy, nullable)void(^requestErrorHandler)(NSError *error);

#pragma mark - show

- (void)showInViewController:(UIViewController *)viewController;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
