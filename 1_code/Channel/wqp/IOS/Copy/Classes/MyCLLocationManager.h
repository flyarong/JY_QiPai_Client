#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MyCLLocationManager : NSObject

+ (MyCLLocationManager *) shareManager;

- (void) startLocation:(void(^)(CLLocation *location)) complete;
- (void) stopLocation;
- (void) startMonitoringSignificantLocationChanges:(void(^)(CLLocation *location))complete;
- (void) stopMonitoringSignificatLocationChanges;

- (int) canLocation;
- (void) openLocation;

@end
