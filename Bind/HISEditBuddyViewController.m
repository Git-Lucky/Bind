//
//  HISEditBuddyViewController.m
//  Bind
//
//  Created by Tim Hise on 2/4/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISEditBuddyViewController.h"
#import "HISCollectionViewDataSource.h"
#import "IQActionSheetPickerView.h"
#import "HISFormTableViewCell.h"
#import "HISSwitchTableViewCell.h"
#import "HISLocalNotificationController.h"

@interface HISEditBuddyViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *editedImageView;
@property (weak, nonatomic) IBOutlet UIButton *startPickerButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IQActionSheetPickerView *datePicker;
@property (weak, nonatomic) IBOutlet UIImageView *formBkg;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UISwitch *remindersSwitch;
@property (weak, nonatomic) IBOutlet UIView *importName;

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
    
//    UIImage *namebadge = [UIImage imageNamed:@"namebadge_icon_blue.png"];
//    UIImage *phone = [UIImage imageNamed:@"phone_icon_blue.png"];
//    UIImage *mail = [UIImage imageNamed:@"closed_mail_icon_blue.png"];
//    UIImage *twitter = [UIImage imageNamed:@"twitter_icon_blue.png"];
//    UIImage *birthday = [UIImage imageNamed:@"calendar_icon_blue.png"];
//    UIImage *link = [UIImage imageNamed:@"bell_icon_blue.png"];
    
    [self setPlaceholdersWithBuddyDetails];
    
    [HISCollectionViewDataSource makeRoundView:self.currentImageView];
    [HISCollectionViewDataSource makeRoundView:self.editedImageView];
    [HISCollectionViewDataSource makeRoundView:self.startPickerButton];
    [self makeViewRound:self.importName];
    
    self.currentImageView.layer.borderWidth = 2;
    self.currentImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    self.editedImageView.layer.borderWidth = 2;
    self.editedImageView.layer.borderColor = [[UIColor whiteColor] CGColor];

    [self processAndDisplayBackgroundImage:backgroundImage];

    self.scrollView.delegate = self;
    
    [self setTapGestureToDismissKeyboard];
    
    self.deleteButton.backgroundColor = [UIColor redColor];
    self.deleteButton.layer.cornerRadius = 5;
    self.formBkg.layer.cornerRadius = 5;
    
    [[UITextField appearance] setTintColor:[UIColor colorWithWhite:0.230 alpha:1.000]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    
    [self makeAutoConstraintsRetainAspectRatio:self.currentImageView];
    [self makeAutoConstraintsRetainAspectRatio:self.editedImageView];
    [self makeAutoConstraintsRetainAspectRatio:self.startPickerButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self deregisterFromKeyboardNotifications];
}

- (void)configureTableView:(UITableView *)tableView
{
    tableView.layer.cornerRadius = 12;
    tableView.layer.masksToBounds = YES;
}

- (void)makeAutoConstraintsRetainAspectRatio:(UIView *)view;
{
    view.frame = CGRectMake(view.center.x-view.frame.size.height/2, view.frame.origin.y, view.frame.size.height, view.frame.size.height);
}

- (void)setPlaceholdersWithBuddyDetails
{
    [self.startPickerButton setImage:[UIImage imageNamed:@"camera_icon_small"] forState:UIControlStateNormal];
    
    self.nameTextField.text = self.buddy.name;
    self.phoneTextField.text = self.buddy.phone;
    self.emailTextField.text = self.buddy.email;
    self.twitterTextField.text = self.buddy.twitter;
    self.birthdayTextField.text = self.buddy.dateOfBirthString;
    self.remindersSwitch.On = self.buddy.innerCircle;
    
    if (self.buddy.pic) {
        self.currentImageView.image = self.buddy.pic;
    } else if (self.buddy.imagePath) {
        self.currentImageView.image = [UIImage imageWithContentsOfFile:self.buddy.imagePath];
    } else {
        self.currentImageView.image = [UIImage imageNamed:@"Placeholder_female_superhero_c.png"];
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

- (void)makeViewRound:(UIView *)view {
    view.layer.cornerRadius = view.frame.size.height/2;
}

- (IBAction)saveButton:(id)sender
{
    self.editedBuddy = [[HISBuddy alloc] init];
    
    self.editedBuddy.affinity = self.buddy.affinity;
    self.editedBuddy.hasAnimated = YES;
    self.editedBuddy.hasChanged = YES;
    
    if (self.editedImageView.image) {
        self.editedBuddy.pic = self.editedImageView.image;
    } else {
        self.editedBuddy.pic = self.currentImageView.image;
    }

    if ([self.nameTextField.text isEqualToString:@""]) {
        self.editedBuddy.name = self.buddy.name;
    } else {
        self.editedBuddy.name = self.nameTextField.text;
    }
    
    if ([self.phoneTextField.text isEqualToString:@""]) {
        self.editedBuddy.phone = self.buddy.phone;
    } else {
        self.editedBuddy.phone = self.phoneTextField.text;
    }
    
    if ([self.emailTextField.text isEqualToString:@""]) {
        self.editedBuddy.email = self.buddy.email;
    } else {
        self.editedBuddy.email = self.emailTextField.text;
    }
    
    if ([self.twitterTextField.text isEqualToString:@""]) {
        self.editedBuddy.twitter = self.buddy.twitter;
    } else {
        self.editedBuddy.twitter = self.twitterTextField.text;
    }
    
    if ([self.birthdayTextField.text isEqualToString:@""]) {
        self.editedBuddy.dateOfBirthString = self.buddy.dateOfBirthString;
        self.editedBuddy.dateOfBirth = self.buddy.dateOfBirth;
    } else {
        self.editedBuddy.dateOfBirthString = self.birthdayTextField.text;
        self.editedBuddy.dateOfBirth = self.buddy.dateOfBirth;
    }
    self.editedBuddy.innerCircle = self.remindersSwitch.isOn;
    
    if (![self.nameTextField.text length]) {
        self.nameTextField.text = @"Name Required";
        self.nameTextField.textColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
    } else {
        HISLocalNotificationController *notifications = [[HISLocalNotificationController alloc] init];
        [notifications cancelNotificationsForBuddy:self.buddy];
        [notifications scheduleNotificationsForBuddy:self.editedBuddy];
        [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
        [self performSegueWithIdentifier:@"editedBuddy" sender:self];
    }
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

#pragma mark - Date Picker

- (IBAction)datePickerButton:(id)sender {
    self.datePicker = [[IQActionSheetPickerView alloc] initWithTitle:@"Birthday" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    self.datePicker.buddy = self.buddy;
    [self.datePicker setTag:6];
    [self.datePicker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
    [self.datePicker showInView:self.view];
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    self.birthdayTextField.text = [titles componentsJoinedByString:@" - "];
    self.buddy.dateOfBirthString = self.birthdayTextField.text;
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

#pragma mark - Text Field

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"Name Required"]) {
        textField.text = @"";
        textField.textColor = [UIColor blackColor];
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

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint tableBottomLeftPoint = CGPointMake(self.formBkg.frame.origin.x, self.formBkg.frame.origin.y + self.formBkg.frame.size.height);
    
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

//makes the phone field edit on the fly
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([[textField description] isEqualToString:[self.phoneTextField description]]) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSArray *components = [newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        NSString *decimalString = [components componentsJoinedByString:@""];
        
        NSUInteger length = decimalString.length;
        BOOL hasLeadingOne = length > 0 && [decimalString characterAtIndex:0] == '1';
        if (hasLeadingOne && range.location == 1) {
            hasLeadingOne = NO;
        }
        
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

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

#pragma mark - Toolbar

- (IBAction)cancel:(id)sender {
    //TODO: add a warning if any info has changed
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)alert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Oops"
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}
// seems this only works from nav bar buttons
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    if ([identifier isEqualToString:@"editedBuddy"]) {
//        if (![self.nameTextField.text length] && ![self.phoneTextField.text length]) {
//            self.nameTextField.text = @"Name Required";
//            self.nameTextField.textColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
//            self.phoneTextField.text = @"Phone Required";
//            self.phoneTextField.textColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
//            return NO;
//        } else if (![self.phoneTextField.text length]) {
//            self.phoneTextField.text = @"Phone Required";
//            self.phoneTextField.textColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
//            return NO;
//        } else if (![self.nameTextField.text length]) {
//            self.nameTextField.text = @"Name Required";
//            self.nameTextField.textColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
//            return NO;
//        } else if ([self.nameTextField.text isEqualToString:@"Name Required"]) {
//            return NO;
//        } else if ([self.nameTextField.text isEqualToString:@"Phone Required"]) {
//            return NO;
//        }else {
//            return YES;
//        }
//    }
//    return NO;
//}

@end
