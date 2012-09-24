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
@property (readwrite, nonatomic, strong) NSCache *attributeCache;
@end

@implementation CCoverflowCollectionViewLayout

+ (Class)layoutAttributesClass
    {
    return([CBetterCollectionViewLayoutAttributes class]);
    }

- (void)awakeFromNib
	{
    self.cellSize = (CGSize){ 200, 200 };
    self.cellSpacing = (CGSize){ 100, 0 };

	const CGFloat D = 0.5;

    self.positionInterpolator = [CInterpolator interpolatorWithDictionary:@{
		@(-D * 5.0): @(-8.0),
		@(-D * 2.0): @(1.0),
		@( D * 2.0): @(1.0),
		@( D * 5.0): @(0.5),
		}];

	self.rotationInterpolator = [CInterpolator interpolatorWithDictionary:@{
		@(-0.5):               @(  80),
		@(-0.25):               @(  0),
		@( 0.25):               @(  0),
		@( 0.5):               @(  -80),
		}];

	self.scaleInterpolator = [CInterpolator interpolatorWithDictionary:@{
		@(-1.0):               @(  0.9),
		@(-0.5):               @(  1.0),
		@( 0.5):               @(  1.0),
		@( 1.0):               @(  0.9),
		}];

	self.darknessInterpolator = [CInterpolator interpolatorWithDictionary:@{
		@(-0.5):               @(  0.5),
		@(-0.25):               @(  1.0),
		@( 0.25):               @(  1.0),
		@( 0.5):               @(  0.5),
		}];

    self.attributeCache = [[NSCache alloc] init];
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
    const CGFloat N = indexPath.row;

	const CGRect theViewBounds = self.collectionView.bounds;

    CBetterCollectionViewLayoutAttributes *theAttributes = [self.attributeCache objectForKey:indexPath];
    if (theAttributes == NULL)
        {
        theAttributes = [[[self class] layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];
        theAttributes.size = self.cellSize;

        [self.attributeCache setObject:theAttributes forKey:indexPath];
        }


	// #########################################################################


	// Delta is distance from center of the view in cellSpacing units...

	const CGFloat theDelta = ((N + 0.5) * self.cellSpacing.width + self.centerOffset - theViewBounds.size.width * 0.5 - self.collectionView.contentOffset.x) / self.cellSpacing.width;

	// #########################################################################
	CATransform3D theTransform = CATransform3DIdentity;
	theTransform.m34 = 1.0 / -2000.0; // Magic Number is Magic.

    const CGFloat theScale = [self.scaleInterpolator interpolatedValueForKey:theDelta];
//    theTransform = CATransform3DScale(theTransform, theScale, theScale, 1.0);

	const CGFloat theRotation = [self.rotationInterpolator interpolatedValueForKey:theDelta];
//	theTransform = CATransform3DRotate(theTransform, theRotation * M_PI / 180.0, 0.0, 1.0, 0.0);

	CGFloat theZIndex = [self.zIndexInterpolator interpolatedValueForKey:theDelta];
//	theTransform = CATransform3DTranslate(theTransform, 0.0, 0.0, -theZIndex * 3000.0 * 10.0);
//	theAttributes.zIndex = theZIndex;

	theAttributes.transform3D = theTransform;

	// #########################################################################

    CGFloat thePosition = ((N + 0.5) * self.cellSpacing.width);
	theAttributes.center = (CGPoint){ thePosition + self.centerOffset, CGRectGetMidY(theViewBounds) };


	// #########################################################################

//	theAttributes.shieldAlpha = 1.0 - [self.darknessInterpolator interpolatedValueForKey:theDelta];

	// #########################################################################
	theAttributes.userInfo = @{
		@"delta": @(theDelta),
		@"rotation": @(theRotation),
		@"scale": @(theScale),
		@"Z": @(theZIndex),
		@"contentOffset": @(self.collectionView.contentOffset.x),
		};

    return(theAttributes);
	}

@end
