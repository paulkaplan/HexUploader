//
//  ORSAppDelegate.m
//  ORSSerialPortDemo
//
//  Created by Andrew R. Madsen on 6/27/12.
//	Copyright (c) 2012 Andrew R. Madsen (andrew@openreelsoftware.com)
//	
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//	
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "AppDelegate.h"
#import "ORSSerialPortManager.h"
#import "ORSSerialPort.h"

@implementation AppDelegate
@synthesize window = _window;

- (void)applicationWillTerminate:(NSNotification *)notification
{
	NSArray *ports = [[ORSSerialPortManager sharedSerialPortManager] availablePorts];
	for (ORSSerialPort *port in ports) { [port close]; }
    
}

-(void)awakeFromNib {
    NSLog(@"awaking from nib");

    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

-(NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    NSLog(@"drag enter");
    return NSDragOperationGeneric;
}
-(BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    NSLog(@"prepare for drag");
    NSPasteboard* pbrd = [sender draggingPasteboard];
    // Do something here.
    NSLog(@"%@", pbrd);
    return YES;
}

@end
