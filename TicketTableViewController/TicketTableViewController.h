//
//  TicketTableViewController.h
//  Tickets
//
//  Created by Ilya Doroshkevitch on 28.12.2020.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
#import "NotificationCenter.h"

NS_ASSUME_NONNULL_BEGIN

@interface TicketTableViewController : UITableViewController

- (instancetype)initWithTickets:(NSArray *)tickets;
- (instancetype)initFavoriteTicketsController;

@end

NS_ASSUME_NONNULL_END
