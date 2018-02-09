//
//  AppDelegate.h
//  Mileage
//
//  Created by Mehul Bhavani on 20/11/17.
//  Copyright © 2017 AppYogi Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

