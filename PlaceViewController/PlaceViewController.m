//
//  PlaceViewController.m
//  Tickets
//
//  Created by Ilya Doroshkevitch on 22.12.2020.
//

#import "PlaceViewController.h"
#import "City.h"
#import "Airport.h"

#define ReuseIdentifier @"CellIdentifier"


@interface PlaceViewController ()

@property (nonatomic) PlaceType placeType;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSArray *currentArray;
@property (nonatomic, strong) NSArray *filteredArray;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation PlaceViewController

- (instancetype)initWithType:(PlaceType)type
{
    self = [super init];
    if (self) {
        _placeType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    _filteredArray = _currentArray;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    //MARK: Add SearchBar
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchBar.delegate = self;
    _tableView.tableHeaderView = _searchBar;
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Города", @"Аэропорты"]];
    [_segmentedControl addTarget:self action:@selector(changeSource) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.tintColor = [UIColor blackColor];
    self.navigationItem.titleView = _segmentedControl;
    _segmentedControl.selectedSegmentIndex = 0;
    [self changeSource];
    
    if (_placeType == PlaceTypeDeparture) {
        self.title = @"Откуда";
    } else {
        self.title = @"Куда";
    }
    
}

- (void)changeSource {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            _currentArray = [[DataManager sharedInstance] cities];
            _filteredArray = _currentArray;
            break;
        case 1:
            _currentArray = [[DataManager sharedInstance] airports];
            _filteredArray = _currentArray;
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}



//MARK: UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_filteredArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:ReuseIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (_segmentedControl.selectedSegmentIndex == 0) {
        City *city = [_filteredArray objectAtIndex:indexPath.row];
        cell.textLabel.text = city.name;
        cell.detailTextLabel.text = city.code;
    }
    else if (_segmentedControl.selectedSegmentIndex == 1) {
        Airport *airport = [_filteredArray objectAtIndex:indexPath.row];
        cell.textLabel.text = airport.name;
        cell.detailTextLabel.text = airport.code;
    }
    
    return cell;
}

//MARK: UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DataSourceType dataType = ((int)_segmentedControl.selectedSegmentIndex) + 1;
    [self.delegate selectPlace:[_filteredArray objectAtIndex:indexPath.row] withType:_placeType andDataType:dataType];
    [self.navigationController popViewControllerAnimated:YES];
}

//MARK: SearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        if (_segmentedControl.selectedSegmentIndex == 0) {
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(City *evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject.name containsString:searchText];
            }];
            self.filteredArray = [self.currentArray filteredArrayUsingPredicate:predicate];
        }
        if (_segmentedControl.selectedSegmentIndex == 1) {
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(Airport *evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject.name containsString:searchText];
            }];
            self.filteredArray = [self.currentArray filteredArrayUsingPredicate:predicate];
        }
    }
    else {
        self.filteredArray = self.currentArray;
    }
    [self.tableView reloadData];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations firstObject];
    if (location) {
        NSLog(@"%@", location);
    }
}



@end
