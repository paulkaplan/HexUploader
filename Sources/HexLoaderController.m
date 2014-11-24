#import "HexLoaderController.h"
#import "ORSSerialPortManager.h"

@implementation HexLoaderController

@synthesize sendTextField = _sendTextField;
@synthesize openCloseButton = _openCloseButton;

@synthesize serialPortManager = _serialPortManager;
@synthesize serialPort = _serialPort;

@synthesize availableDevices = _availableDevices;
@synthesize availableBaudRates = _availableBaudRates;

- (id)init
{
    self = [super init];
    if (self)
	{
        self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
		self.availableBaudRates = [NSArray arrayWithObjects:
                                    [NSNumber numberWithInteger:300],
                                    [NSNumber numberWithInteger:1200],
                                    [NSNumber numberWithInteger:2400],
                                    [NSNumber numberWithInteger:4800],
                                    [NSNumber numberWithInteger:9600],
                                    [NSNumber numberWithInteger:14400],
                                    [NSNumber numberWithInteger:19200],
                                    [NSNumber numberWithInteger:28800],
                                    [NSNumber numberWithInteger:38400],
                                    [NSNumber numberWithInteger:57600],
                                    [NSNumber numberWithInteger:115200],
                                   nil];

        // Initialize devices from JSON manifest
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"devices" ofType:@"json"];
        NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
        
        self.availableDevices = [[NSMutableArray alloc] init];
        [[json objectForKey:@"devices"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Device *new_device = [[Device alloc] initWithDictionary:obj];
            [self.availableDevices addObject:new_device];
        }];
        
        self.device = [self.availableDevices objectAtIndex:5];
        
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(serialPortsWereConnected:) name:ORSSerialPortsWereConnectedNotification object:nil];
		[nc addObserver:self selector:@selector(serialPortsWereDisconnected:) name:ORSSerialPortsWereDisconnectedNotification object:nil];
        
        // Make sure arduino.app is installed
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        BOOL arduinoAppExists;
        [localFileManager fileExistsAtPath:@"/Applications/Arduino.app" isDirectory:&arduinoAppExists];
        
        if(!arduinoAppExists){
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Arduino application not found"];
            [alert setInformativeText:@"This application depends on the Arduino IDE. It must be installed to /Applications/Arduino"];
            [alert runModal];
        }

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
		[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
#endif
    }
    
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (IBAction)openOrClosePort:(id)sender
{
	self.serialPort.isOpen ? [self.serialPort close] : [self.serialPort open];
}

#pragma mark - ORSSerialPortDelegate Methods

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
	// After a serial port is removed from the system, it is invalid and we must discard any references to it
	self.serialPort = nil;
	self.openCloseButton.title = @"Open";
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
	NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
}


#pragma mark - NSUserNotificationCenterDelegate

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[center removeDeliveredNotification:notification];
	});
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return YES;
}

#endif

#pragma mark - Notifications

- (void)serialPortsWereConnected:(NSNotification *)notification
{
	NSArray *connectedPorts = [[notification userInfo] objectForKey:ORSConnectedSerialPortsKey];
	[self postUserNotificationForConnectedPorts:connectedPorts];
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
	NSArray *disconnectedPorts = [[notification userInfo] objectForKey:ORSDisconnectedSerialPortsKey];
	[self postUserNotificationForDisconnectedPorts:disconnectedPorts];
	
}

- (void)postUserNotificationForConnectedPorts:(NSArray *)connectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in connectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Connected", @"Serial Port Connected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was connected to your Mac.", @"Serial port connected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
#endif
}

- (void)postUserNotificationForDisconnectedPorts:(NSArray *)disconnectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in disconnectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Disconnected", @"Serial Port Disconnected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was disconnected from your Mac.", @"Serial port disconnected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
#endif
}

@synthesize receivedDataTextView = _receivedDataTextView;

 - (IBAction)sendFileButtonAction:(id)sender{
     
     self.receivedDataTextView.font = [NSFont fontWithName:@"Monaco" size:10];
     
     NSOpenPanel* openDlg = [NSOpenPanel openPanel];
     
     // Enable the selection of files in the dialog.
     [openDlg setCanChooseFiles:YES];
     
     // Enable the selection of directories in the dialog.
     [openDlg setCanChooseDirectories:YES];
     
     // Display the dialog.  If the OK button was pressed,
     // process the files.
     if ( [openDlg runModal] == NSOKButton )
     {

         NSString* fileName = [[openDlg URL] path];
         NSTask *task=[[NSTask alloc] init];
         
         // create pipe for output
         NSPipe *outputPipe = [[NSPipe alloc] init];
         task.standardOutput = outputPipe;
         task.standardError = outputPipe;
         
         [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
         
         [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){

             NSData *output = [[outputPipe fileHandleForReading] availableData];
             NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
             [self.receivedDataTextView.textStorage.mutableString appendString:[NSString stringWithFormat:@"%@", outStr]];
             
             // Scroll to end of outputText field
             NSRange range;
             range = NSMakeRange([self.receivedDataTextView.string length], 0);
             [self.receivedDataTextView setFont:[NSFont fontWithName:@"Monaco" size:10]];

             [self.receivedDataTextView scrollRangeToVisible:range];
             [self.receivedDataTextView setNeedsDisplay:YES];
             [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
         }];
         
         NSLog(@"");
         
         [task setLaunchPath:@"/Applications/Arduino.app/Contents/Resources/Java/hardware/tools/avr/bin/avrdude"];
         [task setCurrentDirectoryPath:@"/Applications/Arduino.app/Contents/Resources/Java/hardware/tools/avr/etc"];
        
         NSArray *args = [NSArray arrayWithObjects:
                            @"-F",
                            @"-Cavrdude.conf",
                            [NSString stringWithFormat:@"-p%@",self.device.device_type],
                            [NSString stringWithFormat:@"-c%@",self.device.programmer],
                            [NSString stringWithFormat:@"-P%@",self.serialPort.path],
                            @"-D",
                            [NSString stringWithFormat:@"%@%@", @"-Uflash:w:", fileName],
                          nil];
         
         [task setArguments:args];
         [task launch];
     }
}

- (void)setSerialPortManager:(ORSSerialPortManager *)manager
{
	if (manager != _serialPortManager)
	{
		[_serialPortManager removeObserver:self forKeyPath:@"availablePorts"];
		_serialPortManager = manager;
		NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
		[_serialPortManager addObserver:self forKeyPath:@"availablePorts" options:options context:NULL];
	}
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data {
    NSLog(@"%@", data);
}

- (void)setSerialPort:(ORSSerialPort *)port
{
	if (port != _serialPort)
	{
		[_serialPort close];
		_serialPort.delegate = nil;
		_serialPort = port;
		_serialPort.delegate = self;
	}
}

@end
