//
//  SearchViewController.m
//  DuckGenius
//
//  Created by Spencer Kamchee on 2/12/14.
//  Copyright (c) 2014 Spencer Kamchee. All rights reserved.
//

#import "SearchViewController.h"
#import "WebViewController.h"
#import "SearchResultCell.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

-(void)viewDidAppear:(BOOL)animated{
    NSString *defaultSearch = @"Chicago";
    
    //lazy instantiation of self.searchResults
    //When user returns to the page, any existing search results should not be replaced if self.searchResults is not nil
    if(!self.searchResults){
        self.searchResults = [[NSMutableArray alloc]init];
        [self downloadData:defaultSearch];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //Return one row when there are no results. tableView: cellForRowAtIndexPath: should provide
    //one cell with a label saying "No results"
    if(![self.searchResults count])
        return 1;
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchResult";
    SearchResultCell *cell = (SearchResultCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

    if([self.searchResults count]){
        NSDictionary* aResult = self.searchResults[indexPath.row];
        cell.searchText.text = [aResult valueForKey:@"Text"];
        cell.label.text = [aResult valueForKey:@"FirstURL"];
        cell.searchImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[aResult valueForKey:@"Icon"] valueForKey:@"URL"]]]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.searchText.text = @"No results found";
        cell.label.text = @"";
        cell.searchImage.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"segueToWebViewController"]){
        WebViewController *wvController = (WebViewController*)segue.destinationViewController;
        SearchResultCell *cell = (SearchResultCell*)sender;
        wvController.url = cell.label.text;
    }
}

//called by UITableView when a cell is selected
//get the cell and set it as the sender (so we can extract data from it)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"segueToWebViewController" sender:selectedCell];
}

- (IBAction)addButtonTapped:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Query" message:@"Enter search term" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] ;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.delegate = self;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    UITextField * alertTextField = [alertView textFieldAtIndex:0];
    
    // Pass this text to our download method
    if([alertTextField.text length]){
        NSLog(@"Query duckduckgo for term: %@",alertTextField.text);
        [self downloadData:alertTextField.text];
    }else{
        NSLog(@"Empty string");
    }
}

- (void)downloadData:(NSString*)queryTerm
{
    //clear the previous set of search results
    [self.searchResults removeAllObjects];
    
    //url encode the search term
    NSString *urlEncodedQueryTerm = [queryTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *query = [NSString stringWithFormat:@"http://api.duckduckgo.com/?q=%@&format=json&pretty=1",urlEncodedQueryTerm];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:query]
            completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                NSError *errorJson = nil;
                // Convert JSON to NSDictionary
                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
                //NSLog(@"Results as an NSDictionary:%@",results);
                
                // Update the searchResults property
                NSArray *relatedTopicResults = [results valueForKey:@"RelatedTopics"];
                for(NSDictionary *result in relatedTopicResults){
                    
                    NSString *textValue = [result valueForKey:@"Text"];
                    NSString *firstURLValue = [result valueForKey:@"FirstURL"];
                    
                    if(textValue.length && firstURLValue.length){
                        [self.searchResults addObject:result];
                    }else{
                        NSArray *topicResults = [result valueForKey:@"Topics"];
                        for(NSDictionary *tResult in topicResults){
                            NSString *tTextValue = [tResult valueForKey:@"Text"];
                            NSString *tFirstURLValue = [tResult valueForKey:@"FirstURL"];

                            if(tTextValue.length && tFirstURLValue.length){
                                [self.searchResults addObject:tResult];
                            }
                        }
                    }
                }
                
                // Refresh the table on main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                
            }] resume];
    
    
    /*Update Recent Searches array*/
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Test is RecentSearcher array is in defaults, if not create it
    NSMutableArray *recentSearches;
    if (![defaults objectForKey:@"RecentSearches"]) {
        // Initialize the array
        recentSearches = [[NSMutableArray alloc] init];
    } else {
        // Make a mutable copy of the array so we can update it
        recentSearches = [[defaults objectForKey:@"RecentSearches"] mutableCopy];
    }
    NSDate *now = [[NSDate alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"hh:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *time = [dateFormatter stringFromDate:now];
    
    // Add the term to local array
    NSMutableDictionary *aQuery = [NSMutableDictionary dictionaryWithObject:queryTerm forKey:@"QueryTerm"];
    [aQuery setObject:time forKey:@"Time"];
    [recentSearches addObject:aQuery];
   
    // Copy local array to user defaults
    [defaults setObject:recentSearches forKey:@"RecentSearches"];
    // Write it to disk
    [defaults synchronize];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

@end

