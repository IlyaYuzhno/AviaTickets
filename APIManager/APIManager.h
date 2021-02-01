//
//  APIManager.h
//  Tickets
//
//  Created by Ilya Doroshkevitch on 28.12.2020.
//

#import <Foundation/Foundation.h>
#import "City.h"
#import "DataManager.h"
#import "Ticket.h"
#import "MainViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (instancetype)sharedInstance;
- (void)cityForCurrentIP:(void (^)(City *city))completion;

- (void)ticketsWithRequest:(SearchRequest)request withCompletion:(void (^)(NSArray *tickets))completion;
- (void)mapPricesFor:(City *)origin withCompletion:(void (^)(NSArray *prices))completion;

@end

NS_ASSUME_NONNULL_END
