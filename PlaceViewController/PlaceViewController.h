//
//  PlaceViewController.h
//  Tickets
//
//  Created by Ilya Doroshkevitch on 22.12.2020.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"


typedef enum PlaceType {
    PlaceTypeArrival,
    PlaceTypeDeparture
} PlaceType;

@protocol PlaceViewControllerDelegate <NSObject>
- (void)selectPlace:(id)place withType:(PlaceType)placeType andDataType:(DataSourceType)dataType;
@end

@interface PlaceViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) id<PlaceViewControllerDelegate>delegate;
- (instancetype)initWithType:(PlaceType)type;

@end


