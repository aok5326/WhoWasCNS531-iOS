//
//  DateAndLiftProcessor.m
//  whowasCNS
//
//  Created by Alexander Kohler on 8/27/14.
//  Copyright (c) 2014 Kohlerbear. All rights reserved.
//

#import "DateAndLiftProcessor.h"


//Constants
#define FIVE_1 .65
#define FIVE_2 .75
#define FIVE_3 .85

#define TRIPLE_1 .7
#define TRIPLE_2 .8
#define TRIPLE_3 .9

#define SINGLE_1 .75
#define SINGLE_2 .85
#define SINGLE_3 .95

#define UNIT_CONVERSION_FACTOR 2.20462

@implementation DateAndLiftProcessor
NSString * const FREQ5 = @"5-5-5";
NSString * const FREQ3 = @"3-3-3";
NSString * const FREQ1 = @"5-3-1";

//Guess this is how you make constructors in objective c...
-(id)init
{
    if( self = [super init] )
    {
    //day classification definition (Proper call syntax- String myString = Lift.Bench.name())

	//Currency definitions
    /////////////////////// fix me enumCURRENT_LIFT = [Lift ]
    NSString* DICKS = FREQ5;
    CURRENT_FREQUENCY = FREQ5;
	CURRENT_FREQUENCY = FREQ5;
    CURRENT_CYCLE = 1;
	int liftTrack = 0;//because we want to progress from bench (if we stayed at one bench would happen twice at the incrementing of the lift)
	int freqTrack = 2;//because we want to progress from fives (if we stayed at one freq would be fives twice when incrementing frequency)
        
    //initialize our date to some date ( I don't think it matters what.. guess we'll find out.)
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:7];
    [comps setMonth:7];
    [comps setYear:1977];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    CURRENT_DATE_CAL = [gregorian dateFromComponents:comps];
    
    df = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [df setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [df setDateFormat:@"MM-dd-yyyy"];
    }
    
    return self;
    
}


//enum conversion method
- (NSString*) convertToString:(Lift) whichLift {
    NSString *result = nil;
    
    switch(whichLift) {
        case Bench:
            result = @"Bench";
            break;
        case Squat:
            result = @"Squat";
            break;
        case OHP:
            result = @"OHP";
            break;
        case Deadlift:
            result = @"Deadlift";
            break;
        case REST:
            result = @"REST";
            break;
        default:
            result = @"Enum error!";
    }
    
    return result;
}


-(void) setStartingDate:(NSString*) myDate
{
    STARTING_DATE_STRING = myDate;
}

-(NSString*) getDate
{
    return CURRENT_DATE_STRING;
}


-(void) setDate:(NSString*) formattedDate
{
    CURRENT_DATE_STRING = formattedDate;
}


-(void) setStartingLifts:(NSString*) startingBench and: (NSString*) startingSquat and: (NSString*) startingOHP and: (NSString*) startingDead
{
    //error handling may have to be held here, but ideally before even grouping with intent.
    BENCH_TRAINING_MAX = [startingBench doubleValue];
    SQUAT_TRAINING_MAX = [startingSquat doubleValue];
    OHP_TRAINING_MAX = [startingOHP doubleValue];
    DEAD_TRAINING_MAX = [startingDead doubleValue];
    
    //for sake of getStartingXXX method (title output on ThirdScreen)
    //I don't think this is needed in iOS version.
}


//getter definitions

-(NSString*) getStartingDate
{
    return STARTING_DATE_STRING;
}

-(int) getCycle
{
    return CURRENT_CYCLE;
}

-(void) setCycle:(int) myCycle
{
    CURRENT_CYCLE = myCycle;
}

-(NSString*) getLiftType
{
    return CURRENT_LIFT;
}

-(NSString*) getFreq
{
    return CURRENT_FREQUENCY;
}

//need to implement a calculate5 function, calculate3 function, and calculate1 function
-(double) getFirstLift
{
    if (ROUND_FLAG)//if there is rounding wanted
    {
        if (UNIT_MODE_LBS)//lbs
            CURRENT_FIRST =  [self round:CURRENT_FIRST and:5];//return first lift rounded to nearest 5lb
        if (!UNIT_MODE_LBS)
            CURRENT_FIRST = [self roundkg:CURRENT_FIRST and:2.5];//return first lift rounded to nearest 1kg
    }
    
    
    return CURRENT_FIRST;
}

-(double) getSecondLift
{
    if (ROUND_FLAG)//if there is rounding wanted
    {
        if (UNIT_MODE_LBS)//lbs
            CURRENT_SECOND =  [self round:CURRENT_SECOND  and:5];//return first lift rounded to nearest 5lb
        if (!UNIT_MODE_LBS)
            CURRENT_SECOND = [self round:CURRENT_SECOND and:2.5];//return first lift rounded to nearest 2.5kg
    }
    
    return CURRENT_SECOND;
}

-(double) getThirdLift
{
    if (ROUND_FLAG)//if there is rounding wanted
    {
        if (UNIT_MODE_LBS)//lbs
            CURRENT_THIRD =  [self round:CURRENT_THIRD and:5];//return first lift rounded to nearest 5lb
        if (!UNIT_MODE_LBS)
            CURRENT_THIRD = [self round:CURRENT_THIRD  and:2.5];//return first lift rounded to nearest 2.5kg
    }
    
    return CURRENT_THIRD;
}

-(double) getBenchTM
{
    return BENCH_TRAINING_MAX;
}

-(double) getSquatTM
{
    return SQUAT_TRAINING_MAX;
}

-(double) getOHPTM
{
    return OHP_TRAINING_MAX;
}

-(double) getDeadTM
{
    return DEAD_TRAINING_MAX;
}

-(BOOL) getUnitMode
{
    return UNIT_MODE_LBS;
}


-(NSString*) getStartingBench
{
    return STARTINGBENCH;
}

-(NSString*) getStartingSquat
{
    return STARTINGSQUAT;
}

-(NSString*) getStartingOHP
{
    return STARTINGOHP;
}

-(NSString*) getStartingDead
{
    return STARTINGDEAD;
}


/*-(float) RoundTo: (float) number andRoundTo: (float) roundVal
{
    if (number >= 0) {
        return roundVal * floorf(number / roundVal + 0.5f);
    }
    else {
        return roundVal * ceilf(number / roundVal - 0.5f);
    }
}*/

//Setter definitions


-(void) setUnitMode:(NSString*) unitMode
{
    if ([unitMode isEqualToString:@"Lbs"])
           UNIT_MODE_LBS = YES;
    if ([unitMode isEqualToString:@"Kgs"])
        UNIT_MODE_LBS = NO;
}

-(void) setRoundingFlag:(bool) roundFlag
{
    ROUND_FLAG = roundFlag;
}


//calculation/misc definitions

//turns our STARTING_DATE_STRING into a more workable calendar object that we can do date arithmetic om
-(void) parseDateString
{
    df = [[NSDateFormatter alloc] init];
   // [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
   NSLocale *locale = [NSLocale currentLocale];
    [df setLocale:locale];
  //   NSString *timeZoneName = [[NSTimeZone localTimeZone] name];
 //   [df setTimeZone:[NSTimeZone timeZoneWithName:timeZoneName]];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    CURRENT_DATE_CAL = [df dateFromString:STARTING_DATE_STRING]; //parsed
 
    //TODO may need to format this guy
    
 
 
}

//day incrementing function
-(void) incrementDay
{
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    CURRENT_DATE_CAL = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
}



//Lift (and cycle if needed) incrementing function
//PERCENTAGE definitions
-(void) incrementLiftBasedOn:(NSArray*) myPattern whenCurrentLiftIs: (NSString*) currentLift
{
     //NAMES ASSIGNED ARE BASED ON ENUM::
    
    //#####****
    //enum Lift {Bench, Squat, OHP, Deadlift, REST};
    //liftTrack will have to be
    //need separate variable (static? like lifttrack that holds patternSize
    if (liftTrack + 1 < patternSize)
    {
		liftTrack++;
		CURRENT_LIFT = myPattern[liftTrack];//assign currentLift to be the next one in the patten
		//if it's a rest day that is taken care of in getCurrentTM by returning 0 which will be rooted out on insertion (onlys tms > 0)
    }
    else if ( (liftTrack + 1) == patternSize)
    {
        liftTrack = 0;//reset our liftTrack
        [self incrementFreq];
    }
    
    
}//end method incrementLift



//Method to increment frequency-(only called within incrementLift)
-(void) incrementFreq
{
    switch (freqTrack)
    {
		case 1:
			CURRENT_FREQUENCY = FREQ5;
			freqTrack++;
			break;
            
		case 2:
			CURRENT_FREQUENCY = FREQ3;
			freqTrack++;
			break;
            
		case 3:
			CURRENT_FREQUENCY = FREQ1;
			freqTrack = 1;
			break;
            
		default:
			CURRENT_FREQUENCY = @"incrementFreq ERROR:<";
            
    }
}//end method incrementfreq


-(void) incrementCycleAndUpdateTMs
{
    CURRENT_CYCLE = CURRENT_CYCLE + 1;
    if ([self getUnitMode])
    {
        BENCH_TRAINING_MAX = BENCH_TRAINING_MAX + 5; //this WILL HAVE TO CHANGE FOR KG MODE
        OHP_TRAINING_MAX = OHP_TRAINING_MAX + 5;
        SQUAT_TRAINING_MAX = SQUAT_TRAINING_MAX + 10;
        DEAD_TRAINING_MAX = DEAD_TRAINING_MAX + 10;
    }
    
    if (!([self getUnitMode]))
    {
        BENCH_TRAINING_MAX = BENCH_TRAINING_MAX + (5 / UNIT_CONVERSION_FACTOR);
        OHP_TRAINING_MAX = OHP_TRAINING_MAX + (5 / UNIT_CONVERSION_FACTOR);
        SQUAT_TRAINING_MAX = SQUAT_TRAINING_MAX + (10 / UNIT_CONVERSION_FACTOR);
        DEAD_TRAINING_MAX = DEAD_TRAINING_MAX + (10 / UNIT_CONVERSION_FACTOR);
    }
}


//to be called after a regular increment (just go to next day)


//Calculation methods

-(void) calculateFivesDay:(double) myLift
{
    CURRENT_FIRST  = myLift * FIVE_1;
    CURRENT_SECOND = myLift * FIVE_2;
    CURRENT_THIRD  = myLift * FIVE_3;
}


-(void) calculateTriplesDay:(double) myLift
{
    CURRENT_FIRST  = myLift * TRIPLE_1;
    CURRENT_SECOND = myLift * TRIPLE_2;
    CURRENT_THIRD  = myLift * TRIPLE_3;
}

-(void) calculateSingleDay:(double) myLift
{
    CURRENT_FIRST  = myLift * SINGLE_1;
    CURRENT_SECOND = myLift * SINGLE_2;
    CURRENT_THIRD  = myLift * SINGLE_3;
}

-(double) roundkg:(double) i and:(double) v //first argument is rounded,
{
    return v * floorf(i / v + 0.5f);
    //return (double) (Math.round(i/v) * v);
}

-(double) round:(double) i and:(int) v //first argument is rounded,
{
return v * floorf(i / v + 0.5f);
    //    return (double) (Math.round(i/v) * v);
}

-(void) initializePatternSize:(int) length
{
    patternSize = length;
}



//enum Lift {Bench, Squat, OHP, Deadlift, REST};
-(void) setCurrentLift:(NSString*) lift
{
    if ([lift isEqualToString:@"Bench"] || [lift isEqualToString:@"Squat"] || [lift isEqualToString:@"OHP"] || [lift isEqualToString:@"Deadlift"] || [lift isEqualToString:@"Rest"])
		CURRENT_LIFT = lift;
    else
        CURRENT_LIFT = @"ERROR";
}

-(double) getCurrentTM
{
        //since switch statements don't exist exist in objective c we're going back to cmpsc 121 for a bit :)
		 if ([CURRENT_LIFT isEqualToString:@"Bench"])
			return [self getBenchTM];
		else if ([CURRENT_LIFT isEqualToString:@"Squat"])
			return [self getSquatTM];
		else if ([CURRENT_LIFT isEqualToString:@"OHP"])
			return [self getOHPTM];
        else if ([CURRENT_LIFT isEqualToString:@"Deadlift"])
			return [self getDeadTM];
		else if ([CURRENT_LIFT isEqualToString:@"Rest"])
			return 0;
        else //"Default"
			return 999;	
}



    

@end