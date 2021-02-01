//
//  FavoriteMapPrice+CoreDataProperties.m
//  Tickets
//
//  Created by Ilya Doroshkevitch on 20.01.2021.
//
//

#import "FavoriteMapPrice+CoreDataProperties.h"

@implementation FavoriteMapPrice (CoreDataProperties)

+ (NSFetchRequest<FavoriteMapPrice *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"FavoriteMapPrice"];
}

@dynamic created;
@dynamic to;
@dynamic from;
@dynamic price;
@dynamic flightNumber;
@dynamic departure;
@dynamic numberOfChanges;
@dynamic airline;

@end
