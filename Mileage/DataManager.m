//
//  DataManager.m
//  Mileage
//
//  Created by Mehul Bhavani on 09/04/18.
//  Copyright © 2018 AppYogi Software. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"
@import Firebase;

@interface NSManagedObject (ToDictionary)
- (NSDictionary *)dictionaryRepresentation;
@end

@implementation NSManagedObject (ToDictionary)
- (NSDictionary *)dictionaryRepresentation {
    return @{
             @"amount":[self valueForKey:@"amount"],
             @"filling_date":[self valueForKey:@"date"],
             @"odometer":[self valueForKey:@"odometer"],
             @"rate":[self valueForKey:@"rate"],
             @"station":[self valueForKey:@"station"],
             @"volume":[self valueForKey:@"volume"],
             };
}
@end

@implementation DataManager
{
    
}

+ (instancetype)defaultManager {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
        NSLog(@"DataManager Ready!");
    });
    return sharedInstance;
}

- (instancetype)init {
    if((self = [super init])) {
        [FIRApp configure];
    }
    return self;
}

- (void)syncWithCompletionBlock:(DataManagerCompletionBlock)block {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = delegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FillingEntry"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    NSArray *entries = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    FIRWriteBatch *batch = [FIRFirestore firestore].batch;
    for(NSManagedObject *entry in entries) {
        if(![entry valueForKey:@"fillingId"]) {
            NSLog(@"FILLING ID missing");
            continue;
        }
        NSDictionary *dict = [entry dictionaryRepresentation];
        if(dict) {
            [batch setData:dict forDocument:[[[FIRFirestore firestore] collectionWithPath:@"fillings"] documentWithPath:[entry valueForKey:@"fillingId"]]];
        }
    }
    [batch commitWithCompletion:^(NSError * _Nullable error) {
        if(error) NSLog(@"%@", error);
        if(block) {
            block(nil, error);
        }
    }];
}
- (void)addEntry:(id)entry completionBlock:(DataManagerCompletionBlock)block {
    NSDictionary *dict = [entry dictionaryRepresentation];
    [[[[FIRFirestore firestore] collectionWithPath:@"fillings"] documentWithPath:[entry valueForKey:@"fillingId"]] setData:dict completion:^(NSError * _Nullable error) {
        if(error) NSLog(@"%@", error);
        if(block) {
            block(nil, error);
        }
    }];
}
- (void)updateEntry:(id)entry completionBlock:(DataManagerCompletionBlock)block {
    NSDictionary *dict = [entry dictionaryRepresentation];
    [[[[FIRFirestore firestore] collectionWithPath:@"fillings"] documentWithPath:[entry valueForKey:@"fillingId"]] setData:dict completion:^(NSError * _Nullable error) {
        if(error) NSLog(@"%@", error);
        if(block) {
            block(nil, error);
        }
    }];
}
- (void)removeEntry:(id)entry completionBlock:(DataManagerCompletionBlock)block {
    [[[[FIRFirestore firestore] collectionWithPath:@"fillings"] documentWithPath:[entry valueForKey:@"fillingId"]] deleteDocumentWithCompletion:^(NSError * _Nullable error) {
        if(error) NSLog(@"%@", error);
        if(block) {
            block(nil, error);
        }
    }];
}

@end
