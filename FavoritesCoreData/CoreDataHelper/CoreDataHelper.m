//
//  CoreDataHelper.m
//  Tickets
//
//  Created by Ilya Doroshkevitch on 20.01.2021.
//

#import "CoreDataHelper.h"


@interface CoreDataHelper ()
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@end


@implementation CoreDataHelper

+ (instancetype)sharedInstance
{
    static CoreDataHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataHelper alloc] init];
        [instance setup];
    });
    return instance;
}

- (void)setup {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FavoriteTicket" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSURL *docsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [docsURL URLByAppendingPathComponent:@"base.sqlite"];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    
    NSPersistentStore* store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:nil];
    if (!store) {
        abort();
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
}

- (void)save {
    NSError *error;
    [_managedObjectContext save: &error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
}

#pragma mark - favoriteFromTicket
- (FavoriteTicket *)favoriteFromTicket:(Ticket *)ticket {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
    request.predicate = [NSPredicate predicateWithFormat:@"price == %ld AND airline == %@ AND from == %@ AND to == %@ AND departure == %@ AND expires == %@ AND flightNumber == %ld", (long)ticket.price.integerValue, ticket.airline, ticket.from, ticket.to, ticket.departure, ticket.expires, (long)ticket.flightNumber.integerValue];
    return [[_managedObjectContext executeFetchRequest:request error:nil] firstObject];
}

#pragma mark - favoriteFromMapPrice
- (FavoriteMapPrice *)favoriteFromMapPrice:(MapPrice *)price {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteMapPrice"];
    request.predicate = [NSPredicate predicateWithFormat:@"price == %ld AND from == %@ AND to == %@ AND departure == %@", (long)price.price, price.from.name, price.to.name, price.departure];
    return [[_managedObjectContext executeFetchRequest:request error:nil] firstObject];
}

/*
 

 
 mapPriceFavorite.price = price.value;
 mapPriceFavorite.departure = price.departure;
 mapPriceFavorite.from = price.origin.name;
 mapPriceFavorite.to = price.destination.name;
 mapPriceFavorite.created = [NSDate date];
 */


#pragma mark - Ticket isFavorite
- (BOOL)isFavorite:(Ticket *)ticket {
    return [self favoriteFromTicket:ticket] != nil;
}


#pragma mark - MapPrice isFavorite
- (BOOL)isFavoriteMapPrice:(MapPrice *)price {
    return [self favoriteFromMapPrice:price] != nil;
}


#pragma mark - Add Ticket to Favorite
- (void)addToFavorite:(Ticket *)ticket {
    FavoriteTicket *favorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteTicket" inManagedObjectContext:_managedObjectContext];
    favorite.price = ticket.price.intValue;
    favorite.airline = ticket.airline;
    favorite.departure = ticket.departure;
    favorite.expires = ticket.expires;
    favorite.flightNumber = ticket.flightNumber.intValue;
    favorite.returnDate = ticket.returnDate;
    favorite.from = ticket.from;
    favorite.to = ticket.to;
    favorite.created = [NSDate date];
    [self save];
}


#pragma mark - Add MapPrice to Favorite
- (void)addToFavoriteMapPrice:(MapPrice *)price {
    FavoriteMapPrice *mapPriceFavorite = [NSEntityDescription insertNewObjectForEntityForName:@"FavoriteMapPrice" inManagedObjectContext:_managedObjectContext];
    
    mapPriceFavorite.price = price.price;
    mapPriceFavorite.departure = price.departure;
    mapPriceFavorite.from = price.from.name;
    mapPriceFavorite.to = price.to.name;
    mapPriceFavorite.created = [NSDate date];
    
    [self save];
}

#pragma mark - Remove Ticket from Favorite
- (void)removeFromFavorite:(Ticket *)ticket {
    FavoriteTicket *favorite = [self favoriteFromTicket:ticket];
    if (favorite) {
        [_managedObjectContext deleteObject:favorite];
        [self save];
    }
}

#pragma mark - Remove MapPrice from Favorite
- (void)removeFromFavoriteMapPrice:(MapPrice *)price {
    FavoriteMapPrice *mapPrice = [self favoriteFromMapPrice:price];
    if (mapPrice) {
        [_managedObjectContext deleteObject:mapPrice];
        [self save];
    }
}


- (NSArray *)favorites {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteTicket"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
    return [_managedObjectContext executeFetchRequest:request error:nil];
}

- (NSArray *)favoritesMapPrices {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteMapPrice"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"departure" ascending:NO]];
    return [_managedObjectContext executeFetchRequest:request error:nil];
}



@end



