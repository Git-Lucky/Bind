//
//  HISNewFriendVC.m
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISCreateBuddyViewController.h"
#import "HISBuddyListViewController.h"
#import "HISCollectionViewDataSource.h"
#import "HISLocalNotificationController.h"
#import "IQActionSheetPickerView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface HISCreateBuddyViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, ABPeoplePickerNavigationControllerDelegate>

{
    UITextField *_selectedTextField;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *twitterField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *closenessBar;
@property (weak, nonatomic) IBOutlet UILabel *bestiesLabel;
@property (weak, nonatomic) IBOutlet UILabel *everyoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;
@property (strong, nonatomic) HISLocalNotificationController *localNotificationController;
@property (strong, nonatomic) IQActionSheetPickerView *datePicker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation HISCreateBuddyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imagePicker.layer.borderColor = [UIColor colorWithWhite:0.976 alpha:1.000].CGColor;
    self.imagePicker.layer.borderWidth = 2;
    self.imagePicker.layer.cornerRadius = self.imagePicker.layer.frame.size.width / 2;
    
    [self resizeTextField:self.phoneField];
    [self resizeTextField:self.nameField];
    [self resizeTextField:self.emailField];
    [self resizeTextField:self.twitterField];
    
    [self processAndDisplayBackgroundImage:backgroundImage];

    self.localNotificationController = [[HISLocalNotificationController alloc] init];
    
    self.scrollView.delegate = self;
    
    [self setTapGestureToDismissKeyboard];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    [self.closenessBar setTintColor:[UIColor whiteColor]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self deregisterFromKeyboardNotifications];
}

- (HISBuddy *)buddyToAdd
{
    if (!_buddyToAdd) {
        _buddyToAdd = [[HISBuddy alloc] init];
    }
    return _buddyToAdd;
}

- (void)processAndDisplayBackgroundImage:(NSString *)imageName
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:imageName] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (void)resizeTextField:(UITextField *)textField
{
    CGRect frameRect = textField.frame;
    frameRect.size.height = 200;
    textField.frame = frameRect;
}

#pragma mark - Photo Picker

- (IBAction)startPicker:(id)sender {
    
//    if (!self.buddy.imagePath) {
    
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIActionSheet *picChoice = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
            [picChoice showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
        } else {
            UIActionSheet *picChoice = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", nil];
            [picChoice showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
        }
//    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Photo Library"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        return;
    }
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
//    if ([info objectForKey:UIImagePickerControllerSourceTypeCamera]) {
//        <#statements#>
//    }
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:editedImage.CGImage orientation:(ALAssetOrientation)editedImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error )
     {
         NSLog(@"IMAGE SAVED TO PHOTO ALBUM");
         [library assetForURL:assetURL resultBlock:^(ALAsset *asset )
          {
              NSLog(@"we have our ALAsset!");
          }
                 failureBlock:^(NSError *error )
          {
              NSLog(@"Error loading asset");
          }];
     }];
    
    self.buddyToAdd.pic = editedImage;
    self.imageView.image = editedImage;
    self.imageView.layer.borderWidth = 2;
    self.imageView.layer.borderColor = [UIColor colorWithWhite:0.988 alpha:1.000].CGColor;
    self.imagePicker.titleLabel.text = @"";
    self.imagePicker.layer.borderWidth = 0;
    
    [HISCollectionViewDataSource makeRoundView:self.imageView];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - People Picker

- (IBAction)showPicker:(id)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    [self displayPerson:person];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)displayPerson:(ABRecordRef)person
{
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString* fullName;
    if (firstName && lastName) {
        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    } else if (lastName) {
        fullName = [NSString stringWithFormat:@"%@", lastName];
    } else if (firstName) {
        fullName = [NSString stringWithFormat:@"%@", firstName];
    } else {
        fullName = @"";
    }
    
    self.nameField.text = fullName;
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        self.phoneField.text = phone;
    }
        
    ABMutableMultiValueRef eMail  = ABRecordCopyValue(person, kABPersonEmailProperty);
    if(ABMultiValueGetCount(eMail) > 0) {
        eMail = (__bridge ABMutableMultiValueRef)((__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(eMail, 0));
        self.emailField.text = (__bridge NSString *)(eMail);
    }
    
    NSData *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(person);
    
    UIImage *image = [UIImage imageWithData:imgData];
    
    if (image) {
        self.buddyToAdd.pic = image;
        self.imageView.image = image;
        self.imageView.layer.borderWidth = 2;
        self.imageView.layer.borderColor = [UIColor colorWithWhite:0.988 alpha:1.000].CGColor;
        self.imagePicker.titleLabel.text = @"";
        self.imagePicker.layer.borderWidth = 0;
        
        [HISCollectionViewDataSource makeRoundView:self.imageView];
    }
}

#pragma mark - Date Picker

- (IBAction)datePickerButton:(id)sender {
    self.datePicker = [[IQActionSheetPickerView alloc] initWithTitle:@"Birthday" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    self.datePicker.buddy = self.buddyToAdd;
    [self.datePicker setTag:6];
    [self.datePicker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
    [self.datePicker showInView:self.view];
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    self.birthdayField.text = [titles componentsJoinedByString:@" - "];
    self.buddyToAdd.dateOfBirthString = self.birthdayField.text;
}


#pragma mark - Toolbar

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Segment

- (IBAction)closenessSegment:(id)sender {
    if (self.closenessBar.selectedSegmentIndex == 0) {
        self.bestiesLabel.hidden = NO;
        self.buddyToAdd.priority = 1;
    } else {
        self.bestiesLabel.hidden = YES;
    }
    
    if (self.closenessBar.selectedSegmentIndex == 1) {
        self.everyoneLabel.hidden = NO;
        self.buddyToAdd.priority = 2;
    } else {
        self.everyoneLabel.hidden = YES;
    }
}



#pragma mark - Text Field Delegate

//these next two methods go together to allow the user to hit next and go to next text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _selectedTextField = textField;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)hideKeyboard
{
    [self.scrollView endEditing:YES];
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    if ([textField.text isEqualToString:self.birthMonthField.text]) {
//        if (textField.text.length == 1) {
//            NSString *Ostring = @"0";
//            NSString *formattedString = [Ostring stringByAppendingString:textField.text];
//            textField.text = formattedString;
//        } else if (textField.text.length > 2) {
//            textField.text = @"";
//        } else if ([textField.text intValue] > 12) {
//            textField.text = @"";
//        }
//    }
//    
//    if ([textField.text isEqualToString:self.birthDayField.text]) {
//        if (textField.text.length == 1) {
//            NSString *Ostring = @"0";
//            NSString *formattedString = [Ostring stringByAppendingString:textField.text];
//            textField.text = formattedString;
//        } else if (textField.text.length > 2) {
//            textField.text = @"";
//        } else if ([textField.text intValue] > 31) {
//            textField.text = @"";
//        }
//    }
//}

//- (void)keyboardWillShow:(NSNotification *)note
//{
//    NSValue *keyboardFrame = [note userInfo][UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardFrameRect = keyboardFrame.CGRectValue;
//    CGFloat keyboardHeight = keyboardFrameRect.size.height;
//    
//    if (CGRectGetMaxY(_selectedTextField.frame) > keyboardHeight) {
//        //[uiview animate ...
//        //self.containerView.frame = CGRectMake(0, keyboardHeight - 10, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
//    }
//    
//}
//
//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

//makes the phone field edit on the fly

#pragma mark - Scroll View Behavior

- (void)setTapGestureToDismissKeyboard
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = self.birthdayField.frame.origin;
    
    CGFloat buttonHeight = self.birthdayField.frame.size.height;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight +10);
        
        [self.scrollView setContentOffset:scrollPoint animated:YES];
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([[textField description] isEqualToString:[self.phoneField description]]) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSArray *components = [newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        NSString *decimalString = [components componentsJoinedByString:@""];
        
        NSUInteger length = decimalString.length;
        BOOL hasLeadingOne = length > 0 && [decimalString characterAtIndex:0] == '1';
        
        if (length == 0 || (length > 10 && !hasLeadingOne) || (length > 11)) {
            textField.text = decimalString;
            return NO;
        }
        
        NSUInteger index = 0;
        NSMutableString *formattedString = [NSMutableString string];
        
        if (hasLeadingOne) {
            [formattedString appendString:@"1 "];
            index += 1;
        }
        
        if (length - index > 3) {
            NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 3)];
            [formattedString appendFormat:@"(%@) ",areaCode];
            index += 3;
        }
        
        if (length - index > 3) {
            NSString *prefix = [decimalString substringWithRange:NSMakeRange(index, 3)];
            [formattedString appendFormat:@"%@-",prefix];
            index += 3;
        }
        
        NSString *remainder = [decimalString substringFromIndex:index];
        [formattedString appendString:remainder];
        
        textField.text = formattedString;
        
        return NO;
    }
    
    
    return 1;
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}


#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"addedFriend"]) {
        if (![self.nameField.text length]) {
            [self alert:@"What is your friend's name?"];
            return NO;
        } else if (![self.phoneField.text length]) {
            [self alert:@"Did you forget their phone number?"];
            return NO;
        } else if (!(self.closenessBar.selectedSegmentIndex == 0 || self.closenessBar.selectedSegmentIndex == 1)) {
            [self alert:@"How close are you?"];
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addedFriend"]) {
        if (self.buddyToAdd) {
            self.buddyToAdd.name = self.nameField.text;
            self.buddyToAdd.phone = self.phoneField.text;
            self.buddyToAdd.email = self.emailField.text;
            self.buddyToAdd.twitter = self.twitterField.text;
            self.buddyToAdd.affinity = .75;
            self.buddyToAdd.dateOfLastInteraction = [NSDate date];
            self.buddyToAdd.hasChanged = YES;
            
            [self.localNotificationController scheduleNotificationsForBuddy:self.buddyToAdd];
            
            [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
        }
    }
}

- (void)alert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Oops"
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

@end
