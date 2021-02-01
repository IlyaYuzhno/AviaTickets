//
//  FavoriteMapPrice+CoreDataProperties.h
//  Tickets
//
//  Created by Ilya Doroshkevitch on 20.01.2021.
//
//

#import "FavoriteMapPrice+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface FavoriteMapPrice (CoreDataProperties)

+ (NSFetchRequest<FavoriteMapPrice *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *created;
@property (nullable, nonatomic, copy) NSString *to;
@property (nullable, nonatomic, copy) NSString *from;
@property (nonatomic) int64_t price;
@property (nonatomic) int16_t flightNumber;
@property (nullable, nonatomic, copy) NSDate *departure;
@property (nonatomic) int16_t numberOfChanges;
@property (nullable, nonatomic, copy) NSString *airline;

@end

NS_ASSUME_NONNULL_END
