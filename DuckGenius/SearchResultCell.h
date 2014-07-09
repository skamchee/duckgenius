//
//  SearchResultCell.h
//  DuckGenius
//
//  Created by Spencer Kamchee on 2/12/14.
//  Copyright (c) 2014 Spencer Kamchee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *searchText;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;

@end
