 //  TableDisplay.m
//  whowasCNS
//
//  Created by Alexander Kohler on 8/19/14.
//  Copyright (c) 2014 Kohlerbear. All rights reserved.
//

#import "TableDisplay.h"
#import "DateAndLiftProcessor.h"
#import "TableDisplayCell.h"
@interface TableDisplay ()

@end


@implementation TableDisplay
@synthesize dates = _dates;
@synthesize cycles = _cycles;
@synthesize firstLifts = _firstLifts;
@synthesize secondLifts = _secondLifts;
@synthesize thirdLifts = _thirdLifts;
@synthesize typeFreqs = _typeFreqs;
@synthesize numberOfCycles = _numberOfCycles;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        insertStatus = NO;
        changedView = NO;
        tableColorToggle = YES;
        self.dates = [[NSMutableArray alloc] init]; //initialize our date array
        self.cycles = [[NSMutableArray alloc] init];
        self.firstLifts = [[NSMutableArray alloc] init];
        self.secondLifts  = [[NSMutableArray alloc] init];
        self.thirdLifts = [[NSMutableArray alloc] init];
        self.typeFreqs = [[NSMutableArray alloc] init];
        for (int i = 0; i < 7; i++){
            kgBooleans[i] = YES;
            lbBooleans[i] = YES;
        }
        
        _curView = DEFAULT_V; //the fact that this isn't static may open up a can of worms
        Processor  = [[DateAndLiftProcessor alloc] init];
        
        trainingMaxStreamLabel.text = [NSString stringWithFormat:@"%@",_trainingMaxStream];
        
        
        [self openDB:YES];
        [Processor setStartingDate:_dateText];
        [Processor setRoundingFlag:_usingRounding];
        if (_usingLbs)
            [Processor setUnitMode:@"Lbs"];
        if (!_usingLbs)
            [Processor setUnitMode:@"Kgs"];
        [Processor parseDateString];
        [Processor setStartingLifts:_benchTM and:_squatTM and:_ohpTM and:_deadTM];
        [Processor calculateCycle:_numberOfCycles with:_patternArray withDBContext:_contactDB];
//        [self getData:@""];
        [self populateArrays:@""]; //initialize our date array
        [self openDB:NO];
        // Custom initialization
    }
    return self;
}

-(id) init
{
    self = [super init];
    if(self)
    {
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self init];
    //self.dates = [NSArray arrayWithObjects:@"9-01: Bench Triples: 430 440 450", @"9-02 Squat 5-3-1 120 140 170", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
}

-(void)openDB:(bool)yesOrNo
    {
    //check if a database exists, if not, create one
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"lifts.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    bool databaseAlreadyExists = [[NSFileManager defaultManager] fileExistsAtPath:_databasePath];
    
    const char *dbpath = [_databasePath UTF8String];
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        if (!databaseAlreadyExists)
        {
        char *errMsg;
        const char *sql_stmt =
        "CREATE TABLE IF NOT EXISTS LIFTS (liftDate text not null, Cycle integer, Lift text not null, Frequency text not null, First_Lift real, Second_Lift real, Third_Lift real, Training_Max integer, column_lbFlag integer)";
        
            if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                _status.text = @"Failed to create table";
            }
        }
        
        if (!yesOrNo)
            sqlite3_close(_contactDB);
        
    }
}


-(void) clearDB
{
        const char *dbpath = [_databasePath UTF8String];
    if(sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        const char *sql = "DELETE FROM lifts";
        sqlite3_stmt *statement;
        if(sqlite3_prepare_v2(_contactDB, sql,-1, &statement, NULL) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_DONE){
                // executed
            }else{
                //NSLog(@"%s",sqlite3_errmsg(db))
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(_contactDB);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)getData:(NSString*)whereClause
{	NSString *queryStatement = @"SELECT * FROM lifts";
    // You're gonna have to mess with whereclause syntax, may not just be a simple string like it was in android
	//liftDate text not null, Cycle integer, Lift text not null, Frequency text not null, First_Lift real, Second_Lift real, Third_Lift real, Training_Max integer, column_lbFlag integer
    if (![whereClause isEqualToString:@""])//if we do not have an empty query
    {
        queryStatement = [queryStatement stringByAppendingString:@" "];
        queryStatement = [queryStatement stringByAppendingString:whereClause];
    }
	
	
    // Prepare the query for execution
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_contactDB, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        // Create a new address from the found row
        while (sqlite3_step(statement) == SQLITE_ROW)
		{
			
            char *liftDate = (char*) sqlite3_column_text(statement, 0);
			int cycle = sqlite3_column_int(statement, 1);
			char *liftType = (char*) sqlite3_column_text(statement, 2);
			char *frequency = (char*) sqlite3_column_text(statement, 3);
			double firstlift = (double) sqlite3_column_double(statement, 4);
			double secondlift = (double) sqlite3_column_double(statement, 5);
			double thirdlift = (double) sqlite3_column_double(statement, 6);
			
			//these may be able to go into a single statement
            
			NSString *liftDateString   = [NSString stringWithUTF8String:liftDate];
			NSString* cycleString 	   = [NSString stringWithFormat:@"%i", cycle];
			NSString *liftTypeString   = [NSString stringWithUTF8String:liftType];
			NSString *frequencyString  = [NSString stringWithUTF8String:frequency];
			NSString* firstliftString  = [NSString stringWithFormat:@"%g", firstlift];
			NSString* secondliftString = [NSString stringWithFormat:@"%g", secondlift];
			NSString* thirdliftString  = [NSString stringWithFormat:@"%g", thirdlift];
			
			//training max is also something you will need to worry about for when you start supporting view existing database
			//createColumn:liftDate withCycle:cycle liftType:liftType freq:frequency first:firstlift second:secondlift third:thirdlift; //either createColumn or a addToBuffer method or the like
		}
        sqlite3_finalize(statement);
    }
}


/*
//fix your loop initialization stuff
-(void)populateArrays
{	NSString *queryStatement = @"SELECT * FROM lifts";

	
    // Prepare the query for execution
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(_contactDB, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        // Create a new address from the found row
        while (sqlite3_step(statement) == SQLITE_ROW)
		{
			//date
            char *liftDate = (char*) sqlite3_column_text(statement, 0);
            NSString *liftDateString   = [NSString stringWithUTF8String:liftDate];
            [self.dates addObject:liftDateString];
            
            //cycle
            int cycle = sqlite3_column_int(statement, 1);
            NSString* cycleString = [NSString stringWithFormat:@"Cycle: %i", cycle];
            [self.cycles addObject:cycleString];
            
            //lift type
            char *liftType = (char*) sqlite3_column_text(statement, 2);
            NSString *liftTypeString   = [NSString stringWithUTF8String:liftType];

            NSString* liftBuffer;
            
            //first ,second, third lift
            double firstlift = (double) sqlite3_column_double(statement, 4);
            double secondlift = (double) sqlite3_column_double(statement, 5);
			double thirdlift = (double) sqlite3_column_double(statement, 6);
            NSString* firstliftString;
            NSString* secondliftString;
            NSString* thirdliftString;
        char *frequency = (char*) sqlite3_column_text(statement, 3);
        NSString *frequencyString  = [NSString stringWithUTF8String:frequency];
            
            //may want to refactor and break this into another method 
          if ([frequencyString isEqualToString:@"5-5-5"])
          {
              firstliftString  = [NSString stringWithFormat:@"%gx5", firstlift];
              secondliftString = [NSString stringWithFormat:@"%gx5", secondlift];
              thirdliftString =  [NSString stringWithFormat:@"%gx5", thirdlift];
              liftBuffer = [NSString stringWithFormat:@"%@ - 5-5-5", liftTypeString];
          }
            else if ([frequencyString isEqualToString:@"3-3-3"])
            {
                firstliftString  = [NSString stringWithFormat:@"%gx3", firstlift];
                secondliftString = [NSString stringWithFormat:@"%gx3", secondlift];
                thirdliftString =  [NSString stringWithFormat:@"%gx3", thirdlift];
              liftBuffer = [NSString stringWithFormat:@"%@ - 3-3-3", liftTypeString];
            }
            
            else if ([frequencyString isEqualToString:@"5-3-1"])
            {
                firstliftString  = [NSString stringWithFormat:@"%gx5", firstlift];
                secondliftString = [NSString stringWithFormat:@"%gx3", secondlift];
                thirdliftString =  [NSString stringWithFormat:@"%gx1", thirdlift];
                liftBuffer = [NSString stringWithFormat:@"%@ - 5-3-1", liftTypeString];
            }
            
            [self.firstLifts addObject:firstliftString];
            [self.secondLifts addObject:secondliftString];
            [self.thirdLifts addObject:thirdliftString];
            [self.typeFreqs addObject:liftBuffer];
            
			
		}
        sqlite3_finalize(statement);
    }
}*/

-(void)populateArrays:(NSString*) whereClause
{
    NSString *queryStatement = @"SELECT * FROM lifts";
    // You're gonna have to mess with whereclause syntax, may not just be a simple string like it was in android
    //liftDate text not null, Cycle integer, Lift text not null, Frequency text not null, First_Lift real, Second_Lift real, Third_Lift real, Training_Max integer, column_lbFlag integer
    if (![whereClause isEqualToString:@""])//if we do not have an empty query
    {
        queryStatement = [queryStatement stringByAppendingString:@" "];
        queryStatement = [queryStatement stringByAppendingString:whereClause];
    }
    //View by options :
    //- Do a select statement to make sure that insertions/column names are appropriate
    //Show all - ""
    //LIFT only -  "where liftType = 'Bench', Squat, Deadlift, OHP, etc...
    //FREQ only - :where freq = '5-3-1' etc...
    // Prepare the query for execution
    //Test these declarations and ensure they are proper syntactically
    char *liftDate;
    sqlite3_stmt *statement;
    NSString *liftDateString;
    int cycle;
    NSString* cycleString;
    char *liftType;
    NSString *liftTypeString;
    NSString* liftBuffer;
    double firstlift;
    double secondlift;
    double thirdlift;
    NSString* firstliftString;
    NSString* secondliftString;
    NSString* thirdliftString;
    char *frequency;
    NSString *frequencyString;
    if (sqlite3_prepare_v2(_contactDB, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        // Create a new address from the found row
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            //date
            liftDate = (char*) sqlite3_column_text(statement, 0);
            liftDateString = [NSString stringWithUTF8String:liftDate];
            [self.dates addObject:liftDateString];
            //cycle
            cycle = sqlite3_column_int(statement, 1);
            cycleString = [NSString stringWithFormat:@"Cycle: %i", cycle];
            [self.cycles addObject:cycleString];
            //lift type
            liftType = (char*) sqlite3_column_text(statement, 2);
            liftTypeString = [NSString stringWithUTF8String:liftType];
            //first ,second, third lift
            firstlift = (double) sqlite3_column_double(statement, 4);
            secondlift = (double) sqlite3_column_double(statement, 5);
            thirdlift = (double) sqlite3_column_double(statement, 6);
            frequency = (char*) sqlite3_column_text(statement, 3);
            frequencyString = [NSString stringWithUTF8String:frequency];
            //may want to refactor and break this into another method
            if ([frequencyString isEqualToString:@"5-5-5"])
            {
                if (_usingRounding) //change me to proper logic
                {
                firstliftString = [NSString stringWithFormat:@"%gx5", firstlift];
                secondliftString = [NSString stringWithFormat:@"%gx5", secondlift];
                thirdliftString = [NSString stringWithFormat:@"%gx5", thirdlift];
                }
                else
                {
                firstliftString = [NSString stringWithFormat:@"%.2fx5", firstlift];
                secondliftString = [NSString stringWithFormat:@"%.2fx5", secondlift];
                thirdliftString = [NSString stringWithFormat:@"%.2fx5", thirdlift];
                }
                liftBuffer = [NSString stringWithFormat:@"%@ - 5-5-5", liftTypeString];
            }
            else if ([frequencyString isEqualToString:@"3-3-3"])
            {
                if (_usingRounding)
                {
                    firstliftString = [NSString stringWithFormat:@"%gx3", firstlift];
                    secondliftString = [NSString stringWithFormat:@"%gx3", secondlift];
                    thirdliftString = [NSString stringWithFormat:@"%gx3", thirdlift];
                }
                else
                {
                firstliftString = [NSString stringWithFormat:@"%.2fx3", firstlift];
                secondliftString = [NSString stringWithFormat:@"%.2fx3", secondlift];
                thirdliftString = [NSString stringWithFormat:@"%.2fx3", thirdlift];
                }
                liftBuffer = [NSString stringWithFormat:@"%@ - 3-3-3", liftTypeString];
            }
            else if ([frequencyString isEqualToString:@"5-3-1"])
            {
                if (_usingRounding)
                {
                firstliftString = [NSString stringWithFormat:@"%gx5", firstlift];
                secondliftString = [NSString stringWithFormat:@"%gx3", secondlift];
                thirdliftString = [NSString stringWithFormat:@"%gx1", thirdlift];
                }
                else
                {
                    firstliftString = [NSString stringWithFormat:@"%.2fx5", firstlift];
                    secondliftString = [NSString stringWithFormat:@"%.2fx3", secondlift];
                    thirdliftString = [NSString stringWithFormat:@"%.2fx1", thirdlift];
                }
                liftBuffer = [NSString stringWithFormat:@"%@ - 5-3-1", liftTypeString];
            }
            [self.firstLifts addObject:firstliftString];
            [self.secondLifts addObject:secondliftString];
            [self.thirdLifts addObject:thirdliftString];
            [self.typeFreqs addObject:liftBuffer];
        }
        sqlite3_finalize(statement);
    }
}

-(IBAction) showConfigMenu
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Config" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Adjust Lifts",@"View By", @"Reset", nil];
    [actionSheet setTag:1];
    [actionSheet showInView:self.view];
}

-(IBAction) showViewByMenu
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"View by..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Bench Only",@"Squat Only", @"OHP Only", @"Deadlift Only", @"5-5-5 only", @"3-3-3 only", @"5-3-1 only", nil];
    [actionSheet setTag:2];
    [actionSheet showInView:self.view];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 1)
    {
        switch(buttonIndex)
        {
            case 0:  // adjust lifts
                //DB clearing is currently the responsiblity of your magicial view disappeared method however we will have to see how that plays with view existing projection feature - remember to OPEN AND CLOSE THE DATABASE IF DECIDE TO CLEAR HERE AGAIN ;)
                [[self navigationController] popViewControllerAnimated:YES];//essentially hit back button : NOTE: NEED TO OVERRIDE THIS METHOD FOR TRADITIONAL
                break;
            case 1://View By
                [self showViewByMenu];
                break;
            case 2: //reset
                //clear table, go back to first screen - have an ARE YOU SURE popup
                break;
            }
    }
    
    else if (actionSheet.tag == 2)
    {
        [self openDB:YES];
        [self.dates removeAllObjects];
        [self.cycles removeAllObjects];
        [self.firstLifts removeAllObjects];
        [self.secondLifts removeAllObjects];
        [self.thirdLifts removeAllObjects];
        [self.typeFreqs removeAllObjects];
        switch(buttonIndex)
        {
            case 0:  // Bench only
                [self populateArrays:@"where lift = 'Bench'"];
                _curView = BENCH_V;
                break;
            case 1://Squat only
                [self populateArrays:@"where lift = 'Squat'"];
                _curView = SQUAT_V;
                break;
            case 2: //OHP only
                [self populateArrays:@"where lift = 'OHP'"];
                _curView = OHP_V;
                break;
            case 3: //Deadlift only
                [self populateArrays:@"where lift = 'Deadlift'"];
                _curView = DEAD_V;
                break;
            case 4: //5-5-5 only
                [self populateArrays:@"where Frequency = '5-5-5'"];
                _curView = FIVES_V;
                break;
            case 5: //3-3-3 only
                [self populateArrays:@"where Frequency = '3-3-3'"];
                _curView = THREES_V;
                break;
            case 6: //5-3-1 only
                [self populateArrays:@"where Frequency = '5-3-1'"];
                _curView = ONES_V;
                break;
        }
        [liftTableView reloadData];
        [self openDB:NO];
    }
    
}
                 
//for sake of back button override
 - (void)viewWillDisappear:(BOOL)animated
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self)
    {
        // View is disappearing because a new view controller was pushed onto the stack
        NSLog(@"New view controller was pushed"); //remove me eventually
    }
    else if ([viewControllers indexOfObject:self] == NSNotFound)
    {
        [self openDB:YES];
        [self clearDB];
        [self openDB:NO];
        NSLog(@"View controller was popped"); //remove me eventually
    }
}

//table display methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //A complete cycle is 12 lifts - 4 5-5-5s, 4 3-3-3s, and 4 5-3-1s
    if (_curView == BENCH_V || _curView == SQUAT_V || _curView == DEAD_V || _curView == OHP_V)
        return _numberOfCycles * 3;
    else if (_curView == FIVES_V || _curView == THREES_V || _curView == ONES_V)
        return _numberOfCycles * 4;
    else
    return (_numberOfCycles * 12);
}


/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _numberOfCycles;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EntryCell";
    
    TableDisplayCell *cell = [tableView
                                    dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TableDisplayCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    cell.date.text = [self.dates
                      objectAtIndex:[indexPath row]];
    cell.cycle.text = [self.cycles
                       objectAtIndex:[indexPath row]];
    cell.liftOne.text = [self.firstLifts objectAtIndex:[indexPath row]];
    cell.liftTwo.text = [self.secondLifts objectAtIndex:[indexPath row]];
    cell.liftThree.text = [self.thirdLifts objectAtIndex:[indexPath row]];
    cell.typeFreq.text = [self.typeFreqs objectAtIndex:[indexPath row]];
    
    //initialize our tableview variable
       return cell;
}









@end
