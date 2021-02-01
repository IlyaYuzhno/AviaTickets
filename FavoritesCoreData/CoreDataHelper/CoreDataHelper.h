//
//  CoreDataHelper.h
//  Tickets
//
//  Created by Ilya Doroshkevitch on 20.01.2021.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataManager.h"
#import "FavoriteTicket+CoreDataClass.h"
#import "FavoriteMapPrice+CoreDataClass.h"
#import "Ticket.h"
#import "MapPrice.h"

@interface CoreDataHelper : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isFavorite:(Ticket *)ticket;
- (BOOL)isFavoriteMapPrice:(MapPrice *)price;
- (NSArray *)favorites;
- (NSArray *)favoritesMapPrices;
- (void)addToFavorite:(Ticket *)ticket;
- (void)removeFromFavorite:(Ticket *)ticket;
- (void)addToFavoriteMapPrice:(MapPrice *)price;
- (void)removeFromFavoriteMapPrice:(MapPrice *)price;


@end
