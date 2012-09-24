//
//  CInterpolator.m
//  NewScroller
//
//  Created by Jonathan Wight on 9/6/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CInterpolator.h"

#include "Interpolator.h"

// TODO interpolators for points, sizes, transforms, colors, etc.

@interface CInterpolator ()
@property (readwrite, nonatomic, assign) Interpolator <CGFloat> *KV;
@end

@implementation CInterpolator

+ (CInterpolator *)interpolator;
    {
    return([[self alloc] init]);
    }

+ (CInterpolator *)interpolatorWithDictionary:(NSDictionary *)inDictionary
	{
	NSArray *theKeys = [[inDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSMutableArray *theValues = [NSMutableArray array];
	for (id theKey in theKeys)
		{
		[theValues addObject:inDictionary[theKey]];
		}

	CInterpolator *theInterpolator = [self interpolator];
	theInterpolator.keys = theKeys;
	theInterpolator.values = theValues;
	return(theInterpolator);
	}

- (void)dealloc
    {
    if (_KV)
        {
        delete _KV;
        }
    }

- (CGFloat)interpolatedValueForKey:(CGFloat)key
    {
    if (_KV == NULL)
        {
        [self populate];
        }

    return(_KV->interpolate(key));
    }

- (void)populate
    {
    NSParameterAssert(_keys.count > 0);
    // NSParameterAssert([_keys isSorted]);
    NSParameterAssert(self.keys.count == self.values.count);

    // #########################################################################

    _KV = new Interpolator <CGFloat> ();
    for (int N = 0; N != self.keys.count; ++N)
        {
        _KV->addKV([self.keys[N] floatValue], [self.values[N] floatValue]);
        }
    }

@end

#pragma mark -

@implementation CInterpolator (Convenience)

- (NSArray *)interpolatedValuesForKeys:(NSArray *)inKeys
    {
    NSMutableArray *theValues = [NSMutableArray array];
    for (NSNumber *theKey in inKeys)
        {
        CGFloat theValue = [self interpolatedValueForKey:[theKey floatValue]];
        [theValues addObject:@(theValue)];
        }
    return(theValues);
    }

@end
