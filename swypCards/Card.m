//
//  Card.m
//  swypCards
//
//  Created by Alexander List on 1/28/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "Card.h"

@implementation Card
@dynamic coverImage;
@dynamic insideImage;
@dynamic signature;
@dynamic thumbnailImage;
@dynamic timeStamp;
@dynamic wasReceived;
@dynamic cardData;

@synthesize personName = _personName, personRank = _personRank, personImage;

-(void) awakeFromInsert{
	[super awakeFromInsert];
	self.timeStamp	=	[NSDate date];
}


-(void) setPersonImage:(UIImage *)image{
	[self setThumbnailImage:UIImageJPEGRepresentation(image, .8)];
}

-(void) awakeFromFetch{
	[super awakeFromFetch];
	[self setValuesFromSerializedData:[self cardData]];
}

-(void) setPersonName:(NSString *)personName{
	_personName = personName;
	[self setCardData:[self serializedDataValue]];
}

-(void) setPersonRank:(NSNumber *)personRank{
	_personRank = personRank;
	[self setCardData:[self serializedDataValue]];
}


-(NSData*)serializedDataValue{
	NSDictionary * saveDict		= [NSMutableDictionary dictionary];
	[saveDict setValue:[self personName] forKey:@"personName"];
	[saveDict setValue:[self personRank] forKey:@"personRank"];
	NSData * archive	=	[NSKeyedArchiver archivedDataWithRootObject:allCommittedValues];
	return archive;
}

-(void) setValuesFromSerializedData:(NSData*)serializedData{
	NSDictionary * decodedValues	=	[NSKeyedUnarchiver unarchiveObjectWithData:serializedData];
	for (NSString * key in decodedValues.allKeys){
		if ([[decodedValues valueForKey:key] isKindOfClass:[NSNull class]] == NO){
			if ([key isEqualToString:@"personName"]){
				[self setPersonImage:[decodedValues valueForKey:key]];
			}else if ([key isEqualToString:@"personRank"]){
				[self setPersonRank:[decodedValues valueForKey:key]];				
			}
		}
	}
}

@end
