//
//  MapPrice.h
//  Tickets
//
//  Created by Ilya Doroshkevitch on 29.12.2020.
//

#import <Foundation/Foundation.h>
#import "City.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapPrice : NSObject

@property (strong, nonatomic) City *to;
@property (strong, nonatomic) City *from;
@property (strong, nonatomic) NSDate *departure;
@property (strong, nonatomic) NSDate *returnDate;
@property (nonatomic) NSInteger numberOfChanges;
@property (nonatomic) NSInteger price;
@property (nonatomic) NSInteger distance;
@property (nonatomic) BOOL actual;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withOrigin: (City *)origin;

@end

NS_ASSUME_NONNULL_END
