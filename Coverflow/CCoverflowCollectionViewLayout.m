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
    self.cellSpacing = (CGSize){ 200, 0 };

//    self.scaleInterpolator = [CInterpolator interpolator];
//    self.scaleInterpolator.keys = @[ @(0.0f), @(1.0f), @(2.0f) ];
//    self.scaleInterpolator.values = @[ @(0.75f), @(1.0f), @(0.75f) ];

//    self.positionInterpolator = [CInterpolator interpolator];
//    self.positionInterpolator.keys = @[ @(-5.0f), @(0.0f) ];
//    self.positionInterpolator.values = @[ @(4.0), @(0.0f) ];

	const CGFloat D = 0.5;
	self.rotationInterpolator = [CInterpolator interpolatorWithDictionary:@{
		@(0.0 - D * 2.0):               @( 80.0),
		@(0.0 - D + FLT_EPSILON):       @(  0.0),
		@(0.0 + D * 2.0):               @(  0.0),
		@(0.0 + D * 2.0 + FLT_EPSILON): @(-80.0),
		}];

	self.zIndexInterpolator = [CInterpolator interpolatorWithDictionary:@{
		@(0.0 - D * 2.0):               @(-80.0),
		@(0.0 - D + FLT_EPSILON):       @(  0.0),
		@(0.0 + D * 2.0):               @(  0.0),
		@(0.0 + D * 2.0 + FLT_EPSILON): @(-80.0),
		}];

    self.attributeCache = [[NSCache alloc] init];
	}

- (void)prepareLayout
    {
    [super prepareLayout];

	self.centerOffset = (self.collectionView.bounds.size.width - self.cellSize.width) * 0.5;

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

    CBetterCollectionViewLayoutAttributes *theAttributes = [self.attributeCache objectForKey:indexPath];
    if (theAttributes == NULL)
        {
        theAttributes = [[[self class] layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];
        theAttributes.size = self.cellSize;

        [self.attributeCache setObject:theAttributes forKey:indexPath];
        }


	// #########################################################################

    CGFloat thePosition = N * self.cellSpacing.width + self.cellSpacing.width * 0.5 + self.centerOffset;


	// Delta is distance from center of the view in cellSpacing units...

	CGFloat theDelta = ((thePosition - self.collectionView.bounds.size.width * 0.5) - self.collectionView.contentOffset.x) / self.cellSpacing.width;

	// #########################################################################
	CATransform3D theTransform = CATransform3DIdentity;
	theTransform.m34 = 1.0 / -2000.0; // Magic Number is Magic.

//    const CGFloat theScale = [self.scaleInterpolator interpolatedValueForKey:theDelta];
//    theTransform = CATransform3DScale(theTransform, theScale, theScale, 1.0);

	const CGFloat theRotation = [self.rotationInterpolator interpolatedValueForKey:theDelta];
	theTransform = CATransform3DRotate(theTransform, theRotation * M_PI / 180.0, 0.0, 1.0, 0.0);



	CGFloat theZIndex = [self.zIndexInterpolator interpolatedValueForKey:theDelta];
//	theTransform = CATransform3DTranslate(theTransform, 0.0, 0.0, -theZIndex * 3000.0 * 10.0);
theAttributes.zIndex = theZIndex;

	theAttributes.transform3D = theTransform;

	// #########################################################################
//    thePosition = thePosition + self.cellSpacing.width * [self.positionInterpolator interpolatedValueForKey:theDelta];

	theAttributes.center = (CGPoint){ thePosition, CGRectGetMidY(self.collectionView.bounds) };


	// #########################################################################
	theAttributes.userInfo = @{
		@"delta": @(theDelta),
		@"rotation": @(theRotation),
		@"Z": @(theZIndex),
//		@"contentOffset": @(self.collectionView.contentOffset.x),
//		@"view_width_div2": @(self.collectionView.bounds.size.width * 0.5),
//		@"X": @(theAttributes.center.x - theAttributes.size.width * 0.5),
//		@"bounds": NSStringFromCGRect(self.collectionView.bounds),
//		@"rotation": @(theRotation),
		};

    return(theAttributes);
	}

@end
