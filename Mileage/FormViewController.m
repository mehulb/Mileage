//
//  FormViewController.m
//  Mileage
//
//  Created by Mehul Bhavani on 25/11/17.
//  Copyright © 2017 AppYogi Software. All rights reserved.
//

#import "FormViewController.h"
#import "XLForm.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@interface NSObject (NotNull)
- (BOOL)isNull;
- (BOOL)isNotNull;
@end
@implementation NSObject (NotNull)
- (BOOL)isNull {
    return ![self isNotNull];
}
- (BOOL)isNotNull
{
    if(!self || self == nil || [self isEqual:[NSNull null]])
        return NO;
    return YES;
}
@end

@interface FormViewController () 

@end

@implementation FormViewController
{
    NSManagedObject *_object;
}

- (NSManagedObjectContext *)managedObjectContext {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.persistentContainer.viewContext;
}

- (instancetype)init {
    if(self = [super init]) {
        [self initializeForm];
    }
    return self;
}
- (instancetype)initWithObject:(id)object {
    if(self = [super init]) {
        _object = (NSManagedObject *)object;
        [self initializeForm];
    }
    return self;
}
- (void)initializeForm {
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Add Event"];
    
    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // filling date
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"date" rowType:XLFormRowDescriptorTypeDateInline title:@"Date"];
    if(_object) {
        row.value = [_object valueForKey:@"date"];
    }
    else {
        row.value = [NSDate date];
    }
    [section addFormRow:row];
    
    // amount
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"amount" rowType:XLFormRowDescriptorTypeDecimal title:@"Amount"];
    [row.cellConfigAtConfigure setObject:@"0.00" forKey:@"textField.placeholder"];
    if(_object) row.value = [_object valueForKey:@"amount"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // odometer reading
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"odometer" rowType:XLFormRowDescriptorTypeDecimal title:@"Odometer Reading"];
    [row.cellConfigAtConfigure setObject:@"00000.00" forKey:@"textField.placeholder"];
    if(_object) row.value = [_object valueForKey:@"odometer"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // fuel volume
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"volume" rowType:XLFormRowDescriptorTypeDecimal title:@"Fuel Volume"];
    [row.cellConfigAtConfigure setObject:@"0.00" forKey:@"textField.placeholder"];
    if(_object) row.value = [_object valueForKey:@"volume"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // fuel rate
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"rate" rowType:XLFormRowDescriptorTypeDecimal title:@"Fuel Rate"];
    [row.cellConfigAtConfigure setObject:@"00.00" forKey:@"textField.placeholder"];
    if(_object) row.value = [_object valueForKey:@"rate"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    // filling station
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"station" rowType:XLFormRowDescriptorTypeText title:@"Filling Station"];
    [row.cellConfigAtConfigure setObject:@"station" forKey:@"textField.placeholder"];
    if(_object) row.value = [_object valueForKey:@"station"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    [section addFormRow:row];
    
    self.form = form;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBarButtonItem_Tapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBarButtonItem_Tapped:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)cancelBarButtonItem_Tapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)doneBarButtonItem_Tapped:(id)sender {
    NSLog(@"%@", self.formValues);
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSDate *date        = self.formValues[@"date"];
    NSNumber *amount    = self.formValues[@"amount"];
    NSNumber *odometer  = self.formValues[@"odometer"];
    NSNumber *volume    = self.formValues[@"volume"];
    NSNumber *rate      = self.formValues[@"rate"];
    NSString *station   = self.formValues[@"station"];
    
    NSManagedObject *newEntry = nil;
    if(_object) {
        newEntry = _object;
    }
    else {
        newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"FillingEntry" inManagedObjectContext:context];
    }
    
    if(volume.isNull) {
        volume = [self calculateFuelVolume];
    }
    if(rate.isNull) {
        rate = [self calculateFuelRate];
    }
    if(amount.isNull) {
        amount = [self calculateAmount];
    }
    
    [newEntry setValue:date                                 forKey:@"date"];
    [newEntry setValue:amount.isNotNull?amount:@(0.00)      forKey:@"amount"];
    [newEntry setValue:odometer.isNotNull?odometer:@(0.00)  forKey:@"odometer"];
    [newEntry setValue:volume.isNotNull?volume:@(0.00)      forKey:@"volume"];
    [newEntry setValue:rate.isNotNull?rate:@(0.00)          forKey:@"rate"];
    [newEntry setValue:station.isNotNull?station:@"--"      forKey:@"station"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSNumber *)calculateFuelVolume {
    NSNumber *amount    = self.formValues[@"amount"];
    NSNumber *rate      = self.formValues[@"rate"];
    NSNumber *volume    = @(0.00);

    if(amount.isNotNull && rate.isNotNull) {
        volume = @(amount.floatValue / rate.floatValue);
    }
    
    return volume;
}
- (NSNumber *)calculateFuelRate {
    NSNumber *amount    = self.formValues[@"amount"];
    NSNumber *volume    = self.formValues[@"volume"];
    NSNumber *rate      = @(0.00);
    
    if(amount.isNotNull && volume.isNotNull) {
        rate = @(amount.floatValue / volume.floatValue);
    }
    
    return rate;
}
- (NSNumber *)calculateAmount {
    NSNumber *rate      = self.formValues[@"rate"];
    NSNumber *volume    = self.formValues[@"volume"];
    NSNumber *amount      = @(0.00);
    
    if(rate.isNotNull && volume.isNotNull) {
        amount = @(rate.floatValue * volume.floatValue);
    }
    
    return amount;
}

@end
