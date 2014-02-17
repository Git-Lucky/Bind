//
//  HISPhoneNumberFormatter.m
//  Bind
//
//  Created by Tim Hise on 2/6/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISPhoneNumberFormatter.h"

@implementation HISPhoneNumberFormatter

//- (UITextField *)convertToPhoneFormat:(UITextField *)textField
//{
//    NSString *newString = textField.text;
//    NSArray *components = [newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
//    NSString *decimalString = [components componentsJoinedByString:@""];
//    
//    NSUInteger length = decimalString.length;
//    BOOL hasLeadingOne = length > 0 && [decimalString characterAtIndex:0] == '1';
//    
//    if (length == 0 || (length > 10 && !hasLeadingOne) || (length > 11)) {
//        textField.text = decimalString;
//        return NO;
//    }
//    
//    NSUInteger index = 0;
//    NSMutableString *formattedString = [NSMutableString string];
//    
//    if (hasLeadingOne) {
//        [formattedString appendString:@"1 "];
//        index += 1;
//    }
//    
//    if (length - index > 3) {
//        NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 3)];
//        [formattedString appendFormat:@"(%@) ",areaCode];
//        index += 3;
//    }
//    
//    if (length - index > 3) {
//        NSString *prefix = [decimalString substringWithRange:NSMakeRange(index, 3)];
//        [formattedString appendFormat:@"%@-",prefix];
//        index += 3;
//    }
//    
//    NSString *remainder = [decimalString substringFromIndex:index];
//    [formattedString appendString:remainder];
//    
//    textField.text = formattedString;
//    
//    return textField;
//}


@end
