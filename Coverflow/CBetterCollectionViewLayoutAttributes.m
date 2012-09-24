//
//  CBetterCollectionViewLayoutAttributes.m
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CBetterCollectionViewLayoutAttributes.h"

@implementation CBetterCollectionViewLayoutAttributes

- (id)copyWithZone:(NSZone *)zone;
    {
    CBetterCollectionViewLayoutAttributes *theCopy = [super copyWithZone:zone];
	theCopy.userInfo = [self.userInfo copyWithZone:zone];
    return(theCopy);
    }

@end
