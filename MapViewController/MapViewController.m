//
//  MapViewController.m
//  Tickets
//
//  Created by Ilya Doroshkevitch on 29.12.2020.
//

#import "MapViewController.h"
#import "LocationService.h"
#import "APIManager.h"
#import "MapPrice.h"

@interface MapViewController ()

@property (strong, nonatomic) MKMapView *mapView;
@property (nonatomic, strong) LocationService *locationService;
@property (nonatomic, strong) City *origin;
@property (nonatomic, strong) NSArray *prices;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Карта цен";
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.showsUserLocation = YES;
    [self.view addSubview:_mapView];
    
    [[DataManager sharedInstance] loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadedSuccessfully) name:kDataManagerLoadDataDidComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation:) name:kLocationServiceDidUpdateCurrentLocation object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dataLoadedSuccessfully {
    _locationService = [[LocationService alloc] init];
}

- (void)updateCurrentLocation:(NSNotification *)notification {
    CLLocation *currentLocation = notification.object;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(55.7522200, 37.6155600);
    CLLocation *moscow = [[CLLocation alloc]initWithLatitude:coordinate.latitude         longitude:coordinate.longitude];
    
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(moscow.coordinate, 1000000, 1000000);
    [_mapView setRegion: region animated: YES];
    
    if (moscow) {
        _origin = [[DataManager sharedInstance] cityForLocation:moscow];
        if (_origin) {
            [[APIManager sharedInstance] mapPricesFor:_origin withCompletion:^(NSArray *prices) {
                self.prices = prices;
            }];
        }
    }
}

- (void)setPrices:(NSArray *)prices {
    _prices = prices;
    [_mapView removeAnnotations: _mapView.annotations];
 
    for (MapPrice *price in prices) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.title = [NSString stringWithFormat:@"%@ (%@)", price.to.name, price.to.code];
            annotation.subtitle = [NSString stringWithFormat:@"%ld руб.", (long)price.price];
            annotation.coordinate = price.to.coordinate;
            [self->_mapView addAnnotation: annotation];
        });
    }
}





@end
