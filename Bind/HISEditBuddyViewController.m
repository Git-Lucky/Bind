//
//  HISEditBuddyViewController.m
//  Bind
//
//  Created by Tim Hise on 2/4/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISEditBuddyViewController.h"
#import "HISCollectionViewDataSource.h"
#import "M13ProgressViewPie.h"

@interface HISEditBuddyViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *twitterField;
@property (weak, nonatomic) IBOutlet UIImageView *editedImageView;
@property (weak, nonatomic) IBOutlet UIButton *startPickerButton;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *progressViewPie;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation HISEditBuddyViewController

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
    
    [self setPlaceholdersWithBuddyDetails];
    
    [self.startPickerButton setTitle:@"Tap to Edit" forState:UIControlStateNormal];
    
    [HISCollectionViewDataSource makeRoundView:self.currentImageView];
    [HISCollectionViewDataSource makeRoundView:self.editedImageView];
    
    self.startPickerButton.layer.cornerRadius = self.startPickerButton.layer.frame.size.width / 2;
    self.startPickerButton.layer.masksToBounds = YES;
    
    self.progressViewPie.backgroundRingWidth = 0;
    [self.progressViewPie setProgress:self.buddy.affinity animated:NO];

    [self processAndDisplayBackgroundImage:@"BlueGradient.png"];
    
    self.scrollView.delegate = self;
    
    [self setTapGestureToDismissKeyboard];
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


- (void)setPlaceholdersWithBuddyDetails
{
    self.nameField.text = self.buddy.name;
    self.phoneField.text = self.buddy.phone;
    self.emailField.text = self.buddy.email;
    self.twitterField.text = self.buddy.twitter;
    
    if (self.buddy.pic) {
        self.currentImageView.image = self.buddy.pic;
    } else if (self.buddy.imagePath) {
        self.currentImageView.image = [UIImage imageWithContentsOfFile:self.buddy.imagePath];
    } else {
        self.startPickerButton.titleLabel.textColor = [UIColor blackColor];
        self.currentImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
    }
}

- (void)processAndDisplayBackgroundImage:(NSString *)imageName
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:imageName] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (IBAction)saveButton:(id)sender
{
    self.editedBuddy = [[HISBuddy alloc] init];
    
//    self.editedBuddy.name = self.nameField.text;
//    self.editedBuddy.phone = self.phoneField.text;
//    self.editedBuddy.email = self.emailField.text;
//    self.editedBuddy.twitter = self.twitterField.text;
    
    self.editedBuddy.affinity = self.buddy.affinity;
    self.editedBuddy.hasAnimated = YES;
    //hasChanged refers to affinity which has not changed here
    self.editedBuddy.hasChanged = YES;
    
    if (self.editedImageView.image) {
        self.editedBuddy.pic = self.editedImageView.image;
    } else {
        self.editedBuddy.pic = self.currentImageView.image;
    }

    if ([self.nameField.text isEqualToString:@""]) {
        self.editedBuddy.name = self.buddy.name;
    } else {
        self.editedBuddy.name = self.nameField.text;
    }
    
    if ([self.phoneField.text isEqualToString:@""]) {
        self.editedBuddy.phone = self.buddy.phone;
    } else {
        self.editedBuddy.phone = self.phoneField.text;
    }
    
    if ([self.emailField.text isEqualToString:@""]) {
        self.editedBuddy.email = self.buddy.email;
    } else {
        self.editedBuddy.email = self.emailField.text;
    }
    
    if ([self.twitterField.text isEqualToString:@""]) {
        self.editedBuddy.twitter = self.buddy.twitter;
    } else {
        self.editedBuddy.twitter = self.twitterField.text;
    }
    [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
    
    [self performSegueWithIdentifier:@"editedBuddy" sender:self];
}

#pragma mark - Photo Picker

- (IBAction)startPicker:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *picChoice = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Camera", @"Photo Library", nil];
        [picChoice showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    } else {
        UIActionSheet *picChoice = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Photo Library", nil];
        [picChoice showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Photo Library"]) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        return;
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.editedImageView.image = editedImage;
    self.startPickerButton.titleLabel.text = @"";
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)deleteFriend:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Friend" message:@"Are you sure you want to delete this friend?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([buttonTitle isEqualToString:@"Delete"]) {
        [self performSegueWithIdentifier:@"deleteBuddy" sender:self];
    } else {
        return;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = self.twitterField.frame.origin;
    
    CGFloat buttonHeight = self.twitterField.frame.size.height;
    
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

#pragma mark - Toolbar

- (IBAction)cancel:(id)sender {
    //TODO: add a warning if any info has changed
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"removedFriend"]) {
//        
//    }
//}
@end
