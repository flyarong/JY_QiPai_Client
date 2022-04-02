
#import "MyCLLocationManager.h"

static MyCLLocationManager *myCLLocationManager = nil;

@interface MyCLLocationManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, copy) void(^complete)(CLLocation *location);

@end

@implementation MyCLLocationManager

+ (MyCLLocationManager *) shareManager
{
	@synchronized (self)
	{
		if(myCLLocationManager == nil)
			myCLLocationManager = [[MyCLLocationManager alloc] init];
	}
	return myCLLocationManager;
}

- (id) init
{
	self = [super init];
	if(self)
	{
		if([CLLocationManager locationServicesEnabled] == YES)
		{
			_locationManager = [[CLLocationManager alloc] init];
			_locationManager.delegate = self;
			[_locationManager requestAlwaysAuthorization];
            [_locationManager requestWhenInUseAuthorization];
			_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = kCLDistanceFilterNone;
			_locationManager.pausesLocationUpdatesAutomatically = NO;
			_locationManager.activityType = CLActivityTypeFitness;
            
            _geocoder  = [[CLGeocoder alloc] init];
		}
	}
	return self;
}

- (void) startLocation:(void(^)(CLLocation *location))complete
{
	self.complete = complete;
	[_locationManager startUpdatingLocation];
	[_locationManager startUpdatingHeading];
}

- (void) stopLocation
{
	[_locationManager stopUpdatingLocation];
	[_locationManager stopUpdatingHeading];
}

- (void) startMonitoringSignificantLocationChanges:(void(^)(CLLocation *location))complete
{
    [_locationManager startMonitoringSignificantLocationChanges];
}
- (void) stopMonitoringSignificatLocationChanges
{
    [_locationManager stopMonitoringSignificantLocationChanges];
}

- (int) canLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            //玩家还没选择
            return 1;
        case kCLAuthorizationStatusDenied:
            //玩家未授权
            return 2;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorized:
            //玩家授权
            return 0;
        case kCLAuthorizationStatusRestricted:
            //家长限制
            return 2;
        default:
            return 0;
    }
}

- (void) openLocation
{
    [_locationManager requestWhenInUseAuthorization];
}

#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    
	if(self.complete)
		self.complete(location);
    
    CLLocationDegrees latitude = location.coordinate.latitude;
    CLLocationDegrees longitude = location.coordinate.longitude;
    
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if(error || placemarks.count <= 0) {
        } else {
            CLPlacemark *placemark = placemarks.firstObject;
            NSDictionary *addressDic = placemark.addressDictionary;
            NSString *state=[addressDic objectForKey:@"State"];
            NSString *city=[addressDic objectForKey:@"City"];
            NSString *subLocality=[addressDic objectForKey:@"SubLocality"];
            NSString *thoroughfare=[addressDic objectForKey:@"Thoroughfare"];
            
            NSString *detail;
            if(city != nil && ![city isEqualToString:@""])
                detail = city;
            else
                detail = state;
            if(subLocality != nil && ![subLocality isEqualToString:@""])
                detail = [detail stringByAppendingString:subLocality];
            if(thoroughfare != nil && ![thoroughfare isEqualToString:@""])
                detail = [detail stringByAppendingString:thoroughfare];
            
            NSString *strLatitude = [NSString stringWithFormat:@"%f", latitude];
            NSString *strLongitude = [NSString stringWithFormat:@"%f", longitude];
            NSString *result = strLatitude;
            result = [result stringByAppendingFormat:@"#%@#%@", strLongitude, detail];
            
            UnitySendMessage("SDK_callback", "OnGPS", [result cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        
        [self stopLocation];
    }];
}

@end
