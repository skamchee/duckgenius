//
//  RecentSearchesViewController.m
//  DuckGenius
//
//  Created by Spencer Kamchee on 2/13/14.
//  Copyright (c) 2014 Spencer Kamchee. All rights reserved.
//

#import "RecentSearchesViewController.h"
#import "SearchViewController.h"

@interface RecentSearchesViewController ()
@property (strong,nonatomic)NSMutableArray *recentSearches;
@property (strong,nonatomic)NSUserDefaults *defaults;
@end

@implementation RecentSearchesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //add a refresh control to the table
    self.refreshControl = [[UIRefreshControl alloc]init];
    //refresh control will call the refreshDataRequest method
    [self.refreshControl addTarget:self action:@selector(refreshDataRequest) forControlEvents:UIControlEventValueChanged];
    
}

//Get the most up to date copy of the model and reload the data into the table view
-(void)refreshDataRequest
{
    NSLog(@"Refreshing");
    [self.refreshControl beginRefreshing];
    self.defaults = [NSUserDefaults standardUserDefaults];
    // Test is RecentSearcher array is in defaults, if not create it
    
    if (![self.defaults objectForKey:@"RecentSearches"]) {
        // Initialize the array
        self.recentSearches = [[NSMutableArray alloc] init];
    } else {
        // Make a mutable copy of the array so we can update it
        self.recentSearches = [[self.defaults objectForKey:@"RecentSearches"] mutableCopy];
    }
    
    //[self.recentSearches removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    if(self.refreshControl.refreshing){
        [self.refreshControl endRefreshing];
        NSLog(@"Refresh done");
    }
}

//Runs just before the view appears on screen
- (void)viewWillAppear:(BOOL)animated
{
    [self refreshDataRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.recentSearches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecentSearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //UITableViewCells have a property textLabel which is the textLabel it owns
    cell.textLabel.text = [self.recentSearches[indexPath.row] objectForKey:@"QueryTerm"];
    cell.detailTextLabel.text = [self.recentSearches[indexPath.row] objectForKey:@"Time"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


//Clicking a recent search result should load it into the SearchViewController and
//the app switches back to the SearchViewController's root view (via the tab view controller)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Access the first root view controller of the tab controller using the built-in viewControllers array
    if([[self.tabBarController.viewControllers objectAtIndex:0] isKindOfClass:[UINavigationController class]]){
        UINavigationController *navControl = [self.tabBarController.viewControllers objectAtIndex:0];
        //get the root view controller of the UINavigationController
        SearchViewController *searchControl = [navControl.viewControllers objectAtIndex:0];
        //run a query using the text in the selected cell
        [searchControl downloadData:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        //if the navigation controller was looking at the WebViewController, we want to set it
        //back to the SearchViewController (the root controller) in order to see the search results
        [navControl popToRootViewControllerAnimated:NO];
        //show the first root view of the tab controller
        self.tabBarController.selectedViewController = navControl;
    }
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        /*Update the model before updating the table view, otherwise a runtime exception (NSInternalInconsistencyException)
        will occur saying that there is
        and inconsistency in rows between the model and the view*/
        
        //Remove the term from the local array. All indices of objects after term are auto-decremented
        [self.recentSearches removeObjectAtIndex:indexPath.row];
        NSLog(@"Model state after deletion: %@", self.recentSearches);
        // Copy local array to user defaults
        [self.defaults setObject:self.recentSearches forKey:@"RecentSearches"];
        // Write it to disk
        [self.defaults synchronize];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
       
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    //Method used to sync the model to the view. The UITableView automatically handles showing the view
    //differently, so we just need to update the model here.
    // Remove the term from the local array. Indices of objects after the deleted item are auto-decremented.
    id item = [self.recentSearches objectAtIndex:fromIndexPath.row];
    [self.recentSearches removeObjectAtIndex:fromIndexPath.row];
    //Objects at or after the insertion index are auto-incremented
    [self.recentSearches insertObject:item atIndex:toIndexPath.row];
    NSLog(@"Model state after reordering: %@", self.recentSearches);
    // Copy local array to user defaults
    [self.defaults setObject:self.recentSearches forKey:@"RecentSearches"];
    // Write it to disk
    [self.defaults synchronize];
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


//Clear out all recent searches
- (IBAction)clearAllButtonTapped:(id)sender {
    [self.recentSearches removeAllObjects];
    // Copy local array to user defaults
    [self.defaults setObject:self.recentSearches forKey:@"RecentSearches"];
    // Write it to disk
    [self.defaults synchronize];
    
    [self refreshDataRequest];
}
@end
