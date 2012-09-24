//
//  CInterpolator.h
//  NewScroller
//
//  Created by Jonathan Wight on 9/6/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CInterpolator : NSObject

@property (readwrite, nonatomic, copy) NSArray *keys;
@property (readwrite, nonatomic, copy) NSArray *values;

+ (CInterpolator *)interpolator;
+ (CInterpolator *)interpolatorWithValues:(NSArray *)inValues forKeys:(NSArray *)inKeys;
+ (CInterpolator *)interpolatorWithDictionary:(NSDictionary *)inDictionary;

- (CGFloat)interpolatedValueForKey:(CGFloat)key;

@end

#pragma mark -

@interface CInterpolator (Convenience)
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id value, BOOL *stop))block;;
- (CInterpolator *)interpolatorWithReflection;
- (NSArray *)interpolatedValuesForKeys:(NSArray *)inKeys;
@end