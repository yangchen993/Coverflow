//
//  CDemoCollectionViewCell.m
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CDemoCollectionViewCell.h"

#import "CBetterCollectionViewLayoutAttributes.h"

@implementation CDemoCollectionViewCell

- (id)initWithCoder:(NSCoder *)inCoder
    {
    if ((self = [super initWithCoder:inCoder]) != NULL)
        {
        }
    return(self);
    }

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
    {
    [super applyLayoutAttributes:layoutAttributes];

    CBetterCollectionViewLayoutAttributes *theLayoutAttributes = (CBetterCollectionViewLayoutAttributes *)layoutAttributes;

	NSMutableString *theInformation = [NSMutableString string];
	
	[theInformation appendFormat:@"Row: #%d\n", theLayoutAttributes.indexPath.row];
	[theInformation appendFormat:@"Center: %@\n", NSStringFromCGPoint(theLayoutAttributes.center)];
	NSDictionary *theUserInfo = (NSDictionary *)theLayoutAttributes.userInfo;
	[theUserInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[theInformation appendFormat:@"%@: %@\n", key, obj];
		}];

	self.informationLabel.text = theInformation;;
	}

@end
