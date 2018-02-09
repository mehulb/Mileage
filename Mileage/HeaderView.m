//
//  HeaderView.m
//  Mileage
//
//  Created by Mehul Bhavani on 09/12/17.
//  Copyright © 2017 AppYogi Software. All rights reserved.
//

#import "HeaderView.h"
#import <CoreData/CoreData.h>

@implementation HeaderView
{
    BOOL isFloating;
}
    
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _showAverage = YES;
    
    _contentView.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    _contentView.layer.cornerRadius = 8.0;
    _contentView.layer.shadowColor = UIColor.blackColor.CGColor;
    _contentView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    _contentView.layer.shadowRadius = 8.0;
    //_contentView.layer.shadowOpacity = 0.5;
    
    _distanceTitleLabel.text = [NSString stringWithFormat:@"  Average Distance  "];
    _distanceTitleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    _distanceTitleLabel.layer.cornerRadius = CGRectGetHeight(_distanceTitleLabel.frame)/2;
    _distanceTitleLabel.clipsToBounds = YES;
    
    _amountTitleLabel.text = [NSString stringWithFormat:@"  Average Amount  "];
    _amountTitleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    _amountTitleLabel.layer.cornerRadius = CGRectGetHeight(_amountTitleLabel.frame)/2;
    _amountTitleLabel.clipsToBounds = YES;
    
    _fuelTitleLabel.text = [NSString stringWithFormat:@"  Average Fuel  "];
    _fuelTitleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    _fuelTitleLabel.layer.cornerRadius = CGRectGetHeight(_fuelTitleLabel.frame)/2;
    _fuelTitleLabel.clipsToBounds = YES;
    
    _costTitleLabel.text = [NSString stringWithFormat:@"  Per KM  "];
    _costTitleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    _costTitleLabel.layer.cornerRadius = CGRectGetHeight(_costTitleLabel.frame)/2;
    _costTitleLabel.clipsToBounds = YES;
    
    _separatorView.hidden = YES;
    
}

- (void)setData:(NSDictionary *)data {
    if(data) {
        _distanceValueLabel.text = [NSString stringWithFormat:@"%.2f KM", [data[@"distance"] floatValue]];
        _amountValueLabel.text = [NSString stringWithFormat:@"₹ %.2f", [data[@"amount"] floatValue]];
        _fuelValueLabel.text = [NSString stringWithFormat:@"%.2f L", [data[@"volume"] floatValue]];
        
        float cost = [data[@"distance"] floatValue] / [data[@"volume"] floatValue];
        _costValueLabel.text = [NSString stringWithFormat:@"%.2f KM/L", cost];
    }
    else {
        _distanceValueLabel.text = @"0.00 KM";
        _amountValueLabel.text = @"₹ 0.00";
        _fuelValueLabel.text = @"0.00 L";
        _costValueLabel.text = @"0.00 KM/L";
    }
}

- (void)refreshData:(NSArray *)entries {    
    NSManagedObject *firstEntry = entries.lastObject;
    NSManagedObject *lastEntry = entries.firstObject;
    
    NSDictionary *dict = nil;
    if(_showAverage) {
        _distanceTitleLabel.text = [NSString stringWithFormat:@"  Average Distance  "];
        _amountTitleLabel.text = [NSString stringWithFormat:@"  Average Amount  "];
        _fuelTitleLabel.text = [NSString stringWithFormat:@"  Average Fuel  "];
        _costTitleLabel.text = [NSString stringWithFormat:@"  Mileage  "];
        dict = @{
                 @"distance":@(([[lastEntry valueForKey:@"odometer"] floatValue] - [[firstEntry valueForKey:@"odometer"] floatValue])/(entries.count-1)),
                 @"amount":@(([[entries valueForKeyPath:@"@sum.amount"] floatValue])/entries.count),
                 @"volume":@(([[entries valueForKeyPath:@"@sum.volume"] floatValue])/entries.count),
                 @"cost":@(0.00)
                 };
    }
    else {
        _distanceTitleLabel.text = [NSString stringWithFormat:@"  Total Distance  "];
        _amountTitleLabel.text = [NSString stringWithFormat:@"  Total Amount  "];
        _fuelTitleLabel.text = [NSString stringWithFormat:@"  Total Fuel  "];
        _costTitleLabel.text = [NSString stringWithFormat:@"  Per KM  "];
        dict = @{
                 @"distance":@([[lastEntry valueForKey:@"odometer"] floatValue] - [[firstEntry valueForKey:@"odometer"] floatValue]),
                 @"amount":@([[entries valueForKeyPath:@"@sum.amount"] floatValue]),
                 @"volume":@([[entries valueForKeyPath:@"@sum.volume"] floatValue]),
                 @"cost":@(0.00)
                 };
    }
    
    
    [self setData:dict];
}

- (void)floatView:(BOOL)flag {
    if(isFloating != flag) {
        isFloating = flag;
        if(flag) {
            [UIView animateWithDuration:0.5 animations:^{
                _contentView.layer.shadowOpacity = 0.5;
                _contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
                //_separatorView.alpha = 0.0;
            }];
        }
        else {
            [UIView animateWithDuration:0.5 animations:^{
                _contentView.layer.shadowOpacity = 0.0;
                _contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                //_separatorView.alpha = 1.0;
            }];
        }
    }
}

@end
