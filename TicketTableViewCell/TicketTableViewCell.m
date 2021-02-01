//
//  TicketTableViewCell.m
//  Tickets
//
//  Created by Ilya Doroshkevitch on 28.12.2020.
//

#import "TicketTableViewCell.h"
#import <YYWebImage/YYWebImage.h>
#import "APIManager.h"

#define AirlineLogo(iata) [NSURL URLWithString:[NSString stringWithFormat:@"https://pics.avs.io/200/200/%@.png", iata]];

@interface TicketTableViewCell ()

//@property (nonatomic, strong) UIImageView *airlineLogoView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *placesLabel;
@property (nonatomic, strong) UILabel *dateLabel;



@end


@implementation TicketTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.layer.shadowColor = [[[UIColor blackColor] colorWithAlphaComponent:0.2] CGColor];
        self.contentView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        self.contentView.layer.shadowRadius = 10.0;
        self.contentView.layer.shadowOpacity = 1.0;
        self.contentView.layer.cornerRadius = 6.0;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _priceLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _priceLabel.font = [UIFont systemFontOfSize:24.0 weight:UIFontWeightBold];
        [self.contentView addSubview:_priceLabel];
        
        _airlineLogoView = [[UIImageView alloc] initWithFrame:self.bounds];
        _airlineLogoView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_airlineLogoView];
        
        _placesLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _placesLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightLight];
        _placesLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_placesLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _dateLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightRegular];
        [self.contentView addSubview:_dateLabel];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = CGRectMake(10.0, 10.0, [UIScreen mainScreen].bounds.size.width - 20.0, self.frame.size.height - 20.0);
    _priceLabel.frame = CGRectMake(10.0, 10.0, self.contentView.frame.size.width - 110.0, 40.0);
    _airlineLogoView.frame = CGRectMake(CGRectGetMaxX(_priceLabel.frame) + 10.0, 10.0, 80.0, 80.0);
    _placesLabel.frame = CGRectMake(10.0, CGRectGetMaxY(_priceLabel.frame) + 16.0, 300.0, 20.0);
    _dateLabel.frame = CGRectMake(10.0, CGRectGetMaxY(_placesLabel.frame) + 8.0, self.contentView.frame.size.width - 20.0, 20.0);
    
 
// MARK: Cell Views animations
    
    // Animate PriceLabel
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        self->_priceLabel.frame = CGRectMake(52.0, 12.0, self.contentView.frame.size.width - 100.0, 45.0);
    } completion: NULL];
    
    
    //Animate PlacesLabel
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionRepeat animations:^{
        self->_placesLabel.textColor = [UIColor greenColor];
        self->_placesLabel.transform = CGAffineTransformMakeScale(2, 2);
        self->_placesLabel.transform = CGAffineTransformIdentity;
    } completion:NULL];
    
    
    // Animate LogoView
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionRepeat animations:^{
        [self->_airlineLogoView setTransform:CGAffineTransformMakeRotation(M_PI)];
        self->_airlineLogoView.transform = CGAffineTransformIdentity;
    } completion:NULL];
    

    
    // Animate DateLabel
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionRepeat
                     animations:^{
        self->_dateLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
        
    }
                     completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionRepeat
                         animations:^{
            self->_dateLabel.transform = CGAffineTransformIdentity;
            
        } completion:NULL];
    }];
     
}

- (void)setTicket:(Ticket *)ticket {
    _ticket = ticket;
    
    _priceLabel.text = [NSString stringWithFormat:@"%@ руб.", ticket.price];
    _placesLabel.text = [NSString stringWithFormat:@"%@ - %@", ticket.from, ticket.to];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMMM yyyy hh:mm";
    _dateLabel.text = [dateFormatter stringFromDate:ticket.departure];
    NSURL *urlLogo = AirlineLogo(ticket.airline);
    [_airlineLogoView yy_setImageWithURL:urlLogo options:YYWebImageOptionSetImageWithFadeAnimation];
}


- (void)setFavoriteTicket:(FavoriteTicket *)favoriteTicket {
    _favoriteTicket = favoriteTicket;
    
    _priceLabel.text = [NSString stringWithFormat:@"%lld руб.", favoriteTicket.price];
    _placesLabel.text = [NSString stringWithFormat:@"%@ - %@", favoriteTicket.from, favoriteTicket.to];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMMM yyyy hh:mm";
    _dateLabel.text = [dateFormatter stringFromDate:favoriteTicket.departure];
    NSURL *urlLogo = AirlineLogo(favoriteTicket.airline);
    [_airlineLogoView yy_setImageWithURL:urlLogo options:YYWebImageOptionSetImageWithFadeAnimation];
}


- (void)setFavoriteMapPriceTicket:(FavoriteMapPrice *)favoriteMapPrice {
    _favoriteMapPriceTicket = favoriteMapPrice;
    
    _priceLabel.text = [NSString stringWithFormat:@"%lld руб.",_favoriteMapPriceTicket.price];
    _placesLabel.text = [NSString stringWithFormat:@"%@ - %@",_favoriteMapPriceTicket.from, _favoriteMapPriceTicket.to];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMMM yyyy hh:mm";
    _dateLabel.text = [dateFormatter stringFromDate:_favoriteMapPriceTicket.departure];
  
}




@end
