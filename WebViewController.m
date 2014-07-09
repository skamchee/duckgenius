//
//  WebViewController.m
//  DuckGenius
//
//  Created by Spencer Kamchee on 2/12/14.
//  Copyright (c) 2014 Spencer Kamchee. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//scale the webpage to fit the view
    self.webView.scalesPageToFit=YES;
    
    if(self.url){
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[[NSURL alloc]initWithString:self.url]];
        [self.webView loadRequest:urlRequest];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)refreshButton:(UIBarButtonItem *)sender {
    [self.webView reload];
}

- (IBAction)backButton:(UIBarButtonItem *)sender {
    [self.webView goBack];
}

- (IBAction)forwardButton:(UIBarButtonItem *)sender {
    [self.webView goForward];
}
@end
