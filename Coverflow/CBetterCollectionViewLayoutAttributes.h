//
//  CBetterCollectionViewLayoutAttributes.h
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBetterCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes
@property (readwrite, nonatomic, assign) CGFloat shieldAlpha;
@property (readwrite, nonatomic, strong) id <NSCopying> userInfo;
@end
