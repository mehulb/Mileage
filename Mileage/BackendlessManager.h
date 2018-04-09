//
//  BackendlessManager.h
//  Mileage
//
//  Created by Mehul Bhavani on 22/02/18.
//  Copyright © 2018 AppYogi Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ BackendlessCompletionBlock)(id result, NSError *error);

@interface BackendlessManager : NSObject
+ (instancetype)sharedManager;

- (void)syncWithCompletionBlock:(BackendlessCompletionBlock)block;

- (void)addEntry:(id)entry completionBlock:(BackendlessCompletionBlock)block;
- (void)updateEntry:(id)entry completionBlock:(BackendlessCompletionBlock)block;
- (void)removeEntry:(id)entry completionBlock:(BackendlessCompletionBlock)block;

@end
