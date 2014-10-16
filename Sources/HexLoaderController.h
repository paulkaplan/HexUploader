#import <Foundation/Foundation.h>
#import "ORSSerialPort.h"
#import "Device.h"

@class ORSSerialPortManager;

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_7)
@protocol NSUserNotificationCenterDelegate <NSObject>
@end
#endif

@interface HexLoaderController : NSObject <ORSSerialPortDelegate, NSUserNotificationCenterDelegate>

- (IBAction)openOrClosePort:(id)sender;

@property (unsafe_unretained) IBOutlet NSTextField *sendTextField;
@property (unsafe_unretained) IBOutlet NSTextView *receivedDataTextView;
@property (unsafe_unretained) IBOutlet NSButton *openCloseButton;

@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;

@property (nonatomic, strong) NSArray *availableBaudRates;
@property (nonatomic, strong) NSMutableArray *availableDevices;

@property (nonatomic, strong) Device *device;
@property (nonatomic, strong) NSTask *task;

@end
