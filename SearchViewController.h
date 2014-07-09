//
//  SearchViewController.h
//  DuckGenius
//
//  Created by Spencer Kamchee on 2/12/14.
//  Copyright (c) 2014 Spencer Kamchee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController

//Holds an array of NSDictionaries. Each NSDictionary is one query search result.
@property (strong,nonatomic) NSMutableArray *searchResults;

- (IBAction)addButtonTapped:(UIBarButtonItem *)sender;

- (void)downloadData:(NSString*)queryTerm;

@end
