//
//  ViewController.m
//  Tickets
//
//  Created by Ilya Doroshkevitch on 18.12.2020.
//

#import "MainViewController.h"
#import "DataManager.h"
#import "PlaceViewController.h"
#import "APIManager.h"
#import "Ticket.h"
#import "TicketTableViewController.h"
#import "MapPrice.h"
#import "LocationService.h"
#import "CoreDataHelper.h"


@interface MainViewController () <PlaceViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UIView *placeContainerView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton *departureButton;
@property (nonatomic, strong) UIButton *arrivalButton;
@property (nonatomic, strong) UILabel *atLabel;
@property (nonatomic) SearchRequest searchRequest;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) City *origin;
@property (nonatomic, strong) NSArray *prices;
@property (nonatomic, strong) LocationService *locationService;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[DataManager sharedInstance] loadData];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.title = NSLocalizedString(@"main_search", "");
    
    _placeContainerView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 140.0, [UIScreen mainScreen].bounds.size.width - 40.0, 170.0)];
    _placeContainerView.backgroundColor = [UIColor whiteColor];
    _placeContainerView.layer.shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
    _placeContainerView.layer.shadowOffset = CGSizeZero;
    _placeContainerView.layer.shadowRadius = 20.0;
    _placeContainerView.layer.shadowOpacity = 1.0;
    _placeContainerView.layer.cornerRadius = 6.0;
    
    _departureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_departureButton setTitle:NSLocalizedString(@"main_from", "") forState: UIControlStateNormal];
    _departureButton.tintColor = [UIColor blackColor];
    _departureButton.frame = CGRectMake(10.0, 20.0, _placeContainerView.frame.size.width - 20.0, 60.0);
    _departureButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    _departureButton.layer.cornerRadius = 4.0;
    [_departureButton addTarget:self action:@selector(placeButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.placeContainerView addSubview:_departureButton];
    
    
    _arrivalButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_arrivalButton setTitle:NSLocalizedString(@"main_to", "") forState: UIControlStateNormal];
    _arrivalButton.tintColor = [UIColor blackColor];
    _arrivalButton.frame = CGRectMake(10.0, CGRectGetMaxY(_departureButton.frame) + 10.0, _placeContainerView.frame.size.width - 20.0, 60.0);
    _arrivalButton.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    _arrivalButton.layer.cornerRadius = 4.0;
    [_arrivalButton addTarget:self action:@selector(placeButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.placeContainerView addSubview:_arrivalButton];
    [self.view addSubview: _placeContainerView];
    
    _searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_searchButton setTitle:NSLocalizedString(@"search_button", "") forState:UIControlStateNormal];
    _searchButton.tintColor = [UIColor whiteColor];
    _searchButton.frame = CGRectMake(30.0, CGRectGetMaxY(_placeContainerView.frame) + 30, [UIScreen mainScreen].bounds.size.width - 60.0, 60.0);
    _searchButton.backgroundColor = [UIColor blackColor];
    _searchButton.layer.cornerRadius = 8.0;
    _searchButton.titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
    [_searchButton addTarget:self action:@selector(searchButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_searchButton];
    
    _atLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY(_searchButton.frame) + 30, 200, 40.0)];
    _atLabel.text = NSLocalizedString(@"map_price_header", "");
    [_atLabel setFont:[UIFont boldSystemFontOfSize:24]];
    [self.view addSubview:_atLabel];
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY(_atLabel.frame) + 10, [UIScreen mainScreen].bounds.size.width - 40.0, 340.0)];
    _mapView.backgroundColor = [UIColor redColor];
    _mapView.layer.shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.1] CGColor];
    _mapView.layer.shadowOffset = CGSizeZero;
    _mapView.layer.shadowRadius = 20.0;
    _mapView.layer.shadowOpacity = 1.0;
    _mapView.layer.cornerRadius = 6.0;
    _mapView.showsUserLocation = YES;
    _mapView.delegate = self;
    [self.view addSubview: _mapView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadedSuccessfully) name:kDataManagerLoadDataDidComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataLoadedSuccessfully) name:kDataManagerLoadDataDidComplete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentLocation:) name:kLocationServiceDidUpdateCurrentLocation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived) name:@"pushNotification" object:nil];
    
    
}

// MARK: Open Favorite Tickets View after notification tap
-(void)pushNotificationReceived{

    TicketTableViewController *ticketView = [[TicketTableViewController alloc] initFavoriteTicketsController];
    
 [self presentViewController:ticketView animated:YES completion:nil];
}

//MARK: ViewDidAppear
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self presentFirstViewControllerIfNeeded];
}

#pragma  mark - Show or not show Start Screen
- (void)presentFirstViewControllerIfNeeded
{
    BOOL isFirstStart = [[NSUserDefaults standardUserDefaults] boolForKey:@"first_start"];
    if (!isFirstStart) {
        FirstViewController *firstViewController = [[FirstViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        [self presentViewController:firstViewController animated:YES completion:nil];
    }
}



#pragma  mark - Search Button Tapped no animations
//- (void)searchButtonDidTap:(UIButton *)sender {
//    [[APIManager sharedInstance] ticketsWithRequest:_searchRequest withCompletion:^(NSArray *tickets) {
//        if (tickets.count >= 0) {
//            TicketTableViewController *ticketsViewController = [[TicketTableViewController alloc] initWithTickets:tickets];
//            [self.navigationController showViewController:ticketsViewController sender:self];
//        } else {
//            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", "") message:NSLocalizedString(@"tickets_not_found", "") preferredStyle: UIAlertControllerStyleAlert];
//            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"close", "") style:(UIAlertActionStyleDefault) handler:nil]];
//            [self presentViewController:alertController animated:YES completion:nil];
//        }
//    }];
//}

#pragma  mark - Search Button Tapped with animations

- (void)searchButtonDidTap:(UIButton *)sender {
    if (_searchRequest.origin && _searchRequest.destination) {
        [[ProgressView sharedInstance] show:^{
            [[APIManager sharedInstance] ticketsWithRequest:self->_searchRequest withCompletion:^(NSArray *tickets) {
                [[ProgressView sharedInstance] dismiss:^{
                    if (tickets.count > 0) {
                        TicketTableViewController *ticketsViewController = [[TicketTableViewController alloc] initWithTickets:tickets];
                        [self.navigationController showViewController:ticketsViewController sender:self];
                    } else {
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", "") message:NSLocalizedString(@"tickets_not_found", "") preferredStyle: UIAlertControllerStyleAlert];
                        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"close", "") style:(UIAlertActionStyleDefault) handler:nil]];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                }];
            }];
        }];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", "") message:NSLocalizedString(@"not_set_place_arrival_or_departure", "") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Закрыть" style:(UIAlertActionStyleDefault) handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


 




- (void)dataLoadedSuccessfully {
    [[APIManager sharedInstance] cityForCurrentIP:^(City *city) {
        [self setPlace:city withDataType:DataSourceTypeCity andPlaceType:PlaceTypeDeparture forButton:self->_departureButton];
    }];
    _locationService = [[LocationService alloc] init];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)updateCurrentLocation:(NSNotification *)notification {
    _locationManager = [[CLLocationManager alloc] init];
    
    //MARK: Self position annotation add
    _annotation = [[MKPointAnnotation alloc] init];
    _annotation.coordinate = CLLocationCoordinate2DMake(55.7522200, 37.4155600);
    [_mapView addAnnotation:_annotation];
    
    // Moscow coordinates
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(55.7522200, 37.6155600);
    CLLocation *moscow = [[CLLocation alloc]initWithLatitude:coordinate.latitude         longitude:coordinate.longitude];
    
    _geoCoder = [[CLGeocoder alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
     if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
             [_locationManager requestWhenInUseAuthorization];
         }

     // Get autocoordinates
 //    CLLocationCoordinate2D coordinate;
 //    coordinate.latitude=_locationManager.location.coordinate.latitude;
 //    coordinate.longitude=_locationManager.location.coordinate.longitude;
     

     [_geoCoder reverseGeocodeLocation:moscow
                     completionHandler:^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         //String to hold address
         NSLog(@"placemark %@",placemark.region);
         NSLog(@"placemark %@",placemark.country);  // Give Country Name
         NSLog(@"I am currently at %@",placemark.locality); // Extract the city name
         
         self->_annotation.title = placemark.locality;
         
         [self->_departureButton setTitle: placemark.locality forState: UIControlStateNormal];
         
         NSLog(@"location %@",placemark.name);
         NSLog(@"location %@",placemark.ocean);
         NSLog(@"location %@",placemark.postalCode);
         NSLog(@"location %@",placemark.subLocality);
         NSLog(@"location %@",placemark.location);
         
     }
      ];
      
     
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

#pragma mark - Add Annotations with prices
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

- (void)placeButtonDidTap:(UIButton *)sender {
    PlaceViewController *placeViewController;
    if ([sender isEqual:_departureButton]) {
        placeViewController = [[PlaceViewController alloc] initWithType: PlaceTypeDeparture];
    } else {
        placeViewController = [[PlaceViewController alloc] initWithType: PlaceTypeArrival];
    }
    placeViewController.delegate = self;
    [self.navigationController pushViewController: placeViewController animated:YES];
}

#pragma mark - PlaceViewControllerDelegate
- (void)selectPlace:(id)place withType:(PlaceType)placeType andDataType:(DataSourceType)dataType {
    [self setPlace:place withDataType:dataType andPlaceType:placeType forButton: (placeType == PlaceTypeDeparture) ? _departureButton : _arrivalButton ];
}

- (void)setPlace:(id)place withDataType:(DataSourceType)dataType andPlaceType:(PlaceType)placeType forButton:(UIButton *)button {
    NSString *title;
    NSString *iata;
    if (dataType == DataSourceTypeCity) {
        City *city = (City *)place;
        title = city.name;
        iata = city.code;
    }
    else if (dataType == DataSourceTypeAirport) {
        Airport *airport = (Airport *)place;
        title = airport.name;
        iata = airport.cityCode;
    }
    if (placeType == PlaceTypeDeparture) {
        _searchRequest.origin = iata;
    } else {
        _searchRequest.destination = iata;
    }
    [button setTitle: title forState: UIControlStateNormal];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
}


#pragma mark - Annotation View
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *identifier = @"MarkerIdentifier";
    MKMarkerAnnotationView *annotationView = (MKMarkerAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
       if (!annotationView) {
        annotationView = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
       }
    annotationView.canShowCallout = YES;
    annotationView.calloutOffset = CGPointMake(-5.0, 5.0);
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.annotation = annotation;
    return annotationView;
}


#pragma mark - Annotation View tapped
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
        
    // Get annotation index
    NSUInteger index = [mapView.annotations indexOfObject:view.annotation];

    
    
    // Action with MapPrice
     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"actions_with_tickets", "") message:NSLocalizedString(@"actions_with_tickets_describe", "") preferredStyle:UIAlertControllerStyleActionSheet];
    
     UIAlertAction *favoriteAction;
    
     if ([[CoreDataHelper sharedInstance] isFavoriteMapPrice: [_prices objectAtIndex:index]]) {
         favoriteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"remove_from_favorite", "") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
             
             [[CoreDataHelper sharedInstance] removeFromFavoriteMapPrice:[self->_prices objectAtIndex:index]];
             
         }];
     } else {
         favoriteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"add_to_favorite", "") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
             // Add MapPrice to Favorite
             [[CoreDataHelper sharedInstance] addToFavoriteMapPrice: [self->_prices objectAtIndex:index]];
             
             
             // Get IATA from annotation title text
             NSArray *words = [view.annotation.title componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
             NSMutableArray *iata = [NSMutableArray new];
             for (NSString * word in words){
                 if ([word length] > 1 && [word characterAtIndex:0] == '('){
                     NSString * editedWord = [word substringFromIndex:1];
                     [iata addObject:editedWord];
                 }
             }
             
             //Set arrival button title
             [self->_arrivalButton setTitle: view.annotation.title forState: UIControlStateNormal];
             
             //Set searchrequest from IATA
             self->_searchRequest.destination = iata[0];
             
         }];
     }
     
    
    // Cancel action
     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"close", "") style:UIAlertActionStyleCancel handler:nil];
     [alertController addAction:favoriteAction];
     [alertController addAction:cancelAction];
     [self presentViewController:alertController animated:YES completion:nil];

    
}

@end
