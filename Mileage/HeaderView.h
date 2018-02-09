//
//  HeaderView.h
//  Mileage
//
//  Created by Mehul Bhavani on 09/12/17.
//  Copyright © 2017 AppYogi Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UIView

@property (nonatomic, strong) IBOutlet UILabel *distanceTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *distanceValueLabel;

@property (nonatomic, strong) IBOutlet UILabel *amountTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *amountValueLabel;

@property (nonatomic, strong) IBOutlet UILabel *fuelTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *fuelValueLabel;

@property (nonatomic, strong) IBOutlet UILabel *costTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *costValueLabel;
    
@property (nonatomic, strong) IBOutlet UIView *contentView;
@property (nonatomic, strong) IBOutlet UIView *separatorView;
    
@property (nonatomic, assign) BOOL showAverage;

- (void)setData:(NSDictionary *)data;
- (void)refreshData:(NSArray *)entries;
    
- (void)floatView:(BOOL)flag;

@end
