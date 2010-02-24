//
//  AppController.m
//  FakeSMTP
//
//  Created by Jeff Standen on 12/3/08.
//  Copyright 2008 WebGroup Media, LLC.. All rights reserved.
//

#import "AppController.h"

#define WELCOME_MSG 0
#define ECHO_MSG 1

@implementation AppController

+(void)intialize {
    NSString *userDefaultsValuesPath;
    NSDictionary *userDefaultsValuesDict;

	
    // load the default values for the user defaults
    userDefaultsValuesPath=[[NSBundle mainBundle] pathForResource:@"UserDefaults"
														   ofType:@"plist"];
    userDefaultsValuesDict=[NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	
    // set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
	
}

-(id)init {
	if(self = [super init]) {
		listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
		connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
		
		isRunning = NO;
		isInsideData = NO;
	}
	
	return self;
}

-(void)awakeFromNib {
	
}

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {

}

-(void)scrollToBottom {
	NSScrollView *scrollView = [textView enclosingScrollView];
	NSPoint newScrollOrigin;
	
	if([[scrollView documentView] isFlipped])
		newScrollOrigin = NSMakePoint(0.0, NSMaxY([[scrollView documentView] frame]));
	else
		newScrollOrigin = NSMakePoint(0.0, 0.0);
	
	[[scrollView documentView] scrollPoint:newScrollOrigin];
}

-(void)logInput:(NSString *)msg {
	NSString *content = [NSString stringWithFormat:@"%@\n", msg];
	
	NSMutableDictionary *attrib = [NSMutableDictionary dictionaryWithCapacity:1];
	[attrib setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:content attributes:attrib];
	[as autorelease];
	
	[[textView textStorage] appendAttributedString:as];
	[self scrollToBottom];
}

-(void)logOutput:(NSString *)msg {
	NSString *content = [NSString stringWithFormat:@"%@", msg];
	
	NSMutableDictionary *attrib = [NSMutableDictionary dictionaryWithCapacity:1];
	[attrib setObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName];
	
	NSAttributedString *as = [[NSAttributedString alloc] initWithString:content attributes:attrib];
	[as autorelease];
	
	[[textView textStorage] appendAttributedString:as];
	[self scrollToBottom];
}

-(IBAction)clearLogAction:(id)sender {
	[[textView textStorage] setAttributedString:[NSAttributedString new]];
	//[[textView textStorage] deleteCharactersInRange:NSMakeRange(0, [textView length]-1)];
	//[textView reloadData];
}

-(IBAction)startStopServer:(id)sender {
	
//	AuthorizationRef authRef;
//	AuthorizationRights authRights;
//	AuthorizationFlags authFlags;
//	
//	authFlags = kAuthorizationFlagDefaults | 
//		kAuthorizationFlagPreAuthorize |
//		kAuthorizationFlagInteractionAllowed |
//		kAuthorizationFlagExtendRights;
//	
//	AuthorizationItem authItem[1];
//	authItem[0].name = "system.preferences"; // system.privilege.admin
//	authItem[0].valueLength = 0;
//	authItem[0].value = NULL;
//	authItem[0].flags = 0;
//	authRights.count = sizeof(authItem) / sizeof(authItem[0]);
//	authRights.items = authItem;
//	
//	OSStatus authStatus;
//	authStatus = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authRef);
//	
//	authStatus = AuthorizationCopyRights(authRef, &authRights, kAuthorizationEmptyEnvironment, authFlags, NULL);
//	
//	if(authStatus == errAuthorizationSuccess)
//		NSLog(@"Auth approved!");
//	else if(authStatus == errAuthorizationDenied)
//		NSLog(@"Oh no, auth denied!");
	
	//AuthorizationItem authItems = {kAuthorizationRightExecute, 0, NULL, 0};
	//AuthorizationRights authRights = {1, &authItems};
	int port = 0;
	[[NSUserDefaults standardUserDefaults] synchronize];
	int portSelection = [[NSUserDefaults standardUserDefaults] integerForKey:@"portSelection"];
	
	NSLog(@"portSelection: %i", portSelection);
	if(portSelection == 0) {
		port = 2525;
	} else if (portSelection == 1) {
		// auth it
		port = 25;
	} else {
		port = [[NSUserDefaults standardUserDefaults] integerForKey:@"port"];
		NSLog(@"Custom port: %i", port);	
	}
	
	NSLog(@"Listening on port: %i", port);	
	if(!isRunning) {
		if (port < 1000) {
			// we are loggin this sucker !
		}
		NSError *error = nil;
		if(![listenSocket acceptOnPort:port error:&error]) {
			NSLog(@"Error: %@", error);
			return;
		}
		
		NSLog(@"Running...");
		isRunning = YES;
		[startStopButton setLabel:@"Stop SMTP"];
		NSNumber *portNum = [NSNumber numberWithInt:port];
		NSString *startMsg = [NSString stringWithFormat:@"Started listening on port: %@\r\n", portNum];
		[self send:startMsg onSocket:listenSocket];
		
	} else { // stop time
		NSNumber *portNum = [NSNumber numberWithInt:port];
		NSString *startMsg = [NSString stringWithFormat:@"Stopped listening on port: %@\r\n", portNum];
		[self send:startMsg onSocket:listenSocket];
		[listenSocket disconnect];
		
		int i;
		for(i = 0; i < [connectedSockets count]; i++) {
			[[connectedSockets objectAtIndex:i] disconnect];
		}

		isRunning = NO;
		[startStopButton setLabel:@"Start SMTP"];
	}
}

-(void)send:(NSString *)msg onSocket:(AsyncSocket *) sock {
	NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
	
	[sock writeData:data withTimeout:-1 tag:0];
	[self logOutput:msg];
}

-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket {
	[newSocket enablePreBuffering];
	NSLog(@"Answered and pooled a connection.");
	[connectedSockets addObject:newSocket];
}

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
	NSString *welcomeMsg = @"220 Welcome to FakeSMTP 1.0!\r\n";
	[self send:welcomeMsg onSocket:sock];
	
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	
	if(msg) {
		[self logInput:msg];
		
		// QUIT
		if (isInsideData && [msg isEqualToString:@"."]) {
			[self send:@"250 Yeah okay, I'll drop that by if I'm in the area. No promises.\r\n" onSocket:sock];
			isInsideData = NO;

		} else if([msg isCaseInsensitiveLike:@"QUIT"]) {
			[self send:@"221 See ya!\r\n" onSocket:sock];
			[sock disconnect];
			return;
			
		} else if([msg length] >= 4 && [[msg substringToIndex:4] isCaseInsensitiveLike:@"HELO"]) {
			[self send:@"250 Do I know you?\r\n" onSocket:sock];

		} else if([msg length] >= 9 && [[msg substringToIndex:9] isCaseInsensitiveLike:@"MAIL FROM"]) {
			[self send:@"250 You sure send a lot of mail.  Take a break.\r\n" onSocket:sock];
			
		} else if([msg length] >= 7 && [[msg substringToIndex:7] isCaseInsensitiveLike:@"RCPT TO"]) {
			[self send:@"250 You're friends with _THEM_?!\r\n" onSocket:sock];
			
		} else if([msg length] >= 4 && [[msg substringToIndex:4] isCaseInsensitiveLike:@"DATA"]) {
			isInsideData = YES;
			[self send:@"354 You're going to talk no matter what I say, go ahead.\r\n" onSocket:sock];
						
		} else if (isInsideData) {
			// [TODO] Building DATA block
			
		} else {
			[self send:@"502 You confuse me.\r\n" onSocket:sock];
			
		}
		
	} else {
		// [TODO] Error
		NSLog(@"Error reading...");
	}
	
	// [TODO] Try to eliminate need for echo
	//[sock writeData:data withTimeout:-1 tag:0];
	[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
	//[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock {
	[connectedSockets removeObject:sock];
}

@end
