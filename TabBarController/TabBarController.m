//
//  TabBarController.m
//  Tickets
//
//  Created by Ilya Doroshkevitch on 20.01.2021.
//

#import "TabBarController.h"
#import "MainViewController.h"
#import "MapViewController.h"
#import "TicketTableViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
 
}


- (instancetype)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.viewControllers = [self createViewControllers];
        self.tabBar.tintColor = [UIColor blackColor];
    }
    return self;
}


- (NSArray<UIViewController*> *)createViewControllers {
    NSMutableArray<UIViewController*> *controllers = [NSMutableArray new];
    
    MainViewController *mainViewController = [[MainViewController alloc] init];
    mainViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];;
    UINavigationController *mainNavigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    [controllers addObject:mainNavigationController];
    
//    MapViewController *mapViewController = [[MapViewController alloc] init];
//    mapViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Карта цен" image:[UIImage imageNamed:@"map"] selectedImage:[UIImage imageNamed:@"map_selected"]];
//    UINavigationController *mapNavigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
//    [controllers addObject:mapNavigationController];
    
    TicketTableViewController *favoriteViewController = [[TicketTableViewController alloc] initFavoriteTicketsController];
    favoriteViewController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];;
    UINavigationController *favoriteNavigationController = [[UINavigationController alloc] initWithRootViewController:favoriteViewController];
    [controllers addObject:favoriteNavigationController];
    
    return controllers;
}









@end
