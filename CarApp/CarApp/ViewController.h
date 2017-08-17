//
//  ViewController.h
//  CarApp
//
//  Created by Muthu Rajan on 07/04/15.
//  Copyright (c) 2015 Muthu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *carDateArray;
    NSMutableArray *appCarsArray;
    NSMutableArray *tempCarsArray;
    
    IBOutlet UICollectionView *carCollectionView;
}

@property (nonatomic, strong) NSArray *carsArray;

@end

