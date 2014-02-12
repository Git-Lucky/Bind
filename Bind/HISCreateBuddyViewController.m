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
#import "HISPhoneNumberFormatter.h"

@interface HISCreateBuddyViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

{
    UITextField *_selectedTextField;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *twitterField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) HISLocalNotificationController *localNotificationController;

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
    
    [self processAndDisplayBackgroundImage:@"circlebackground.jpg"];

    self.localNotificationController = [[HISLocalNotificationController alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
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
    
    self.buddyToAdd.pic = editedImage;
    self.imageView.image = editedImage;
    self.imagePicker.titleLabel.text = @"";
    self.imagePicker.layer.borderWidth = 0;
    
    [HISCollectionViewDataSource makeRoundView:self.imageView];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark - Toolbar

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Text Field Delegate

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

- (void)keyboardWillShow:(NSNotification *)note
{
    NSValue *keyboardFrame = [note userInfo][UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameRect = keyboardFrame.CGRectValue;
    CGFloat keyboardHeight = keyboardFrameRect.size.height;
    
    if (CGRectGetMaxY(_selectedTextField.frame) > keyboardHeight) {
        //[uiview animate ...
        //self.containerView.frame = CGRectMake(0, keyboardHeight - 10, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//makes the phone field edit on the fly
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


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addedFriend"]) {
        if (self.buddyToAdd) {
            self.buddyToAdd.name = self.nameField.text;
            self.buddyToAdd.phone = self.phoneField.text;
            self.buddyToAdd.email = self.emailField.text;
            self.buddyToAdd.twitter = self.twitterField.text;
            self.buddyToAdd.affinity = 1;
            self.buddyToAdd.dateOfLastInteraction = [NSDate date];
            
            [self.localNotificationController scheduleNotificationsForBuddy:self.buddyToAdd];
            
            [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
        }
    }
}


@end
