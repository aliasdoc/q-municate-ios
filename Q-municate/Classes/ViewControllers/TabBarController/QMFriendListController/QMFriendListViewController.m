//
//  QMFriendListController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 7/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendListViewController.h"
#import "QMFriendsDetailsController.h"
#import "QMFriendListCell.h"
#import "QMFriendsListDataSource.h"
#import "QMApi.h"

@interface QMFriendListViewController ()

<UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>

@property (nonatomic, strong) QMFriendsListDataSource *dataSource;

@end

@implementation QMFriendListViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

#define kQMSHOW_SEARCH 0

- (void)viewDidLoad {
    [super viewDidLoad];
#if kQMSHOW_SEARCH
    [self.tableView setContentOffset:CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height) animated:NO];
#endif
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dataSource = [[QMFriendsListDataSource alloc] initWithTableView:self.tableView searchDisplayController:self.searchDisplayController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    QBUUser *selectedUser = [self.dataSource userAtIndexPath:indexPath];
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:selectedUser.ID];

    if (item) {
        [self performSegueWithIdentifier:kDetailsSegueIdentifier sender:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dataSource tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return [self.dataSource searchDisplayController:controller shouldReloadTableForSearchString:searchString];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    [self.dataSource searchDisplayController:controller didLoadSearchResultsTableView:tableView];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return [self.dataSource searchDisplayController:controller shouldReloadTableForSearchScope:searchOption];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.dataSource searchDisplayControllerWillBeginSearch:controller];
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    [self.dataSource searchDisplayControllerDidBeginSearch:controller];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.dataSource searchDisplayControllerWillEndSearch:controller];
}

#pragma mark - prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kDetailsSegueIdentifier]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QMFriendsDetailsController *vc = segue.destinationViewController;
        vc.selectedUser = [self.dataSource userAtIndexPath:indexPath];
    }
}

@end
