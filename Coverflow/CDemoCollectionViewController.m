//
//  CDemoCollectionViewController.m
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CDemoCollectionViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CDemoCollectionViewCell.h"

@interface CDemoCollectionViewController ()
@property (readwrite, nonatomic, assign) NSInteger cellCount;
@end

@implementation CDemoCollectionViewController

- (void)viewDidLoad
	{
	[super viewDidLoad];

	self.cellCount = 10;
	}

- (void)viewDidAppear:(BOOL)animated
	{
	CALayer *theLayer = [CALayer layer];
	theLayer.borderWidth = 1.0;
	theLayer.borderColor = [UIColor whiteColor].CGColor;
	theLayer.bounds = (CGRect){ .size = { 100, 100 } };
	theLayer.position = (CGPoint){ CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) };
	[self.view.layer addSublayer:theLayer];
	}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
	{
	return(self.cellCount);
	}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
	{
	CDemoCollectionViewCell *theCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DEMO_CELL" forIndexPath:indexPath];
	theCell.backgroundColor = [UIColor colorWithHue:(float)indexPath.row / (float)self.cellCount saturation:0.333 brightness:1.0 alpha:1.0];

	return(theCell);
	}

@end
