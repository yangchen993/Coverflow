//
//  CCoverflowCollectionViewLayout.m
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CCoverflowCollectionViewLayout.h"

#import "CInterpolator.h"
#import "CCoverflowTitleView.h"
#import "CBetterCollectionViewLayoutAttributes.h"

#define XORY_(point) (_alignment ? (point.y) : (point.x))
#define WORH_(size) (_alignment ? (size.height) : (size.width))
#define HORW_(size) (_alignment ? (size.width) : (size.height))
#define CGRectGetMinAxis_(rect) (!_alignment ? CGRectGetMinX((rect)) : CGRectGetMinY((rect)))
#define CGRectGetMaxAxis_(rect) (!_alignment ? CGRectGetMaxX((rect)) : CGRectGetMaxY((rect)))
#define CGPointMakeAligned_(s1, s2) (!_alignment ? CGPointMake((s1), (s2)) : CGPointMake((s2), (s1)))
#define CGSizeMakeAligned_(s1, s2) (!_alignment ? CGSizeMake((s1), (s2)) : CGSizeMake((s2), (s1)))

//#define CGRectGetMidY

@interface CCoverflowCollectionViewLayout ()
@property (readwrite, nonatomic, strong) NSIndexPath *currentIndexPath;

@property (readwrite, nonatomic, assign) CGFloat centerOffset;
@property (readwrite, nonatomic, assign) NSInteger cellCount;
@property (readwrite, nonatomic, strong) CInterpolator *scaleInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *positionoffsetInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *rotationInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *zOffsetInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *darknessInterpolator;

@property (readwrite, nonatomic, assign) int alignment; // 0 == horizontal, 1 == vertical
@end

@implementation CCoverflowCollectionViewLayout

+ (Class)layoutAttributesClass
    {
    return([CBetterCollectionViewLayoutAttributes class]);
    }

- (void)awakeFromNib
	{
	// TODO I don't like putting this in awakeFromNib - but init is never called. Silly.
	self.alignment = 0;
    self.cellSize = CGSizeMakeAligned_(200.0f, 300.0f);
    self.cellSpacing = 40.0f;
	self.snapToCells = YES;

    self.positionoffsetInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-1.0f):               @(-self.cellSpacing * 2.0f),
		@(-0.2f - FLT_EPSILON): @(  0.0f),
		}] interpolatorWithReflection:YES];

	self.rotationInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-0.5f):  @(50.0f),
		@(-0.0f): @( 0.0f),
		}] interpolatorWithReflection:YES];

	self.scaleInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-1.0f): @(0.9),
		@(-0.5f): @(1.0f),
		}] interpolatorWithReflection:NO];

	self.zOffsetInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-9.0f):               @(9.0f),
		@(-1.0f - FLT_EPSILON): @(1.0f),
		@(-1.0f):               @(0.0f),
		}] interpolatorWithReflection:NO];

	self.darknessInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-2.5f): @(0.5f),
		@(-0.5f): @(0.0f),
		}] interpolatorWithReflection:NO];
	}

- (void)prepareLayout
    {
    [super prepareLayout];

	self.centerOffset = (WORH_(self.collectionView.bounds.size) - self.cellSpacing) * 0.5f;

    self.cellCount = [self.collectionView numberOfItemsInSection:0];
	}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
    {
    return(YES);
    }

- (CGSize)collectionViewContentSize
	{
    const CGSize theSize = CGSizeMakeAligned_(
		self.cellSpacing * self.cellCount + self.centerOffset * 2.0f,
        HORW_(self.collectionView.bounds.size)
        );
    return(theSize);
	}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
	{
    NSMutableArray *theLayoutAttributes = [NSMutableArray array];

	// Cells...
	// TODO -- 3 is a bit of a fudge to make sure we get all cells... Ideally we should compute the right number of extra cells to fetch...
    NSInteger theStart = MIN(MAX((NSInteger)floorf(CGRectGetMinAxis_(rect) / self.cellSpacing) - 3, 0), self.cellCount);
    NSInteger theEnd = MIN(MAX((NSInteger)ceilf(CGRectGetMaxAxis_(rect) / self.cellSpacing) + 3, 0), self.cellCount);

    for (NSInteger N = theStart; N != theEnd; ++N)
        {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:N inSection:0];

        UICollectionViewLayoutAttributes *theAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        if (theAttributes != NULL)
            {
            [theLayoutAttributes addObject:theAttributes];
            }
        }

	// Decorations...
	[theLayoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:@"title" atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];

    return(theLayoutAttributes);
	}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
	{
	// Capture some commonly used variables...
    const CGFloat theRow = indexPath.row;
	const CGRect theViewBounds = self.collectionView.bounds;

    CBetterCollectionViewLayoutAttributes *theAttributes = [CBetterCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
	theAttributes.size = self.cellSize;

	// #########################################################################

	// Delta is distance from center of the view in cellSpacing units...
	const CGFloat theDelta = ((theRow + 0.5f) * self.cellSpacing + self.centerOffset - WORH_(theViewBounds.size) * 0.5f - XORY_(self.collectionView.contentOffset)) / self.cellSpacing;

	// TODO - we should write a getter for this that calculates the value. Setting it constantly is wasteful.
	if (roundf(theDelta) == 0)
		{
		self.currentIndexPath = indexPath;
		}

	// #########################################################################

    const CGFloat thePosition = (theRow + 0.5f) * self.cellSpacing + [self.positionoffsetInterpolator interpolatedValueForKey:theDelta];
	if (_alignment == 0)
		{
		theAttributes.center = CGPointMake(thePosition + self.centerOffset, CGRectGetMidY(theViewBounds));
		}
	else
		{
		theAttributes.center = CGPointMake(CGRectGetMidX(theViewBounds), thePosition + self.centerOffset);
		}

	// #########################################################################

	CATransform3D theTransform = CATransform3DIdentity;
	theTransform.m34 = 1.0f / -850.0f; // Magic Number is Magic.

    const CGFloat theScale = self.scaleInterpolator ? [self.scaleInterpolator interpolatedValueForKey:theDelta] : 1.0f;
    theTransform = CATransform3DScale(theTransform, theScale, theScale, 1.0f);

	const CGFloat theRotation = [self.rotationInterpolator interpolatedValueForKey:theDelta];
	theTransform = CATransform3DTranslate(theTransform, WORH_(self.cellSize) * (theDelta > 0.0f ? 0.5f : -0.5f), 0.0f, 0.0f);
	theTransform = CATransform3DRotate(theTransform, theRotation * (CGFloat)M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
	theTransform = CATransform3DTranslate(theTransform, WORH_(self.cellSize) * (theDelta > 0.0f ? -0.5f : 0.5f), 0.0f, 0.0f);

	const CGFloat theZOffset = [self.zOffsetInterpolator interpolatedValueForKey:theDelta];
	theTransform = CATransform3DTranslate(theTransform, 0.0, 0.0, theZOffset);

	theAttributes.transform3D = theTransform;

	// #########################################################################

	theAttributes.shieldAlpha = [self.darknessInterpolator interpolatedValueForKey:theDelta];

	// #########################################################################

    return(theAttributes);
	}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
	{
	UICollectionViewLayoutAttributes *theAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
	theAttributes.center = CGPointMake(CGRectGetMidX(self.collectionView.bounds), CGRectGetMaxY(self.collectionView.bounds) - 25.0);
	theAttributes.size = CGSizeMake(200, 50);
	theAttributes.zIndex = 1;
	return(theAttributes);
	}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
    {
    CGPoint theTargetContentOffset = proposedContentOffset;
    if (self.snapToCells == YES)
        {
        theTargetContentOffset.x = roundf(XORY_(theTargetContentOffset) / self.cellSpacing) * self.cellSpacing;
        theTargetContentOffset.x = MIN(XORY_(theTargetContentOffset), (self.cellCount - 1) * self.cellSpacing);
        }
    return(theTargetContentOffset);
    }


@end
