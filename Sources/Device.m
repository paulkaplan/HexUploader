//
//  Device.m
//  Hex Uploader
//
//  Created by Paul Kaplan on 11/11/13.
//

#import "Device.h"

@implementation Device

@synthesize name;
@synthesize chip;
@synthesize device_type;
@synthesize baud;
@synthesize programmer;

- (id)initWithDictionary:(NSDictionary *)dict {
    if(self = [super init]){
        self.name = [dict valueForKey:@"name"];
        self.chip = [dict valueForKey:@"chip"];
        self.device_type = [dict valueForKey:@"device"];
        self.baud = [dict valueForKey:@"baud"];
        self.programmer = [dict valueForKey:@"programmer"];
    }
    return self;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", self.name, self.chip];
}

@end
