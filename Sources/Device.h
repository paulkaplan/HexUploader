//
//  Device.h
//  Hex Uploader
//
//  Created by Paul Kaplan on 11/11/13.
//  Copyright (c) 2013 Open Reel Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *chip;
@property (nonatomic, strong) NSString *device_type;
@property (nonatomic, strong) NSString *programmer;
@property (nonatomic, strong) NSString *baud;

-(id)initWithDictionary:(NSDictionary *)dict;
-(void)dealloc;

@end
