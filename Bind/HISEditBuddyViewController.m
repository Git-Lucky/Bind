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
#import "IQActionSheetPickerView.h"
#import "HISFormTableViewCell.h"
#import "HISSwitchTableViewCell.h"
#import "HISLocalNotificationController.h"

@interface HISEditBuddyViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *editedImageView;
@property (weak, nonatomic) IBOutlet UIButton *startPickerButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *progressViewPie;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IQActionSheetPickerView *datePicker;
@property (strong, nonatomic) IBOutlet HISFormTableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet HISFormTableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet HISFormTableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet HISFormTableViewCell *twitterCell;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;
@property (strong, nonatomic) IBOutlet HISFormTableViewCell *birthdayCell;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (strong, nonatomic) IBOutlet HISSwitchTableViewCell *remindersCell;
@property (weak, nonatomic) IBOutlet UITableView *formTableView;
@property (strong, nonatomic) NSArray *formImages;


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
    
    UIImage *namebadge = [UIImage imageNamed:@"namebadge_icon_blue.png"];
    UIImage *phone = [UIImage imageNamed:@"phone_icon_blue.png"];
    UIImage *mail = [UIImage imageNamed:@"closed_mail_icon_blue.png"];
    UIImage *twitter = [UIImage imageNamed:@"twitter_icon_blue.png"];
    UIImage *birthday = [UIImage imageNamed:@"calendar_icon_blue.png"];
    UIImage *link = [UIImage imageNamed:@"bell_icon_blue.png"];
    self.formImages = [NSArray arrayWithObjects:namebadge, phone, mail, twitter, birthday, link, nil];
    
    [self setPlaceholdersWithBuddyDetails];
    
    [HISCollectionViewDataSource makeRoundView:self.currentImageView];
    [HISCollectionViewDataSource makeRoundView:self.editedImageView];
    
    self.startPickerButton.layer.cornerRadius = self.startPickerButton.layer.frame.size.width / 2;
    self.startPickerButton.layer.masksToBounds = YES;
    
    self.progressViewPie.backgroundRingWidth = 0;
    [self.progressViewPie setProgress:self.buddy.affinity animated:NO];

    [self processAndDisplayBackgroundImage:backgroundImage];
    
    self.scrollView.delegate = self;
    self.formTableView.delegate = self;
    self.formTableView.dataSource = self;
    
    [self setTapGestureToDismissKeyboard];
    [self configureTableView:self.formTableView];
    
    self.deleteButton.backgroundColor = [UIColor redColor];
    self.deleteButton.layer.cornerRadius = 5;
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

- (void)configureTableView:(UITableView *)tableView
{
    tableView.layer.cornerRadius = 12;
    tableView.layer.masksToBounds = YES;
}

- (void)setPlaceholdersWithBuddyDetails
{
    [self.startPickerButton setImage:[UIImage imageNamed:@"camera_icon_full"] forState:UIControlStateNormal];
    
    self.nameTextField.text = self.buddy.name;
    self.phoneTextField.text = self.buddy.phone;
    self.emailTextField.text = self.buddy.email;
    self.twitterTextField.text = self.buddy.twitter;
    self.birthdayTextField.text = self.buddy.dateOfBirthString;
    self.remindersCell.remindersSwitch.On = self.buddy.innerCircle;
    
    if (self.buddy.pic) {
        self.currentImageView.image = self.buddy.pic;
    } else if (self.buddy.imagePath) {
        self.currentImageView.image = [UIImage imageWithContentsOfFile:self.buddy.imagePath];
    } else {
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
    self.editedBuddy.innerCircle = self.remindersCell.remindersSwitch.isOn;
    
    HISLocalNotificationController *notifications = [[HISLocalNotificationController alloc] init];
    
    [notifications cancelNotificationsForBuddy:self.buddy];
    [notifications scheduleNotificationsForBuddy:self.editedBuddy];

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
    if ([textField.text isEqualToString:@"Phone Required"]) {
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

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint tableBottomLeftPoint = CGPointMake(self.formTableView.frame.origin.x, self.formTableView.frame.origin.y + self.formTableView.frame.size.height);
    
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

#pragma mark - Form TableView Datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    long row = indexPath.row;
    switch (row) {
        case 0:
            cell = self.nameCell;
            break;
        case 1:
            cell = self.phoneCell;
            break;
        case 2:
            cell = self.emailCell;
            break;
        case 3:
            cell = self.twitterCell;
            break;
        case 4:
            cell = self.birthdayCell;
            break;
        case 5:
            cell = self.remindersCell;
            break;
    }
    
    cell.imageView.image = [self.formImages objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
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

- (void)alert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Oops"
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"editedBuddy"]) {
        if (![self.nameTextField.text length] && ![self.phoneTextField.text length]) {
            self.nameTextField.text = @"Name Required";
            self.nameTextField.textColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
            self.phoneTextField.text = @"Phone Required";
            self.phoneTextField.textColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
            return NO;
        } else if (![self.phoneTextField.text length]) {
            self.phoneTextField.text = @"Phone Required";
            self.phoneTextField.textColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
            return NO;
        } else if (![self.nameTextField.text length]) {
            self.nameTextField.text = @"Name Required";
            self.nameTextField.textColor = [UIColor colorWithRed:1.000 green:0.453 blue:0.412 alpha:1.000];
            return NO;
        } else if ([self.nameTextField.text isEqualToString:@"Name Required"]) {
            return NO;
        } else if ([self.nameTextField.text isEqualToString:@"Phone Required"]) {
            return NO;
        }else {
            return YES;
        }
    }
    return NO;
}

@end
