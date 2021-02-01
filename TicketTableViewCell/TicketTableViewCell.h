//
//  TicketTableViewCell.h
//  Tickets
//
//  Created by Ilya Doroshkevitch on 28.12.2020.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "APIManager.h"
#import "FavoriteTicket+CoreDataClass.h"
#import "FavoriteMapPrice+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface TicketTableViewCell : UITableViewCell

@property (nonatomic, strong) Ticket *ticket;
- (void)setFavoriteTicket:(FavoriteTicket *)favoriteTicket;
@property (nonatomic, strong) FavoriteTicket *favoriteTicket;
@property (nonatomic, strong) FavoriteMapPrice *favoriteMapPriceTicket;
- (void)setFavoriteMapPriceTicket:(FavoriteMapPrice *)favoriteMapPrice;
@property (nonatomic, strong) UIImageView *airlineLogoView;

@end

NS_ASSUME_NONNULL_END
