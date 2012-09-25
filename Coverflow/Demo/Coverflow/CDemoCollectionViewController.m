//
//  CDemoCollectionViewController.m
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CDemoCollectionViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "CDemoCollectionViewCell.h"
#import "UIImage+Reflections.h"
#import "CCCoverflowTitleView.h"

@interface CDemoCollectionViewController ()
@property (readwrite, nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (readwrite, nonatomic, assign) NSInteger cellCount;
@property (readwrite, nonatomic, strong) NSArray *assets;
@end

@implementation CDemoCollectionViewController

- (void)viewDidLoad
	{
	[super viewDidLoad];

	[self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CCCoverflowTitleView class]) bundle:NULL] forSupplementaryViewOfKind:@"title" withReuseIdentifier:@"title"];

	self.cellCount = 10;

#if 1
	NSMutableArray *theAssets = [NSMutableArray array];
	NSURL *theURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Images"];
	NSEnumerator *theEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:theURL includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
	for (theURL in theEnumerator)
		{
		if ([[theURL pathExtension] isEqualToString:@"jpg"])
			{
			[theAssets addObject:theURL];
			}
		}
	self.assets = theAssets;
	self.cellCount = self.assets.count;
#else
	// Don't do this.
	self.assetsLibrary = [[ALAssetsLibrary alloc] init];
	[self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop1) {
		NSMutableArray *theAssets = [NSMutableArray array];
		[group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop2) {
			if (theAssets.count > 100)
				{
				*stop2 = YES;
				}
			if (asset)
				{
				[theAssets addObject:asset];
				}
			}];

		self.assets = theAssets;
		if (self.assets.count > 0)
			{
			dispatch_async(dispatch_get_main_queue(), ^{
				self.cellCount = self.assets.count;
				[self.collectionView reloadData];
				});
			}

		*stop1 = YES;
		} failureBlock:NULL];
#endif
	}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
	{
	return(self.cellCount);
	}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
	{
	CDemoCollectionViewCell *theCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DEMO_CELL" forIndexPath:indexPath];

	if (theCell.gestureRecognizers.count == 0)
		{
		[theCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
		}

	theCell.backgroundColor = [UIColor colorWithHue:(float)indexPath.row / (float)self.cellCount saturation:0.333 brightness:1.0 alpha:1.0];

	if (indexPath.row < self.assets.count)
		{
#if 1
		NSURL *theURL = [self.assets objectAtIndex:indexPath.row];
		UIImage *theImage = [UIImage imageWithContentsOfFile:theURL.path];
		theCell.imageView.image = theImage;
		theCell.reflectionImageView.image = [theImage reflectedImageWithHeight:theCell.reflectionImageView.bounds.size.height];
		theCell.backgroundColor = [UIColor clearColor];
#else
		ALAsset *theAsset = [self.assets objectAtIndex:indexPath.row];
		theCell.imageView.image = [UIImage imageWithCGImage:theAsset.thumbnail];
		theCell.reflectionImageView.image = [[UIImage imageWithCGImage:theAsset.thumbnail] reflectedImageWithHeight:theCell.reflectionImageView.bounds.size.height];
		theCell.backgroundColor = [UIColor clearColor];
#endif
		}

	return(theCell);
	}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
	{
	UICollectionReusableView *theView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"title" forIndexPath:indexPath];
	return(theView);
	}

#pragma mark -

- (void)tap:(UITapGestureRecognizer *)inGestureRecognizer
	{
	NSIndexPath *theIndexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];

	NSLog(@"%@", [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:theIndexPath]);
	}

@end
