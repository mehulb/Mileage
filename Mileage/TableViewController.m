//
//  TableViewController.m
//  Mileage
//
//  Created by Mehul Bhavani on 20/11/17.
//  Copyright © 2017 AppYogi Software. All rights reserved.
//

#import "TableViewController.h"
#import "FormViewController.h"
#import "AppDelegate.h"
#import "TableViewCell.h"
#import "HeaderView.h"

@interface TableViewController ()
@end

@implementation TableViewController
{
    NSMutableArray *entries;
    UISegmentedControl *segmentedControl;
    
    IBOutlet HeaderView *headerView;
    IBOutlet UIView *footerView;
    IBOutlet UIButton *addButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Mileage";
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBarButtonItem_Tapped:)];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCell class]) bundle:nil] forCellReuseIdentifier:@"CellID"];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Average", @"Total"]];
    segmentedControl.tintColor = UIColor.darkGrayColor;
    segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segmentedControl;
    [segmentedControl addTarget:self action:@selector(segmentedControlSelectedItem_Changed) forControlEvents:UIControlEventValueChanged];
    
    [headerView setData:nil];
    
    addButton.backgroundColor = UIColor.darkGrayColor;
    addButton.layer.cornerRadius = CGRectGetHeight(addButton.frame)/2;
    addButton.layer.shadowColor = UIColor.blackColor.CGColor;
    addButton.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    addButton.layer.shadowRadius = 8.0;
    addButton.layer.shadowOpacity = 1.0;
    
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchData];
}

- (void)segmentedControlSelectedItem_Changed {
    headerView.showAverage = (segmentedControl.selectedSegmentIndex == 0);
    [self fetchData];
}

- (void)fetchData {
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FillingEntry"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    entries = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [headerView refreshData:entries];
    
    [self.tableView reloadData];
}

- (void)addBarButtonItem_Tapped:(id)sender {
    
}
- (IBAction)addButton_Clicked:(id)sender {
    FormViewController *formController = [[FormViewController alloc] init];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:formController];
    [self presentViewController:controller animated:YES completion:nil];
}
- (IBAction)refreshControl_ValueChanged:(UIRefreshControl *)sender {
    sender.attributedTitle = [[NSAttributedString alloc] initWithString:@"syncing..."];
    [[DataManager defaultManager] syncWithCompletionBlock:^(id result, NSError *error) {
        [sender endRefreshing];
        [self.tableView reloadData];
        sender.attributedTitle = [[NSAttributedString alloc] initWithString:@"pull and release to sync"];
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return entries.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(headerView.frame);
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGRectGetHeight(footerView.frame);
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    
    NSManagedObject *entry = entries[indexPath.row];
    
    cell.dateLabel.text = [self formattedDate:(NSDate *)[entry valueForKey:@"date"]];
    
    if([entry valueForKey:@"station"]) {
        cell.stationLabel.text = [NSString stringWithFormat:@"  %@  ", [entry valueForKey:@"station"]];
        cell.stationLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        cell.stationLabel.layer.cornerRadius = CGRectGetHeight(cell.stationLabel.frame)/2;
        cell.stationLabel.clipsToBounds = YES;
    }
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f KM", [[entry valueForKey:@"odometer"] floatValue]];
    if(indexPath.row > 0) {
        NSManagedObject *prevEntry = entries[indexPath.row-1];
        CGFloat currOdo = [[entry valueForKey:@"odometer"] floatValue];
        CGFloat lastOdo = [[prevEntry valueForKey:@"odometer"] floatValue];
        CGFloat distance = lastOdo-currOdo;
        cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f KM", distance];
        cell.mileageLabel.text = [NSString stringWithFormat:@"  %.1f KM/L  ", distance / [[entry valueForKey:@"volume"] floatValue]];
    }
    else {
        cell.distanceLabel.text = @"0.00 KM";
        cell.mileageLabel.text = [NSString stringWithFormat:@"  %.1f KM/L  ", 0.00];
    }
    
    cell.amountLabel.text = [NSString stringWithFormat:@"₹ %.2f", [[entry valueForKey:@"amount"] floatValue]];
    cell.priceLabel.text = [NSString stringWithFormat:@"₹ %.2f", [[entry valueForKey:@"rate"] floatValue]];
    
    cell.volumeLabel.text = [NSString stringWithFormat:@"  %.2f L  ", [[entry valueForKey:@"volume"] floatValue]];
    cell.volumeLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    cell.volumeLabel.layer.cornerRadius = CGRectGetHeight(cell.volumeLabel.frame)/2;
    cell.volumeLabel.clipsToBounds = YES;
    
    cell.mileageLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    cell.mileageLabel.layer.cornerRadius = CGRectGetHeight(cell.mileageLabel.frame)/2;
    cell.mileageLabel.clipsToBounds = YES;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FormViewController *formController = [[FormViewController alloc] initWithObject:entries[indexPath.row]];
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:formController];
    [self presentViewController:controller animated:YES completion:nil];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *entry = entries[indexPath.row];
        NSManagedObjectContext *context = [self managedObjectContext];
        [context deleteObject:entry];
        [entries removeObject:entry];
        
        NSError *error = nil;
            // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
        [self fetchData];
    }
}
    
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%@", NSStringFromCGPoint(scrollView.contentOffset));
    if(scrollView.contentOffset.y > -64) {
        [headerView floatView:YES];
    }
    else {
        [headerView floatView:NO];
    }
}

#pragma mark -
- (NSManagedObjectContext *)managedObjectContext {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.persistentContainer.viewContext;
}
- (NSString *)formattedDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyy";
    return [formatter stringFromDate:date];
}

@end
