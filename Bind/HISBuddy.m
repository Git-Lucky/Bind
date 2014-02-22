//
//  HISFriend.m
//  Bind
//
//  Created by Tim Hise on 2/1/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISBuddy.h"
#import "HISCollectionViewDataSource.h"

@implementation HISBuddy

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.imagePath = [aDecoder decodeObjectForKey:@"imagePath"];
    self.twitter = [aDecoder decodeObjectForKey:@"twitter"];
    self.email = [aDecoder decodeObjectForKey:@"email"];
    self.phone = [aDecoder decodeObjectForKey:@"phone"];
    self.priority = [[aDecoder decodeObjectForKey:@"priority"] intValue];
    self.affinity = [[aDecoder decodeObjectForKey:@"affinity"] floatValue];
    self.dateOfBirth = [aDecoder decodeObjectForKey:@"dateOfBirth"];
    self.dateOfBirthString = [aDecoder decodeObjectForKey:@"dateOfBirthString"];
    self.dateOfLastInteraction = [aDecoder decodeObjectForKey:@"date"];
    self.buddyID = [aDecoder decodeObjectForKey:@"buddyID"];
    
    //might not need this one
    self.previousAffinity = [[aDecoder decodeObjectForKey:@"previousAffinity"] floatValue];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.imagePath forKey:@"imagePath"];
    [aCoder encodeObject:self.twitter forKey:@"twitter"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.priority] forKey:@"priority"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.affinity] forKey:@"affinity"];
    [aCoder encodeObject:self.dateOfBirth forKey:@"dateOfBirth"];
    [aCoder encodeObject:self.dateOfBirthString forKey:@"dateOfBirthString"];
    [aCoder encodeObject:self.dateOfLastInteraction forKey:@"date"];
    [aCoder encodeObject:self.buddyID forKey:@"buddyID"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.previousAffinity] forKey:@"previousAffinity"];
}

- (void)setPic:(UIImage *)pic {
    
    _pic = pic;
    
    NSData *jpgData = UIImageJPEGRepresentation(_pic, .6);
    NSString *jpgPath = [[HISCollectionViewDataSource documentsDirectoryPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[[NSUUID UUID] UUIDString]]];
    [jpgData writeToFile:jpgPath atomically:YES];
    self.imagePath = jpgPath;
}

//- (void)setAffinity:(CGFloat)affinity
//{
//    _previousAffinity = _affinity;
//    _affinity = affinity;
//}

- (int)daysElapsed:(NSDate *)day1 and:(NSDate *)day2
{
    NSUInteger dayUnit = NSDayCalendarUnit;
    NSCalendar *aCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [aCalendar components:dayUnit fromDate:day1 toDate:day2 options:0];
    
    return [dateComponents day];
}



@end
