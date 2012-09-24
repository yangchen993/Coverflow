//
//  CBetterCollectionViewCell.m
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CBetterCollectionViewCell.h"

#import <QuartzCore/QuartzCore.h>

#import "CBetterCollectionViewLayoutAttributes.h"

@interface CBetterCollectionViewCell ()
@property (readwrite, nonatomic, strong) CALayer *shieldLayer;
@end

#pragma mark -

@implementation CBetterCollectionViewCell

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
    {
    [super applyLayoutAttributes:layoutAttributes];

    CBetterCollectionViewLayoutAttributes *theLayoutAttributes = (CBetterCollectionViewLayoutAttributes *)layoutAttributes;
    if (self.shieldLayer == NULL)
        {
        self.shieldLayer = [self makeShieldLayer];
        self.shieldLayer.zPosition = INFINITY;
        [self.layer addSublayer:self.shieldLayer];
        }

    self.shieldLayer.opacity = theLayoutAttributes.shieldAlpha;
    }

#pragma mark -

- (CALayer *)makeShieldLayer
    {
    CALayer *theShield = [CALayer layer];
    theShield.frame = self.bounds;
    theShield.backgroundColor = [UIColor blackColor].CGColor;
    return(theShield);
    }


@end
