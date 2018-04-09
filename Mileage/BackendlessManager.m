//
//  BackendlessManager.m
//  Mileage
//
//  Created by Mehul Bhavani on 22/02/18.
//  Copyright © 2018 AppYogi Software. All rights reserved.
//

#import "BackendlessManager.h"
#import "Backendless.h"
#import "AppDelegate.h"

#define BACKENDLESS [Backendless sharedInstance]

@implementation BackendlessManager
+ (instancetype)sharedManager {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
        NSLog(@"BackendlessManager Ready!");
    });
    return sharedInstance;
}

- (instancetype)init {
    if([super init]) {
        [BACKENDLESS initApp:@"8407A8CC-0614-926B-FFC3-8FF4E04A0F00" APIKey:@"0B45EF40-CCF2-F4A5-FF6B-65D75B1A5C00"];
        
//        [BACKENDLESS.data describe:@"Fillings" response:^(NSArray<ObjectProperty *> *schema) {
//            NSLog(@"%@", schema);
//        } error:^(Fault *fault) {
//           NSLog(@"%@", fault.description);
//        }];
    }
    return self;
}

- (void)syncWithCompletionBlock:(BackendlessCompletionBlock)block {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = delegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FillingEntry"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    NSArray *entries = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSError *syncError = nil;
        for(NSManagedObject *entry in entries) {
            NSDictionary *dict = @{
                                   @"amount":[entry valueForKey:@"amount"],
                                   @"filling_date":[entry valueForKey:@"date"],
                                   @"odometer":[entry valueForKey:@"odometer"],
                                   @"rate":[entry valueForKey:@"rate"],
                                   @"station":[entry valueForKey:@"station"],
                                   @"volume":[entry valueForKey:@"volume"],
                                   };
            [[BACKENDLESS.data ofTable:@"Fillings"] save:dict response:^(id result) {
                NSLog(@"%@", result);
            } error:^(Fault *fault) {
                NSLog(@"%@", fault.description);
                syncError = [NSError errorWithDomain:NSCocoaErrorDomain code:400 userInfo:@{NSLocalizedDescriptionKey:fault.message,NSLocalizedFailureReasonErrorKey:fault.description}];
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(block) {
                block(nil, syncError);
            }
        });
    });
}

- (void)addEntry:(id)entry completionBlock:(BackendlessCompletionBlock)block {
    
}
- (void)updateEntry:(id)entry completionBlock:(BackendlessCompletionBlock)block {
    
}
- (void)removeEntry:(id)entry completionBlock:(BackendlessCompletionBlock)block {
    
}
@end
