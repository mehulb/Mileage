//
//  TableViewCell.h
//  Mileage
//
//  Created by Mehul Bhavani on 05/12/17.
//  Copyright © 2017 AppYogi Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *amountLabel;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *volumeLabel;
@property (nonatomic, strong) IBOutlet UILabel *stationLabel;

@property (nonatomic, strong) IBOutlet UILabel *mileageLabel;

@end
