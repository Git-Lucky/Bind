//
//  HISPhoneNumberFormatter.h
//  Bind
//
//  Created by Tim Hise on 2/6/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HISPhoneNumberFormatter : NSObject

- (UITextField *)convertToPhoneFormat:(UITextField *)textField;

@end

