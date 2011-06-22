//
//  CoorZipAppDelegate.h
//  CoorZip
//
//  Created by Kevin Ko on 6/20/11.
//  Copyright 2011 ChocoCodes Dev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <YAJL/YAJL.h>
@interface CoorZipAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSTextField *statusLabel;
	IBOutlet NSTextField *zipcodes;
	
	IBOutlet NSTextField *latitudeText;
	IBOutlet NSTextField *longitudeText;
	
	NSString *directory;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSButton *executeButton;
	IBOutlet NSButton *loadButton;
	
}
@property (nonatomic, retain) IBOutlet NSTextField *latitudeText;
@property (nonatomic, retain) IBOutlet NSTextField *longitudeText;
@property (nonatomic, retain) IBOutlet NSButton *loadButton;
@property (nonatomic, retain) IBOutlet NSButton *executeButton;
@property (nonatomic, retain) IBOutlet NSProgressIndicator *progress;
@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet NSTextField *statusLabel;
@property (nonatomic, retain) IBOutlet NSTextField *zipcodes;

-(IBAction)parseIndividual:(NSButton *)button;

-(void)parseCSV:(NSString *)dir;
-(NSString *)parseJSON:(NSMutableDictionary *)dictionary;
-(void)parseJSONAdder:(NSMutableDictionary *)dictionary;
-(IBAction)openCSV:(NSButton *)button;
-(IBAction)executeConversion:(NSButton *)button;
@end
