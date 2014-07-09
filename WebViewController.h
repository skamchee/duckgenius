//
//  WebViewController.h
//  DuckGenius
//
//  Created by Spencer Kamchee on 2/12/14.
//  Copyright (c) 2014 Spencer Kamchee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController


- (IBAction)refreshButton:(UIBarButtonItem *)sender;
- (IBAction)backButton:(UIBarButtonItem *)sender;
- (IBAction)forwardButton:(UIBarButtonItem *)sender;
//weak because self.view holds a reference to webView
//note:self.view is strong so as long as self.view is around
//we know webView will be around
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong,nonatomic) NSString *url;


@end
