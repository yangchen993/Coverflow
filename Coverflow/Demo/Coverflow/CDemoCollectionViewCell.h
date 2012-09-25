//
//  CDemoCollectionViewCell.h
//  Coverflow
//
//  Created by Jonathan Wight on 9/24/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CBetterCollectionViewCell.h"

@interface CDemoCollectionViewCell : CBetterCollectionViewCell
@property (readwrite, nonatomic, weak) IBOutlet UIImageView *imageView;
@property (readwrite, nonatomic, weak) IBOutlet UIImageView *reflectionImageView;
@end
