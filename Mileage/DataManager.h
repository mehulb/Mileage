//
//  DataManager.h
//  Mileage
//
//  Created by Mehul Bhavani on 09/04/18.
//  Copyright © 2018 AppYogi Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ DataManagerCompletionBlock)(id result, NSError *error);

#define DATA_MANAGER [DataManager defaultManager]

@interface DataManager : NSObject
+ (instancetype)defaultManager;

- (void)syncWithCompletionBlock:(DataManagerCompletionBlock)block;

- (void)addEntry:(id)entry completionBlock:(DataManagerCompletionBlock)block;
- (void)updateEntry:(id)entry completionBlock:(DataManagerCompletionBlock)block;
- (void)removeEntry:(id)entry completionBlock:(DataManagerCompletionBlock)block;
@end
