//
//  PrefsController.m
//  FakeSMTP
//
//  Created by Scott on 2/22/10.
//  Copyright 2010 Webgroup Media. All rights reserved.
//

#import "PrefsController.h"


@implementation PrefsController
- (void)controlTextDidChange:(NSNotification *)aNotification {
	NSString *port = [customPort stringValue];
	if ([port length] > 0) {
		[portSelection selectCellAtRow:2 column:0];
		[[NSUserDefaults standardUserDefaults] setValue:@"2" forKey:@"portSelection"];
	}
	
	int portNum = [customPort intValue];
	
	if (portNum < 0) {
		[customPort setStringValue:@"0"];
	}
	if (portNum > 65535) {
		[customPort setStringValue:@"65535"];
	}
	[[NSUserDefaults standardUserDefaults] setValue:port forKey:@"port"];
}
@end
