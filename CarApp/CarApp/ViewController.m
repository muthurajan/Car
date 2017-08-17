//
//  ViewController.m
//  CarApp
//
//  Created by Muthu Rajan on 07/04/15.
//  Copyright (c) 2015 Muthu. All rights reserved.
//

#import "ViewController.h"
#import "CarCollectionHeaderView.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize carsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    appCarsArray = [[NSMutableArray alloc] init];
    carDateArray = [[NSMutableArray alloc] init];
    
    [self getAllCars];
}


- (void)getAllCars
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"cars.json" ofType:nil];
    NSData  *jsonData  = [NSData dataWithContentsOfFile:jsonPath];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    NSArray *carsList   = [jsonDict objectForKey:@"cars"];
    self.carsArray = carsList;

    if(tempCarsArray == nil)
        tempCarsArray  = [[NSMutableArray alloc] initWithArray:carsList];
    
    [self getCarFilterDate];
    
    for(NSString *createDate in carDateArray)
    {
        NSMutableArray *filterCarList =  [self getVehiclesByDate:createDate];
        if([filterCarList count] > 0)
        {
            NSDictionary *carDateDict = [NSDictionary dictionaryWithObject:filterCarList forKey:createDate];
            [appCarsArray addObject:carDateDict];
        }
    }
    
    if([appCarsArray count] > 0)
        [carCollectionView reloadData];
        
    
    NSLog(@"Final cars ==>%@",appCarsArray);
}

- (void)getCarFilterDate
{
    if([carDateArray count] > 0)
        [carDateArray removeAllObjects];
    
    for(NSDictionary *carsDict in self.carsArray)
    {
        NSString *createDate = [carsDict objectForKey:@"create_date"];
        NSArray *dateList = [createDate componentsSeparatedByString:@" "];
        if([dateList count] > 0)
        {
            NSString *carDate = [dateList objectAtIndex:0];
            
            if(![carDateArray containsObject:carDate])
            {
                [carDateArray addObject:carDate];
            }
        }
    }
    
    if([carDateArray count] > 0)
        [self sortCarFilterDate];
}

-(void)sortCarFilterDate
{
    NSMutableArray *tempDateArray = [[NSMutableArray alloc] init];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d/M/yyyy"];
    
    for(NSString *carDate in carDateArray)
    {
        NSDate *filterDate = [dateFormat dateFromString:carDate];
        [tempDateArray addObject:filterDate];
    }
    
    //sort dates
    [tempDateArray sortUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2)
     {
         return [date1 compare:date2];
     }];

    [carDateArray removeAllObjects];
    for(NSDate *carDate in tempDateArray)
    {
        NSString *finalDate =  [dateFormat stringFromDate:carDate];
        [carDateArray addObject:finalDate];
    }
    
    NSLog(@"Final Dates array ==>%@",carDateArray);
    
}

- (NSString *)getCurrentDate:(NSString *)requestDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];

//    NSString *todayDate = [dateFormat stringFromDate:[NSDate date]];
//    NSDate *currentDate = [dateFormat dateFromString:todayDate];

    NSString *dayString;
    NSDate *newDate = [dateFormat dateFromString:requestDate];
    if([[NSCalendar currentCalendar] isDateInToday:newDate])
        dayString = @"Today";
    else if([[NSCalendar currentCalendar] isDateInTomorrow:newDate])
        dayString = @"Tomorrow";
    else if([[NSCalendar currentCalendar] isDateInYesterday:newDate])
        dayString = @"Yesterday";
    else
        dayString = @"";
    
 //   NSString *todayString = ([[NSCalendar currentCalendar] isDateInToday:newDate]) ? @"Today" : @"";
    
    return dayString;
}

- (NSMutableArray *)getVehiclesByDate:(NSString *)reqCreateDate
{
    NSMutableArray *carList = [[NSMutableArray alloc] init];
    
    for(NSDictionary *carsDict in tempCarsArray)
    {
        NSString *createDate = [carsDict objectForKey:@"create_date"];
        NSArray *dateList = [createDate componentsSeparatedByString:@" "];
        if([dateList count] > 0)
        {
            if([[dateList objectAtIndex:0] isEqualToString:reqCreateDate])
            {
                [carList addObject:carsDict];
            }
        }
    }
    
    //Delete the cars from temparoy array to enumerate fast.
    for(NSDictionary *carsDict in carList)
    {
        if([tempCarsArray containsObject:carsDict])
            [tempCarsArray removeObject:carsDict];
    }
    
    
    return carList;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return [appCarsArray count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    NSDictionary *carDict       =   [appCarsArray objectAtIndex:section];
    NSArray *filterCarsArray    =   [carDict objectForKey:[carDateArray objectAtIndex:section]];
    
    return [filterCarsArray count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionHeader)
    {
        CarCollectionHeaderView *headerView =    [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        [headerView.headerImageview setImage:[UIImage imageNamed:@"header_banner.png"]];
        
        NSString *carDateGroup = [carDateArray objectAtIndex:indexPath.section];
        NSString *todayDate =   [self getCurrentDate:carDateGroup];
        [headerView.headerLabel setText:([todayDate length] > 0) ? todayDate : carDateGroup];;
        
        reusableView = headerView;
    }
    
//    if(kind == UICollectionElementKindSectionFooter)
//    {
//        reusableView =    [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
//    }
    
    return reusableView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CarCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UIImageView *imageView  = (UIImageView *) [cell viewWithTag:100];
    UILabel     *carLabel   = (UILabel *)     [cell viewWithTag:101];
    
    if([appCarsArray count] > 0)
    {
        NSDictionary *filterCarDict =   [appCarsArray objectAtIndex:indexPath.section];
        NSArray *filterCarsArray    =   [filterCarDict objectForKey:[carDateArray objectAtIndex:indexPath.section]];
        
        NSDictionary *carsDict  =   [filterCarsArray objectAtIndex:indexPath.row];
        NSString *carImageName  =   [carsDict objectForKey:@"car_image"];
        NSString *carName       =   [carsDict objectForKey:@"car_name"];

        [imageView setImage:[UIImage imageNamed:carImageName]];
        [carLabel setText:carName];
    }
    
    return cell;
}

@end
