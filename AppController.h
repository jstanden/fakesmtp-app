//
//  AppController.h
//  FakeSMTP
//
//  Created by Jeff Standen on 12/3/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SecurityFoundation/SFAuthorization.h>
#import "AsyncSocket.h"

@interface AppController : NSObject {
	AsyncSocket *listenSocket;
	NSMutableArray *connectedSockets;
	
	IBOutlet id startStopButton;
	IBOutlet id clearLogButton;
	IBOutlet id textView;

	BOOL isRunning, isInsideData;
}

-(IBAction)startStopServer:(id)sender;
-(IBAction)clearLogAction:(id)sender;
-(void)logInput:(NSString *)msg;
-(void)logOutput:(NSString *)msg;
-(void)scrollToBottom;

@end
