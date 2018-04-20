//
//  RITLNetAddressPickerCell.m
//  RITLNetAddressPickerView
//
//  Created by YueWen on 2018/4/20.
//  Copyright © 2018年 YueWen. All rights reserved.
//

#import "RITLNetAddressPickerCell.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry.h>
#else
#import "Masonry.h"
#endif

@implementation RITLNetAddressPickerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initUI];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self initUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - init

- (void)initUI {

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.bounds.size.height - 1, [UIScreen mainScreen].bounds.size.width, 1)];
    line.backgroundColor = [UIColor colorWithWhite:242.0/255.0 alpha:1.0];
    
    
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:242.0/255.0 alpha:1.0];
    
    self.addressName = ({
        
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithWhite:51.0/255.0 alpha:1.0];
        
        label;
    });
    
    [self.contentView addSubview:self.addressName];
    
    [self.addressName mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.offset(0);
        make.left.offset(10);
    }];
}




@end
