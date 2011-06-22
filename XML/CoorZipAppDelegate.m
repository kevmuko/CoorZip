//
//  CoorZipAppDelegate.m
//  CoorZip
//
//  Created by Kevin Ko on 6/20/11.
//  Copyright 2011 ChocoCodes Dev. All rights reserved.
//

#import "CoorZipAppDelegate.h"

@implementation CoorZipAppDelegate

@synthesize window;
@synthesize zipcodes, statusLabel, progress, executeButton, loadButton;
@synthesize longitudeText, latitudeText;

-(IBAction)parseIndividual:(NSButton *)button {
	[button setState:NSOffState];
	
	[zipcodes setStringValue:@" "];
	
	//save in dictionary
	NSMutableDictionary *dictionaryCoord = [NSMutableDictionary dictionary];
	[dictionaryCoord setObject:[latitudeText stringValue] forKey:@"latitude"];
	[dictionaryCoord setObject:[latitudeText stringValue] forKey:@"longitude"];
	
	[self performSelectorInBackground:@selector(parseXML:) withObject:dictionaryCoord];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[zipcodes setEditable:YES];
}

-(IBAction)executeConversion:(NSButton *)button {
	[button setState:NSOffState];
	
	//reset text
	[zipcodes setStringValue:@""];
	
	//execute
	[self performSelectorInBackground:@selector(parseCSV:) withObject:directory];
}

-(void)parseCSV:(NSString *)dir {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dir]) {
		//load CSV
		NSMutableDictionary *dictionaryCoord = [NSMutableDictionary dictionary];
		NSString *stringCSV = [NSString stringWithContentsOfFile:dir encoding:NSUTF8StringEncoding error:NULL];
		NSArray *lines = [stringCSV componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
		
		//disable buttons
		[executeButton setEnabled:NO];
		[loadButton setEnabled:NO];
		
		//set the max as the progress bar
		int countValues = [lines count];
		[progress setMaxValue:(float)countValues];
		
		//start at 0
		[progress setDoubleValue:0];
		
		//disable result textfield (reduces lag)
		[zipcodes setEnabled:NO];
		
		//parse CSV and separate it by commas
		for (NSString *line in lines) {
			NSArray *values = [line componentsSeparatedByString:@","];
			if ([values count] != 2) {
				continue;
			}
			
			//save in dictionary
			[dictionaryCoord setObject:[values objectAtIndex:0] forKey:@"latitude"];
			[dictionaryCoord setObject:[values objectAtIndex:1] forKey:@"longitude"];
			
			//cool off = no memory overload
			usleep(400000);
			
			//start XML parsing in background
			[self parseXML:dictionaryCoord];
			
			//update progressbar by adding 1
			float newValue = [progress doubleValue] + 1;
			[progress setDoubleValue:newValue];
			
		}
		
		//enable result text field
		[zipcodes setEnabled:YES];
		
		//reset buttons
		[executeButton setEnabled:YES];
		[loadButton setEnabled:YES];
		
		//set the progress to maximum
		[progress setDoubleValue:(float)countValues];
		
		//find number of lines of the result
		NSString *string = [zipcodes stringValue];
		unsigned numberOfLines, index, stringLength = [string length];
		for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++)
			index = NSMaxRange([string lineRangeForRange:NSMakeRange(index, 0)]);
		
		//save to a file
		[[zipcodes stringValue] writeToFile:[NSHomeDirectory() stringByAppendingString:@"/Desktop/coorzip.txt"] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
		
		//update status
		NSString *finishedText = [NSString stringWithFormat:@"Status: %i lines saved to Desktop", numberOfLines];
		[statusLabel setStringValue:finishedText];
		
		//change color
		NSColor *darkGreen = [NSColor colorWithCalibratedRed:0.194 green:0.500 blue:0.000 alpha:1.000];
		[statusLabel setTextColor:darkGreen];
	}
	else {
		NSRunAlertPanel(@"Problem..!", @"This file does not exist or you have not selected a file yet!", @"Okay", nil, nil);
		[statusLabel setStringValue:@"Status: Not Loaded"];
		[statusLabel setTextColor:[NSColor orangeColor]];
	}
	[pool release];
}
-(void)parseXMLAdder:(NSString *)postal {
	//append to the end of the existing values in the zipcodes textfield
	NSString *string;
	if ([[zipcodes stringValue] isEqualToString:@""]) {
		string = [NSString stringWithFormat:@"%@", postal];
	}
	else {
		string = [[zipcodes stringValue] stringByAppendingFormat:@"\n%@", postal];
	}
	NSLog(@"Result: %@", string);
	[zipcodes setStringValue:string];
}
-(void)parseXML:(NSMutableDictionary *)dictionary {
	//parse XML resulted in the yahoo reverse geocoding api
	
	//make URL based on latitude and longitude
	NSString *url = [[NSString stringWithFormat:@"http://where.yahooapis.com/geocode?q=%@,+%@&gflags=R&appid=dj0yJmk9amVJdWpFaXU3YThIJmQ9WVdrOWVWWnRUWFZ3TldFbWNHbzlOVGN4TkRZM05EWXkmcz1jb25zdW1lcnNlY3JldCZ4PWM2", [dictionary objectForKey:@"latitude"], [dictionary objectForKey:@"longitude"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	//get source
	NSString *source = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:NULL];
	
	//get postal
	NSArray *array1 = [source componentsSeparatedByString: @"<postal>"];
	NSString *rest = (NSString*)[array1 lastObject];
	
	NSArray *array2  = [rest componentsSeparatedByString:@"</postal>"];
	NSString *postal = (NSString *)[array2 objectAtIndex:0];
	
	
	if (postal) {
	postal = [NSString stringWithFormat:@"%@ <Lat:%@ Lon:%@>", postal, [dictionary objectForKey:@"latitude"], [dictionary objectForKey:@"longitude"]];
	}	
	else {
		postal = [NSString stringWithFormat:@"Not Available"];
	}
	[self parseXMLAdder:postal];
}

-(IBAction)openCSV:(NSButton *)button {
	int result;
    NSArray *fileTypes = [NSArray arrayWithObject:@"csv"];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	
    [oPanel setAllowsMultipleSelection:NO];
    result = [oPanel runModalForDirectory:NSHomeDirectory()
									 file:nil types:fileTypes];
    if (result == NSOKButton) {
        NSArray *filesToOpen = [oPanel filenames];
        int i, count = [filesToOpen count];
        for (i=0; i<count; i++) {
            NSString *aFile = [filesToOpen objectAtIndex:i];
			
			//save the loaded directory for later use
			directory = aFile;
			
			//change status
			[statusLabel setStringValue:@"Status: Successfully Loaded"];
			NSColor *darkGreen = [NSColor colorWithCalibratedRed:0.194 green:0.500 blue:0.000 alpha:1.000];
			[statusLabel setTextColor:darkGreen];
		}
    }
}
@end
