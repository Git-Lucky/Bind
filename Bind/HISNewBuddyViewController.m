//
//  HISNewBuddyViewController.m
//  Bind
//
//  Created by Tim Hise on 4/17/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISNewBuddyViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "HISCollectionViewDataSource.h"
#import "HISLocalNotificationController.h"
#import "Animator.h"


@interface HISNewBuddyViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *photoPickerButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *formBackground;
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (strong, nonatomic) HISLocalNotificationController *localNotificationController;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) NSString *phoneNumber;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *birthday;

@end

@implementation HISNewBuddyViewController

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
    
    self.formBackground.layer.cornerRadius = 5;
    [self.photoPickerButton setImage:[UIImage imageNamed:@"camera_icon_button.png"] forState:UIControlStateNormal];
    self.photoPickerButton.layer.cornerRadius = self.photoPickerButton.frame.size.height / 2;
    self.photoPickerButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.photoPickerButton.layer.borderWidth = 2;
    [self makeAutoConstraintsRetainAspectRatio:self.photoPickerButton];
    
    self.scrollView.delegate = self;
    [self setTapGestureToDismissKeyboard];
    
    [[UITextField appearance] setTintColor:[UIColor colorWithWhite:0.230 alpha:1.000]];
    
    [self processAndDisplayBackgroundImage:backgroundImage];
    
    self.localNotificationController = [HISLocalNotificationController new];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self deregisterFromKeyboardNotifications];
}

- (void)makeAutoConstraintsRetainAspectRatio:(UIView *)view;
{
    view.frame = CGRectMake(view.center.x-view.frame.size.height/2, view.frame.origin.y, view.frame.size.height, view.frame.size.height);
}

- (void)processAndDisplayBackgroundImage:(NSString *)imageName
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:imageName] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (HISBuddy *)buddyToAdd
{
    if (!_buddyToAdd) {
        _buddyToAdd = [[HISBuddy alloc] init];
    }
    return _buddyToAdd;
}

#pragma mark - TextFields

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"Name Required"]) {
        textField.text = @"";
        textField.textColor = [UIColor blackColor];
        
        [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)hideKeyboard
{
    [self.scrollView endEditing:YES];
}


#pragma mark - Scroll View Behavior

- (void)setTapGestureToDismissKeyboard
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint tableBottomLeftPoint = CGPointMake(self.formBackground.frame.origin.x, self.formBackground.frame.origin.y + self.formBackground.frame.size.height);
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(visibleRect, tableBottomLeftPoint)) {
        CGPoint scrollPoint = CGPointMake(0.0, tableBottomLeftPoint.y - visibleRect.size.height + 10);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    
}


#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}


#pragma mark - Photo Picker

- (IBAction)PhotoButton:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *picChoice = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
        [picChoice showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    } else {
        UIActionSheet *picChoice = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", nil];
        [picChoice showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    }
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
    
    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [self presentViewController:imagePicker animated:YES completion:^{
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.photoPickerButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.buddyToAdd.pic = editedImage;
    self.photoPickerButton.imageView.image = editedImage;
    self.photoPickerButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [HISCollectionViewDataSource makeRoundView:self.photoPickerButton.imageView];
    
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
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark - People Picker

- (IBAction)importFromContacts:(id)sender {
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
    return YES;
}

- (void)displayPerson:(ABRecordRef)person
{
    
    //name
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
    
    self.nameTextField.text = fullName;
    self.nameTextField.textColor = [UIColor blackColor];
    
    //phone number
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            if (phone) {
                self.phoneNumber = phone;
            }
        };
    }
    
    //emails
    ABMultiValueRef  emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSString *emailId = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, 0);//0 for "Home Email" and 1 for "Work Email".
    if (emailId) {
        self.email = emailId;
    }
    
    //birthday
    ABMutableMultiValueRef birthday = ABRecordCopyValue(person, kABPersonBirthdayProperty);
    if (birthday) {
        self.birthday = [NSDateFormatter localizedStringFromDate:CFBridgingRelease(birthday) dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    }
    
    NSData *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(person);
    UIImage *image = [UIImage imageWithData:imgData];
    UIImage *tempImage = nil;
    
    if (image.size.height > 1000 || image.size.width > 1000) {
        CGSize targetSize = CGSizeMake(image.size.width/6, image.size.height/5);
        UIGraphicsBeginImageContext(targetSize);
        
        CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
        thumbnailRect.origin = CGPointMake(0, 0);
        thumbnailRect.size.width = targetSize.width;
        thumbnailRect.size.height = targetSize.height;
        
        [image drawInRect:thumbnailRect];
        
        tempImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        image = tempImage;
    }
    
    if (image) {
        if ([self.photoPickerButton.imageView.image isEqual:[UIImage imageNamed:@"camera_icon_button.png"]]) {
            self.buddyToAdd.pic = image;
            [self.photoPickerButton setImage:image forState:UIControlStateNormal];
            [HISCollectionViewDataSource makeRoundView:self.photoPickerButton];
        }
//    } else {
//        self.photoPickerButton.imageView.image = [UIImage imageNamed:@"camera_icon_button.png"];
//        //        self.photoPickerButton.layer.cornerRadius = self.photoPickerButton.layer.frame.size.width / 2;
    }
}


#pragma mark - Navigation
- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    UIColor *redColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
    Animator *animator = [Animator new];
    if (![self.nameTextField.text length]) {
        self.nameTextField.text = @"Name Required";
        self.nameTextField.textColor = redColor;
        
        [self.doneButton setTitleColor:redColor forState:UIControlStateNormal];
        
        [animator shrink:self.nameTextField withDuration:.2];
        
        return NO;
    } else if ([self.nameTextField.text isEqualToString:@"Name Required"]) {
        [animator shrink:self.nameTextField withDuration:.2];
        return NO;
    } else {
        return YES;
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (self.buddyToAdd) {
        self.buddyToAdd.name = self.nameTextField.text;
        self.buddyToAdd.phone = self.phoneNumber;
        self.buddyToAdd.email = self.email;
        self.buddyToAdd.getsReminders = self.reminderSwitch.isOn;
        self.buddyToAdd.affinity = .75;
        self.buddyToAdd.dateOfLastCalculation = [NSDate date];
        self.buddyToAdd.hasChanged = YES;
        self.buddyToAdd.innerCircle = self.reminderSwitch.isOn;
        
        [self.localNotificationController scheduleNotificationsForBuddy:self.buddyToAdd];
        
        [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
    }
}

@end
