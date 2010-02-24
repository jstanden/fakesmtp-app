//
//  PrefsController.h
//  FakeSMTP
//
//  Created by Scott on 2/22/10.
//  Copyright 2010 Webgroup Media. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PrefsController : NSWindowController {
	IBOutlet NSMatrix *portSelection;
	IBOutlet NSTextField *customPort;
}
-(void)controlTextDidChange:(NSNotification *)aNotification;
@end

