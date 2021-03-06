//
//  DatePicker.h
//  whowasCNS
//
//  Created by Alexander Kohler on 8/12/14.
//  Copyright (c) 2014 Kohlerbear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePicker.h"
#import "TrainingMaxes.h"
#import "GAITrackedViewController.h"
#import <sqlite3.h>

@interface DatePicker : GAITrackedViewController
{
  
    
	IBOutlet UIDatePicker *picker;
	IBOutlet UITextField  *field;
    NSDate *pickerDate;
    NSString *pickerDateString;
    UILabel *currentPatternField;
    IBOutlet UILabel *existingProjectionErrorText;
}

-(IBAction)displayDate:(id)sender;


-(NSString *)formatDate:(NSString *)initialDate;

@property(nonatomic) NSDate *storedDate;
@property(nonatomic) NSArray *patternArray;
@property (nonatomic) sqlite3 *contactDB;

@end
