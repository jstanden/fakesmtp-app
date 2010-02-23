//
//  PrefsController.m
//  FakeSMTP
//
//  Created by Scott on 2/22/10.
//  Copyright 2010 Webgroup Media. All rights reserved.
//

#import "PrefsController.h"


@implementation PrefsController
- (void)textDidChange:(NSNotification *)aNotification {
	NSString *port = [customPort stringValue];
	NSLog(@"Method Called.");
	if ([port length] == 0) {
		[portSelection selectCellAtRow:2 column:0];
	}
}
@end
