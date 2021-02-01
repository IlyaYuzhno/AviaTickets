//
//  TicketTableViewController.m
//  Tickets
//
//  Created by Ilya Doroshkevitch on 28.12.2020.
//

#import "TicketTableViewController.h"
#import "TicketTableViewCell.h"

#define TicketCellReuseIdentifier @"TicketCellIdentifier"


@interface TicketTableViewController ()

@property (nonatomic, strong) NSArray *tickets;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *dateTextField;

@end

@implementation TicketTableViewController {
    BOOL isFavorites;
    TicketTableViewCell *notificationCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (instancetype)initFavoriteTicketsController {
    self = [super init];
    if (self) {
        isFavorites = YES;
        self.tickets = [NSArray new];
        self.title = NSLocalizedString(@"favorites_tab", "");
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
        
        
        // Add Segmented Control
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Searched", @"From map"]];
        [_segmentedControl addTarget:self action:@selector(changeSource) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.tintColor = [UIColor blackColor];
        self.navigationItem.titleView = _segmentedControl;
        _segmentedControl.selectedSegmentIndex = 0;
        [self changeSource];
        
        // Add Date Picker
        [self addPicker];
        
    }
    return self;
}



- (instancetype)initWithTickets:(NSArray *)tickets {
    self = [super init];
    if (self)
    {
        _tickets = tickets;
        self.title = NSLocalizedString(@"tickets_title", "");
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerClass:[TicketTableViewCell class] forCellReuseIdentifier:TicketCellReuseIdentifier];
        
        // Add Date Picker
        [self addPicker];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (isFavorites) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        _tickets = [[CoreDataHelper sharedInstance] favorites];
        [self.tableView reloadData];
        
    }
}

// Add Date Picker
- (void)addPicker {

    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    _datePicker.preferredDatePickerStyle = UIDatePickerStyleInline;
    _datePicker.minimumDate = [NSDate date];
    
    _dateTextField = [[UITextField alloc] initWithFrame:self.view.bounds];
    _dateTextField.hidden = YES;
    _dateTextField.inputView = _datePicker;
    
    //UIToolbar *keyboardToolbar = [[UIToolbar alloc] init];
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonDidTap:)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    
    _dateTextField.inputAccessoryView = keyboardToolbar;
    [self.view addSubview:_dateTextField];

}



#pragma mark - Segmented Control method
- (void)changeSource {
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            _tickets = [[CoreDataHelper sharedInstance] favorites];
            [self.tableView reloadData];
            break;
        case 1:
            _tickets = [[CoreDataHelper sharedInstance] favoritesMapPrices];
            [self.tableView reloadData];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}



#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tickets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TicketCellReuseIdentifier forIndexPath:indexPath];
       if (isFavorites) {
           
           
           switch (_segmentedControl.selectedSegmentIndex) {
               case 0:
                   cell.favoriteTicket = [_tickets objectAtIndex:indexPath.row];
                   break;
               case 1:
                   cell.favoriteMapPriceTicket = [_tickets objectAtIndex:indexPath.row];
                   break;
               default:
                   break;
           }
           
           
           
           //cell.favoriteTicket = [_tickets objectAtIndex:indexPath.row];
           
           
           
           
       } else {
           cell.ticket = [_tickets objectAtIndex:indexPath.row];
       }
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
       return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140.0;
}



#pragma mark - Add and delete searched tickets in Favorites
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"actions_with_tickets", "") message:NSLocalizedString(@"actions_with_tickets_describe", "") preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *favoriteAction;
    
    if (isFavorites) {
        favoriteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"remove_from_favorite", "") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            
            switch (self->_segmentedControl.selectedSegmentIndex) {
                case 0:
                    [[CoreDataHelper sharedInstance] removeFromFavorite:[self->_tickets objectAtIndex:indexPath.row]];
                    [self.tableView reloadData];
                    break;
                case 1:
                    [[CoreDataHelper sharedInstance] removeFromFavoriteMapPrice:[self->_tickets objectAtIndex:indexPath.row]];
                    [self.tableView reloadData];
                    break;
                default:
                    break;
            }
            [self.tableView reloadData];

        }];
    } else {
        favoriteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"add_to_favorite", "") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[CoreDataHelper sharedInstance] addToFavorite:[self->_tickets objectAtIndex:indexPath.row]];
        }];
    }
    
    
    
    // Create Notification
    UIAlertAction *notificationAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"remind_me", "") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        self->notificationCell = [tableView cellForRowAtIndexPath:indexPath];
        [self->_dateTextField becomeFirstResponder];
        }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"close", "") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:favoriteAction];
    [alertController addAction:notificationAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)doneButtonDidTap:(UIBarButtonItem *)sender
{
    if (_datePicker.date && notificationCell) {
//        NSString *message = [NSString stringWithFormat:@"%@ - %@ за %@ руб.", notificationCell.ticket.from, notificationCell.ticket.to, notificationCell.ticket.price];
        
        NSString *message = [NSString stringWithFormat:@"%@ - %@ за %lld руб.", notificationCell.favoriteTicket.from, notificationCell.favoriteTicket.to, notificationCell.favoriteTicket.price];
        
        NSURL *imageURL;
        if (notificationCell.airlineLogoView.image) {
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/%@.png", notificationCell.ticket.airline]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                UIImage *logo = notificationCell.airlineLogoView.image;
                NSData *pngData = UIImagePNGRepresentation(logo);
                [pngData writeToFile:path atomically:YES];
                
            }
            imageURL = [NSURL fileURLWithPath:path];
        }
        
        Notification notification = NotificationMake(NSLocalizedString(@"ticket_reminder", ""), message, _datePicker.date, imageURL);
        [[NotificationCenter sharedInstance] sendNotification:notification];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Успешно" message:[NSString stringWithFormat:NSLocalizedString(@"notification_will_be_sent", ""), @" - %@", _datePicker.date] preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"close", "") style:UIAlertActionStyleCancel handler:nil];
        [self->_dateTextField resignFirstResponder];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    _datePicker.date = [NSDate date];
    notificationCell = nil;
    [self.view endEditing:YES];
    
}

@end
