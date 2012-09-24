//
//  CCoverflowCollectionViewLayout.m
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CCoverflowCollectionViewLayout.h"

#import "CInterpolator.h"

#import "CBetterCollectionViewLayoutAttributes.h"

//#define XORY(axis, point) ((axis) ? (point.y) : (point.x))
//#define WORH(axis, size) ((axis) ? (size.height) : (size.width))

@interface CCoverflowCollectionViewLayout ()
@property (readwrite, nonatomic, assign) CGFloat centerOffset;
@property (readwrite, nonatomic, assign) NSInteger cellCount;
@property (readwrite, nonatomic, strong) CInterpolator *scaleInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *positionInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *darknessInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *rotationInterpolator;
@property (readwrite, nonatomic, strong) CInterpolator *zIndexInterpolator;
@end

@implementation CCoverflowCollectionViewLayout

+ (Class)layoutAttributesClass
    {
    return([CBetterCollectionViewLayoutAttributes class]);
    }

- (void)awakeFromNib
	{
    self.cellSize = (CGSize){ 200, 200 };
    self.cellSpacing = (CGSize){ 200, 0 };
	self.snapToCells = YES;

    self.positionInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-1.0):                 @( 0.5),
		@(-0.5 - FLT_EPSILON):  @( 0.5),
		@(-0.5):                @( 0.0),
		}] interpolatorWithReflection:NO];

	self.rotationInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-0.5):  @(80.0),
		@(-0.25): @( 0.0),
		}] interpolatorWithReflection:YES];

	self.scaleInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-1.0):               @(  0.9),
		@(-0.5):               @(  1.0),
		}] interpolatorWithReflection:NO];

	self.darknessInterpolator = [[CInterpolator interpolatorWithDictionary:@{
		@(-0.5):  @(0.5),
		@(-0.25): @(1.0),
		}] interpolatorWithReflection:NO];
	}

- (void)prepareLayout
    {
    [super prepareLayout];

	self.centerOffset = (self.collectionView.bounds.size.width - self.cellSpacing.width) * 0.5;

    self.cellCount = [self.collectionView numberOfItemsInSection:0];
	}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
    {
    return(YES);
    }

- (CGSize)collectionViewContentSize
	{
	#warning TODO
    const CGSize theSize = {
        .width = 10000, // self.cellSpacing.width * self.cellCount + fabs(self.centerOffset) * 2,
        .height = self.collectionView.bounds.size.height,
        };
    return(theSize);
	}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
	{
    NSMutableArray *theLayoutAttributes = [NSMutableArray array];
	NSInteger theStart = 0;
	NSInteger theStop = self.cellCount;
    for (NSInteger N = theStart; N != theStop; ++N)
        {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:N inSection:0];

        UICollectionViewLayoutAttributes *theAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        if (theAttributes != NULL)
            {
            [theLayoutAttributes addObject:theAttributes];
            }
        }
    return(theLayoutAttributes);
	}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
	{
	// Capture some commonly used variables...
    const CGFloat N = indexPath.row;
	const CGRect theViewBounds = self.collectionView.bounds;

	// Get a cached attributes object or create a new one...
	// TODO: Not sure if caching helps or hinders.
    CBetterCollectionViewLayoutAttributes *theAttributes = [[[self class] layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];
	theAttributes.size = self.cellSize;

	// #########################################################################

	// Delta is distance from center of the view in cellSpacing units...
	const CGFloat theDelta = ((N + 0.5f) * self.cellSpacing.width + self.centerOffset - theViewBounds.size.width * 0.5f - self.collectionView.contentOffset.x) / self.cellSpacing.width;

	// #########################################################################
	CATransform3D theTransform = CATransform3DIdentity;
	theTransform.m34 = 1.0f / -2000.0f; // Magic Number is Magic.

    const CGFloat theScale = [self.scaleInterpolator interpolatedValueForKey:theDelta];
    theTransform = CATransform3DScale(theTransform, theScale, theScale, 1.0f);

	const CGFloat theRotation = [self.rotationInterpolator interpolatedValueForKey:theDelta];
	theTransform = CATransform3DRotate(theTransform, theRotation * (CGFloat)M_PI / 180.0f, 0.0f, 1.0f, 0.0f);

//	CGFloat theZIndex = [self.zIndexInterpolator interpolatedValueForKey:theDelta];
//	theTransform = CATransform3DTranslate(theTransform, 0.0, 0.0, -theZIndex * 3000.0 * 10.0);
//	theAttributes.zIndex = theZIndex;

	theAttributes.transform3D = theTransform;

	// #########################################################################

//	theAttributes.shieldAlpha = 1.0 - [self.darknessInterpolator interpolatedValueForKey:theDelta];

	// #########################################################################

	#warning TODO

	CGFloat thePositionMultiplier = self.positionInterpolator ? [self.positionInterpolator interpolatedValueForKey:theDelta] : 0.0f;
    CGFloat thePosition = ((N + 0.5f) * self.cellSpacing.width);
	thePosition += thePositionMultiplier * self.cellSpacing.width;
	theAttributes.center = (CGPoint){ thePosition + self.centerOffset, CGRectGetMidY(theViewBounds) };

	// #########################################################################

	// TODO - this is just for debugging...
	theAttributes.userInfo = @{
		@"delta": @(theDelta),
//		@"rotation": @(theRotation),
//		@"scale": @(theScale),
//		@"Z": @(theZIndex),
		@"contentOffset": @(self.collectionView.contentOffset.x),
		@"P": @(thePositionMultiplier),
		};

	// #########################################################################

    return(theAttributes);
	}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
    {
    CGPoint theTargetContentOffset = proposedContentOffset;
    if (self.snapToCells == YES)
        {
        theTargetContentOffset.x = roundf(theTargetContentOffset.x / self.cellSpacing.width) * self.cellSpacing.width;
        theTargetContentOffset.x = MIN(theTargetContentOffset.x, (self.cellCount - 1) * self.cellSpacing.width);
        }
    return(theTargetContentOffset);
    }


@end
