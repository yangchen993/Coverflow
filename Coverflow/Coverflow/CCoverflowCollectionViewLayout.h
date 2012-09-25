//
//  CCoverflowCollectionViewLayout.h
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCoverflowCollectionViewLayout : UICollectionViewLayout
@property (readwrite, nonatomic, assign) CGSize cellSize;
@property (readwrite, nonatomic, assign) CGSize cellSpacing;
@property (readwrite, nonatomic, assign) BOOL snapToCells;
@end
