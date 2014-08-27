//
//  HISDetailsVC.m
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISBuddyDetailsViewController.h"
#import "HISEditBuddyViewController.h"
#import "M13ProgressViewPie.h"
#import "HISLocalNotificationController.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "MPNotificationView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

//*****************************************
// Icon and Animation Constants
    const int   ACTIVITIES_ICON_SIZE = 60;
    const float HYPOTENUSE = 75;
//*****************************************

@interface HISBuddyDetailsViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>{
    //Animation Vars
    UIDynamicAnimator *_animator;
    UIGravityBehavior *_gravity;
    UIDynamicBehavior  *_behavior;
    UISnapBehavior *_snap0o;
    UISnapBehavior *_snap45o;
    UISnapBehavior *_snap90o;
    UISnapBehavior *_snap135o;
    UISnapBehavior *_snap180o;
    BOOL _buttonsOut;
    CGPoint _pt0o_out;
    CGPoint _pt0o_in;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollingView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (nonatomic, readwrite) CGRect phoneButtonBounds;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *progressViewPie;
@property (weak, nonatomic) IBOutlet UIButton *composeMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *textMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) HISLocalNotificationController *localNotificationController;
@property (weak, nonatomic) IBOutletCollection(UILabel) NSArray *actionLabels;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *textView;
@property (weak, nonatomic) IBOutlet UIView *tweetView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIImageView *inputFieldImage;
@property (weak, nonatomic) IBOutlet UIImageView *inputFieldBkg;
@property (weak, nonatomic) IBOutlet UIButton *inputFieldSaveButton;
@property (weak, nonatomic) IBOutlet UIButton *inputFieldDismissButton;
@property (weak, nonatomic) IBOutlet UIView *inputFieldView;
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (weak, nonatomic) IBOutlet UILabel *importLabel;
@property (nonatomic) BOOL isPhoneField;

@property (strong, nonatomic) NSMutableArray *weMoves;

//@property (nonatomic) CGPoint phoneViewStart;
//@property (nonatomic) CGPoint textViewStart;
//@property (nonatomic) CGPoint tweetViewStart;
//@property (nonatomic) CGPoint emailViewStart;



// Animation View
@property (strong, nonatomic) UIView *vwMainBtn;
@property (strong, nonatomic) UIView *view0o;
@property (strong, nonatomic) UIView *view45o;
@property (strong, nonatomic) UIView *view90o;
@property (strong, nonatomic) UIView *view135o;
@property (strong, nonatomic) UIView *view180o;

@end

@implementation HISBuddyDetailsViewController

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
    
    [HISCollectionViewDataSource makeRoundView:self.imageView];
    
    [self processAndDisplayBackgroundImage:backgroundImage];
    
    [self makeAutoConstraintsRetainAspectRatio:self.imageView];
    [self makeAutoConstraintsRetainAspectRatio:self.progressViewPie];
    
    [self setUpWeButtonToAnimate];
    
    self.scrollingView.delegate = self;
    self.inputField.delegate = self;
    [self setTapGestureToDismissKeyboard];
    [[UITextField appearance] setTintColor:[UIColor colorWithWhite:0.230 alpha:1.000]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    [self registerForKeyboardNotifications];
    
    [self setOutletsWithBuddyDetails];
    self.titleLabel.text = self.buddy.name;
    
    self.weMoves = nil;
    
    [self setupContactButtons];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self deregisterFromKeyboardNotifications];
}

- (void)setOutletsWithBuddyDetails
{
    if (self.buddy.pic) {
        self.imageView.image = self.buddy.pic;
    } else if (self.buddy.imagePath) {
        self.imageView.image = [UIImage imageWithContentsOfFile:self.buddy.imagePath];
    } else {
        self.imageView.image = [UIImage imageNamed:@"Placeholder_female_superhero_c.png"];
    }
    
    [self.progressViewPie setProgress:self.buddy.affinity animated:YES];
}

- (void)makeButtonRoundWithWhiteBorder:(UIButton *)button
{
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.cornerRadius = button.frame.size.width / 2;
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

- (void)setupContactButtons
{
    NSString *phoneString = self.buddy.phone;
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    //No Phone Number
    if (phoneString.length < 7) {
        [self.phoneButton setAlpha:.5];
        [self.textMessageButton setAlpha:.5];
        [self.phoneButton removeTarget:self action:@selector(phoneButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.phoneButton addTarget:self action:@selector(showPhoneInputField) forControlEvents:UIControlEventTouchUpInside];
        [self.textMessageButton removeTarget:self action:@selector(textButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.textMessageButton addTarget:self action:@selector(showPhoneInputField) forControlEvents:UIControlEventTouchUpInside];
    } else {
    //Valid Phone Number
        [self.phoneButton setAlpha:1.0];
        [self.textMessageButton setAlpha:1.0];
        [self.phoneButton removeTarget:self action:@selector(showPhoneInputField) forControlEvents:UIControlEventTouchUpInside];
        [self.phoneButton addTarget:self action:@selector(phoneButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.textMessageButton removeTarget:self action:@selector(showPhoneInputField) forControlEvents:UIControlEventTouchUpInside];
        [self.textMessageButton addTarget:self action:@selector(textButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    //No Twitter name
    if (!self.buddy.twitter) {
        [self.twitterButton setAlpha:.5];
        [self.twitterButton removeTarget:self action:@selector(tweetButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.twitterButton addTarget:self action:@selector(showTwitterInputField) forControlEvents:UIControlEventTouchUpInside];
    } else {
    //Valid Twitter Name
        [self.twitterButton setAlpha:1.0];
        [self.twitterButton removeTarget:self action:@selector(showTwitterInputField) forControlEvents:UIControlEventTouchUpInside];
        [self.twitterButton addTarget:self action:@selector(tweetButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //No Email Address
    if (!self.buddy.email) {
        [self.composeMessageButton setAlpha:.5];
        [self.composeMessageButton removeTarget:self action:@selector(emailNow:) forControlEvents:UIControlEventTouchUpInside];
        [self.composeMessageButton addTarget:self action:@selector(showEmailInputField) forControlEvents:UIControlEventTouchUpInside];
    } else {
    //Valid Email Address
        [self.composeMessageButton setAlpha:1.0];
        [self.composeMessageButton removeTarget:self action:@selector(showEmailInputField) forControlEvents:UIControlEventTouchUpInside];
        [self.composeMessageButton addTarget:self action:@selector(emailNow:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.inputFieldBkg.layer.cornerRadius = 5;
    self.inputFieldSaveButton.layer.cornerRadius = 5;
    self.inputFieldDismissButton.layer.cornerRadius = 5;
    self.importButton.layer.cornerRadius = 5;
}

- (void)toggleWeButtonAndInputField
{
    //We Button Showing --> Going to Input Field
    if (!self.vwMainBtn.hidden) {
        self.inputFieldView.hidden = NO;
        self.inputFieldView.alpha = 0.0f;
        self.vwMainBtn.hidden = YES;
        self.view0o.hidden = YES;
        self.view135o.hidden = YES;
        self.view180o.hidden = YES;
        self.view45o.hidden = YES;
        self.view90o.hidden = YES;
        [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
            self.inputFieldView.alpha = 1.0f;
        } completion:^(BOOL finished) {
        }];
    } else {
    //Input Field Showing --> Going to We Button
        self.vwMainBtn.hidden = NO;
        self.vwMainBtn.alpha = 0.0f;
        //clears previous input
        self.inputField.text = @"";
        [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
            self.inputFieldView.alpha = 0.0f;
            self.vwMainBtn.alpha = 1.0f;
        } completion:^(BOOL finished) {
            self.inputFieldView.hidden = YES;
            self.view0o.hidden = NO;
            self.view135o.hidden = NO;
            self.view180o.hidden = NO;
            self.view45o.hidden = NO;
            self.view90o.hidden = NO;
        }];
    }
}

- (void)showPhoneInputField
{
    if (!self.vwMainBtn.hidden) {
        [self toggleWeButtonAndInputField];
    }
    self.isPhoneField = YES;
    self.inputFieldImage.image = [UIImage imageNamed:@"phone_icon_blue"];
    self.inputField.keyboardType = UIKeyboardTypePhonePad;
    self.inputField.placeholder = @"Phone";
    self.importButton.hidden = NO;
    self.importLabel.hidden = NO;
}

- (void)showTwitterInputField
{
    if (!self.vwMainBtn.hidden) {
        [self toggleWeButtonAndInputField];
    }
    self.isPhoneField = NO;
    self.inputFieldImage.image = [UIImage imageNamed:@"twitter_icon_blue"];
    self.inputField.keyboardType = UIKeyboardTypeTwitter;
    self.inputField.placeholder = @"@twitter";
    self.importButton.hidden = YES;
    self.importLabel.hidden = YES;
}

- (void)showEmailInputField
{
    if (!self.vwMainBtn.hidden) {
        [self toggleWeButtonAndInputField];
    }
    self.isPhoneField = NO;
    self.inputFieldImage.image = [UIImage imageNamed:@"closed_mail_icon_blue"];
    self.inputField.keyboardType = UIKeyboardTypeEmailAddress;
    self.inputField.placeholder = @"Email";
    self.importButton.hidden = NO;
    self.importLabel.hidden = NO;
}

#pragma mark - TextFields

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
    [self.scrollingView endEditing:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.isPhoneField) {
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


#pragma mark - Scroll View Behavior

- (void)setTapGestureToDismissKeyboard
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.scrollingView addGestureRecognizer:tapGesture];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint tableBottomLeftPoint = CGPointMake(self.inputFieldView.frame.origin.x, self.inputFieldView.frame.origin.y + self.inputFieldView.frame.size.height);
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, tableBottomLeftPoint)) {
        
        CGPoint scrollPoint = CGPointMake(0.0, tableBottomLeftPoint.y - visibleRect.size.height + 10);
        
        [self.scrollingView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    CGPoint returnPoint = CGPointMake(0.0, -60);
    
    [self.scrollingView setContentOffset:returnPoint animated:YES];
    
}


#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
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



#pragma mark - Animations on WE button

- (void)setUpWeButtonToAnimate
{
    // RPL Animation
    _buttonsOut = NO;
    float vwMainBtnSide = 60;
    float vwMainBtnX = (self.view.frame.size.width/2) - (vwMainBtnSide/2);
    float vwMainBtnY = (self.view.frame.size.height - vwMainBtnSide - 10); // 10 Padding
    
    // Create "We" View
    self.vwMainBtn = [[UIView alloc]initWithFrame:CGRectMake(vwMainBtnX, vwMainBtnY, vwMainBtnSide, vwMainBtnSide)];
    self.vwMainBtn.backgroundColor = [UIColor colorWithRed:0.144 green:0.615 blue:0.801 alpha:1.000];
    self.vwMainBtn.layer.masksToBounds = YES;
    self.vwMainBtn.layer.cornerRadius = vwMainBtnSide/2;
    //    self.vwMainBtn.layer.borderWidth = 2;
    
    // Create "We" Button
    UIButton *btnMain = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    [btnMain setTitle:@"We" forState:UIControlStateNormal];
    //    [btnMain setTitleColor:[UIColor colorWithWhite:0.215 alpha:1.000] forState:UIControlStateNormal];
    [btnMain setBackgroundImage:[UIImage imageNamed:@"we.png"] forState:UIControlStateNormal];
    [btnMain addTarget:self action:@selector(pressedMainButton:) forControlEvents:UIControlEventTouchUpInside];  // #pragma mark - selectors
    [btnMain setFrame:CGRectMake(0, 0, self.vwMainBtn.frame.size.width, self.vwMainBtn.frame.size.height)];
    [self.vwMainBtn addSubview:btnMain];
    
    // Create
    self.view0o = [[UIView alloc] initWithFrame:CGRectMake(self.vwMainBtn.frame.origin.x,
                                                           self.vwMainBtn.frame.origin.y,
                                                           ACTIVITIES_ICON_SIZE,
                                                           ACTIVITIES_ICON_SIZE)];
    _pt0o_in = CGPointMake(self.vwMainBtn.frame.origin.x, self.vwMainBtn.frame.origin.y);
    self.view0o.layer.masksToBounds = YES;
    self.view0o.layer.cornerRadius = ACTIVITIES_ICON_SIZE/2;
    [self.view addSubview:self.view0o];
    
    UIButton *btn0o = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn0o setBackgroundImage:[UIImage imageNamed:@"gift_icon.png"] forState:UIControlStateNormal];
    [btn0o addTarget:self action:@selector(pressed0oButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn0o setFrame:CGRectMake(0, 0, self.view0o.frame.size.width, self.view0o.frame.size.height)];
    btn0o.layer.cornerRadius = btn0o.layer.frame.size.height / 2;
    btn0o.layer.borderColor = [[UIColor whiteColor] CGColor];
    btn0o.layer.borderWidth = 2;
    [self.view0o addSubview:btn0o];
    
    self.view45o = [[UIView alloc] initWithFrame:CGRectMake(self.vwMainBtn.frame.origin.x,
                                                            self.vwMainBtn.frame.origin.y,
                                                            ACTIVITIES_ICON_SIZE,
                                                            ACTIVITIES_ICON_SIZE)];
    [self.view addSubview:self.view45o];
    
    UIButton *btn45o = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn45o setBackgroundImage:[UIImage imageNamed:@"social_icon.png"] forState:UIControlStateNormal];
    [btn45o addTarget:self action:@selector(pressed45oButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn45o setFrame:CGRectMake(0, 0, self.view45o.frame.size.width, self.view45o.frame.size.height)];
    btn45o.layer.cornerRadius = btn45o.layer.frame.size.height / 2;
    btn45o.layer.borderColor = [[UIColor whiteColor] CGColor];
    btn45o.layer.borderWidth = 2;
    [self.view45o addSubview:btn45o];
    
    self.view90o = [[UIView alloc] initWithFrame:CGRectMake(self.vwMainBtn.frame.origin.x,
                                                            self.vwMainBtn.frame.origin.y,
                                                            ACTIVITIES_ICON_SIZE,
                                                            ACTIVITIES_ICON_SIZE)];
    
    [self.view addSubview:self.view90o];
    
    UIButton *btn90o = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn90o setBackgroundImage:[UIImage imageNamed:@"besties_icon.png"] forState:UIControlStateNormal];
    [btn90o addTarget:self action:@selector(pressed90oButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn90o setFrame:CGRectMake(0, 0, self.view90o.frame.size.width, self.view90o.frame.size.height)];
    btn90o.layer.cornerRadius = btn90o.layer.frame.size.height / 2;
    btn90o.layer.borderColor = [[UIColor whiteColor] CGColor];
    btn90o.layer.borderWidth = 2;
    [self.view90o addSubview:btn90o];
    
    self.view135o = [[UIView alloc] initWithFrame:CGRectMake(self.vwMainBtn.frame.origin.x,
                                                             self.vwMainBtn.frame.origin.y,
                                                             ACTIVITIES_ICON_SIZE,
                                                             ACTIVITIES_ICON_SIZE)];
    
    [self.view addSubview:self.view135o];
    
    UIButton *btn135o = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn135o setBackgroundImage:[UIImage imageNamed:@"messaged_icon.png"] forState:UIControlStateNormal];
    [btn135o addTarget:self action:@selector(pressed135oButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn135o setFrame:CGRectMake(0, 0, self.view135o.frame.size.width, self.view135o.frame.size.height)];
    btn135o.layer.cornerRadius = btn90o.layer.frame.size.height / 2;
    btn135o.layer.borderColor = [[UIColor whiteColor] CGColor];
    btn135o.layer.borderWidth = 2;
    [self.view135o addSubview:btn135o];
    
    self.view180o = [[UIView alloc] initWithFrame:CGRectMake(self.vwMainBtn.frame.origin.x,
                                                             self.vwMainBtn.frame.origin.y,
                                                             ACTIVITIES_ICON_SIZE,
                                                             ACTIVITIES_ICON_SIZE)];
    
    [self.view addSubview:self.view180o];
    
    UIButton *btn180o = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn180o setBackgroundImage:[UIImage imageNamed:@"we_called_icon.png"] forState:UIControlStateNormal];
    [btn180o addTarget:self action:@selector(pressed180oButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn180o setFrame:CGRectMake(0, 0, self.view180o.frame.size.width, self.view180o.frame.size.height)];
    btn180o.layer.cornerRadius = btn90o.layer.frame.size.height / 2;
    btn180o.layer.borderColor = [[UIColor whiteColor] CGColor];
    btn180o.layer.borderWidth = 2;
    [self.view180o addSubview:btn180o];
    
    // Set starting points for the buttons under circle pic
    //    self.phoneViewStart = CGPointMake(self.phoneView.frame.origin.x + self.phoneView.frame.size.width/2, self.phoneView.frame.origin.y + self.phoneView.frame.size.height/2);
    //    self.textViewStart = CGPointMake(self.textView.frame.origin.x + self.textView.frame.size.width/2, self.textView.frame.origin.y + self.textView.frame.size.height/2);
    //    self.tweetViewStart = CGPointMake(self.tweetView.frame.origin.x + self.tweetView.frame.size.width/2, self.tweetView.frame.origin.y + self.tweetView.frame.size.height/2);
    //    self.emailViewStart = CGPointMake(self.emailView.frame.origin.x + self.emailView.frame.size.width/2, self.emailView.frame.origin.y + self.emailView.frame.size.height/2);
    
    // Add "We" View
    [self.view addSubview:self.vwMainBtn];
    
    // Dynamics
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

#pragma mark - Action Buttons

- (IBAction)phoneButton:(id)sender
{
    NSString *phoneString = self.buddy.phone;
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneString]]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneString]]];
        [self addAffinity:.20];
    } else {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't have a phone!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
}

- (IBAction)tweetButton:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *address = [NSString stringWithFormat:@"%@ ",self.buddy.twitter];
        [tweetSheet setInitialText:address];
        [self presentViewController:tweetSheet animated:YES completion:^{
            
        }];
        if (tweetSheet.completionHandler) {
            [self addAffinity:.1];
        }
    } else {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device is not setup for twitter" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    

}

//- (IBAction)facebookButton:(id)sender {
//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
//        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//        
//        [controller setInitialText:@"Hello"];
//        [self presentViewController:controller animated:YES completion:Nil];
//    }
//}

- (IBAction)textButton:(id)sender
{
    [self showSMS:nil];
}

- (IBAction)saveButton:(id)sender {
    if (self.inputFieldImage.image == [UIImage imageNamed:@"phone_icon_blue"]) {
        self.buddy.phone = self.inputField.text;
    } else if (self.inputFieldImage.image == [UIImage imageNamed:@"twitter_icon_blue"]) {
        if (self.inputField.text.length > 0 && [self.inputField.text hasPrefix:@"@"]) {
            self.buddy.twitter = self.inputField.text;
        }
    } else if (self.inputFieldImage.image == [UIImage imageNamed:@"closed_mail_icon_blue"]) {
        if (self.inputField.text.length > 0) {
             self.buddy.email = self.inputField.text;
        }
    }
    
    [self toggleWeButtonAndInputField];
    [self setupContactButtons];
    
}

- (IBAction)dismissButton:(id)sender {
    [self toggleWeButtonAndInputField];
}

- (IBAction)importButton:(id)sender {
    [self importFromContacts:nil];
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
    return NO;
}

- (void)displayPerson:(ABRecordRef)person
{
    
    //name
    if ([self.inputField.placeholder isEqualToString:@"Phone"]) {
        //phone number
        NSString* phone = nil;
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumbers) > 0) {
            for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                if (phone) {
                    self.buddy.phone = phone;
                }
            };
        }
    }
    
    if ([self.inputField.placeholder isEqualToString:@"Email"]) {
        //emails
        ABMultiValueRef  emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSString *emailId = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, 0);//0 for "Home Email" and 1 for "Work Email".
        if (emailId) {
            self.buddy.email = emailId;
        }
    }
}

#pragma mark - Selector - Activity Buttons

-(void)pressedMainButton:(UIButton *)sender
{
    if(!_buttonsOut) {
        [_animator removeAllBehaviors];
        
        float adjacentLength = HYPOTENUSE*0.78539816339; // constant for (45degrees*PI/180)
        float oppositeLength = HYPOTENUSE*0.78539816339;
        
        _pt0o_out = CGPointMake(self.vwMainBtn.frame.origin.x+HYPOTENUSE+ACTIVITIES_ICON_SIZE/4+ACTIVITIES_ICON_SIZE/2 + 4, self.vwMainBtn.frame.origin.y);
        _snap0o = [[UISnapBehavior alloc] initWithItem:self.view0o snapToPoint:_pt0o_out];

        CGPoint pt45o = CGPointMake(self.vwMainBtn.frame.origin.x+adjacentLength+ACTIVITIES_ICON_SIZE/2 + 5,
                                    self.vwMainBtn.frame.origin.y-oppositeLength);
        _snap45o = [[UISnapBehavior alloc] initWithItem:self.view45o snapToPoint:pt45o];

        CGPoint pt90o = CGPointMake(self.vwMainBtn.frame.origin.x+ACTIVITIES_ICON_SIZE/2,
                                    self.vwMainBtn.frame.origin.y-HYPOTENUSE);
        _snap90o = [[UISnapBehavior alloc] initWithItem:self.view90o snapToPoint:pt90o];
        
        CGPoint pt135o = CGPointMake(self.vwMainBtn.frame.origin.x-adjacentLength+ACTIVITIES_ICON_SIZE/2 - 5,
                                    self.vwMainBtn.frame.origin.y-oppositeLength);
        _snap135o = [[UISnapBehavior alloc] initWithItem:self.view135o snapToPoint:pt135o];
        
        CGPoint pt180o = CGPointMake(self.vwMainBtn.frame.origin.x-adjacentLength-ACTIVITIES_ICON_SIZE/2+ACTIVITIES_ICON_SIZE/2 - 4, self.vwMainBtn.frame.origin.y);
        _snap180o = [[UISnapBehavior alloc] initWithItem:self.view180o snapToPoint:pt180o];
        
//        UISnapBehavior *phoneSnap = [[UISnapBehavior alloc] initWithItem:self.phoneView snapToPoint:self.imageView.center];
//        UISnapBehavior *textSnap = [[UISnapBehavior alloc] initWithItem:self.textView snapToPoint:self.imageView.center];
//        UISnapBehavior *tweetSnap = [[UISnapBehavior alloc] initWithItem:self.tweetView snapToPoint:self.imageView.center];
//        UISnapBehavior *emailSnap = [[UISnapBehavior alloc] initWithItem:self.emailView snapToPoint:self.imageView.center];
        
        [_snap0o setDamping:0.5];
        [_snap45o setDamping:0.5];
        [_snap90o setDamping:0.5];
        [_snap135o setDamping:0.5];
        [_snap180o setDamping:0.5];
//        [phoneSnap setDamping:1];
//        [tweetSnap setDamping:1];
//        [textSnap setDamping:1];
//        [emailSnap setDamping:1];
        
        [_animator addBehavior:_snap0o];
        [_animator addBehavior:_snap45o];
        [_animator addBehavior:_snap90o];
        [_animator addBehavior:_snap135o];
        [_animator addBehavior:_snap180o];
//        [_animator addBehavior:phoneSnap];
//        [_animator addBehavior:textSnap];
//        [_animator addBehavior:tweetSnap];
//        [_animator addBehavior:emailSnap];
        
        [UIView animateWithDuration:.2f animations:^{
            self.phoneView.alpha = 0;
        }];
        [UIView animateWithDuration:.2f animations:^{
            self.textView.alpha = 0;
        }];
        [UIView animateWithDuration:.2f animations:^{
            self.tweetView.alpha = 0;
        }];
        [UIView animateWithDuration:.2f animations:^{
            self.emailView.alpha = 0;
        }];
        
        _buttonsOut = YES;
        
    } else {
        [_animator removeAllBehaviors];
        
        CGPoint pt0o = CGPointMake(self.vwMainBtn.frame.origin.x+ACTIVITIES_ICON_SIZE/2,
                                   self.vwMainBtn.frame.origin.y+ACTIVITIES_ICON_SIZE/2);
        UISnapBehavior *snap0oBack = [[UISnapBehavior alloc] initWithItem:self.view0o snapToPoint:pt0o];
        
        UISnapBehavior *snap45o;
        CGPoint pt45o = CGPointMake(self.vwMainBtn.frame.origin.x+ACTIVITIES_ICON_SIZE/2,
                                    self.vwMainBtn.frame.origin.y+ACTIVITIES_ICON_SIZE/2);
        snap45o = [[UISnapBehavior alloc] initWithItem:self.view45o snapToPoint:pt45o];
        
        UISnapBehavior *snap90o;
        CGPoint pt90o = CGPointMake(self.vwMainBtn.frame.origin.x+ACTIVITIES_ICON_SIZE/2,
                                    self.vwMainBtn.frame.origin.y+ACTIVITIES_ICON_SIZE/2);
        snap90o = [[UISnapBehavior alloc] initWithItem:self.view90o snapToPoint:pt90o];
        
        UISnapBehavior *snap135o;
        CGPoint pt135o = CGPointMake(self.vwMainBtn.frame.origin.x+ACTIVITIES_ICON_SIZE/2,
                                     self.vwMainBtn.frame.origin.y+ACTIVITIES_ICON_SIZE/2);
        snap135o = [[UISnapBehavior alloc] initWithItem:self.view135o snapToPoint:pt135o];
        
        UISnapBehavior *snap180o;
        CGPoint pt180o = CGPointMake(self.vwMainBtn.frame.origin.x+ACTIVITIES_ICON_SIZE/2,
                                     self.vwMainBtn.frame.origin.y+ACTIVITIES_ICON_SIZE/2);
        snap180o = [[UISnapBehavior alloc] initWithItem:self.view180o snapToPoint:pt180o];
        
//        UISnapBehavior *phoneSnap = [[UISnapBehavior alloc] initWithItem:self.phoneView snapToPoint:self.phoneViewStart];
//        UISnapBehavior *textSnap = [[UISnapBehavior alloc] initWithItem:self.textView snapToPoint:self.textViewStart];
//        UISnapBehavior *tweetSnap = [[UISnapBehavior alloc] initWithItem:self.tweetView snapToPoint:self.tweetViewStart];
//        UISnapBehavior *emailSnap = [[UISnapBehavior alloc] initWithItem:self.emailView snapToPoint:self.emailViewStart];
    
        [snap0oBack setDamping:0.5];
        [snap45o setDamping:0.5];
        [snap90o setDamping:0.5];
        [snap135o setDamping:0.5];
        [snap180o setDamping:0.5];
//        [phoneSnap setDamping:1];
//        [tweetSnap setDamping:1];
//        [textSnap setDamping:1];
//        [emailSnap setDamping:1];
        
        [_animator addBehavior:snap0oBack];
        [_animator addBehavior:snap45o];
        [_animator addBehavior:snap90o];
        [_animator addBehavior:snap135o];
        [_animator addBehavior:snap180o];
//        [_animator addBehavior:phoneSnap];
//        [_animator addBehavior:textSnap];
//        [_animator addBehavior:tweetSnap];
//        [_animator addBehavior:emailSnap];
        
        [UIView animateWithDuration:.3f animations:^{
            self.phoneView.alpha = 1;
        }];
        [UIView animateWithDuration:.3f animations:^{
            self.textView.alpha = 1;
        }];
        [UIView animateWithDuration:.3f animations:^{
            self.tweetView.alpha = 1;
        }];
        [UIView animateWithDuration:.3f animations:^{
            self.emailView.alpha = 1;
        }];
        
        _buttonsOut = NO;
    }
}

-(void)pressed0oButton:(UIButton *)sender //gifted
{
//    [self createUndoAffinityObject:.22];
    if (self.buddy.affinity < 1) {
        [MPNotificationView notifyWithText:@"...exchanged gifts."
                                    detail:@"20 Points!"
                                     image:[UIImage imageNamed:@"gift_icon_blue"]
                               andDuration:3];
    } else {
        [MPNotificationView notifyWithText:@"For now, your circle is complete"
                                    detail:@"Maximum points reached for today"
                                     image:[UIImage imageNamed:@"checkmark_icon"]
                               andDuration:3];
    }
    [self addAffinity:.22];
}

-(void)pressed45oButton:(UIButton *)sender //socialed
{
//    [self createUndoAffinityObject:.07];
    if (self.buddy.affinity < 1) {
    [MPNotificationView notifyWithText:@"...socialed."
                                detail:@"7 Points!"
                                 image:[UIImage imageNamed:@"social_icon_blue"]
                           andDuration:3];
    } else {
        [MPNotificationView notifyWithText:@"For now, your circle is complete"
                                    detail:@"Maximum points reached for today"
                                     image:[UIImage imageNamed:@"checkmark_icon"]
                               andDuration:3];
    }
    [self addAffinity:.07];
}

-(void)pressed90oButton:(UIButton *)sender // Hang
{
//    [self createUndoAffinityObject:.30];
    if (self.buddy.affinity < 1) {
    [MPNotificationView notifyWithText:@"...hung out."
                                detail:@"30 Points!"
                                 image:[UIImage imageNamed:@"besties_icon_blue"]
                           andDuration:3];
    } else {
        [MPNotificationView notifyWithText:@"For now, your circle is complete"
                                    detail:@"Maximum points reached for today"
                                     image:[UIImage imageNamed:@"checkmark_icon"]
                               andDuration:3];
    }
    [self addAffinity:.30];
}

-(void)pressed135oButton:(UIButton *)sender // messaged
{
//    [self createUndoAffinityObject:.10];
    if (self.buddy.affinity < 1) {
    [MPNotificationView notifyWithText:@"...messaged."
                                detail:@"10 Points!"
                                 image:[UIImage imageNamed:@"messaged_icon_blue"]
                           andDuration:3];
    } else {
        [MPNotificationView notifyWithText:@"For now, your circle is complete"
                                    detail:@"Maximum points reached for today"
                                     image:[UIImage imageNamed:@"checkmark_icon"]
                               andDuration:3];
    }
    [self addAffinity:.10];
}

-(void)pressed180oButton:(UIButton *)sender // talked
{
//    [self createUndoAffinityObject:.18];
    if (self.buddy.affinity < 1) {
    [MPNotificationView notifyWithText:@"...talked."
                                detail:@"20 Points!"
                                 image:[UIImage imageNamed:@"we_called_icon_blue"]
                           andDuration:3];
    } else {
        [MPNotificationView notifyWithText:@"For now, your circle is complete"
                                    detail:@"Maximum points reached for today"
                                     image:[UIImage imageNamed:@"checkmark_icon"]
                               andDuration:3];
    }
    [self addAffinity:.18];
}

- (IBAction)undoButton:(id)sender {
    if ([self.weMoves lastObject]) {
        NSNumber *wrappedAffinity = [self.weMoves lastObject];
        double affinity = [wrappedAffinity doubleValue];
        [self drainAffinity:affinity];
        [self.weMoves removeObject:[self.weMoves lastObject]];
    }
}

#pragma mark - Controller

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
        {
            //TODO: add timestamp and don't continue adding points for message after the first one for a day
            [self addAffinity:.12];
            break;
        }
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSMS:(NSString*)file {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    
    NSArray *recipents = @[self.buddy.phone];
    NSString *message = @"";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];

}

- (IBAction)emailNow:(id)sender {

        NSArray *toRecipents = [NSArray arrayWithObject:self.buddy.email];
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = self;

        [mailComposeViewController setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mailComposeViewController animated:YES completion:NULL];
}
    
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            [self addAffinity:.12];
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)addAffinity:(double)number
{
    if (self.buddy.affinity < 1) {
        self.buddy.affinity = self.buddy.affinity + number;
        [self.progressViewPie setProgress:self.buddy.affinity animated:YES];
        [UIView animateWithDuration:0.3f delay:0 options:0 animations:^{
            
        } completion:^(BOOL finished) {
            
        }];
        
        self.buddy.hasChanged = YES;
        
        if (!self.localNotificationController){
            self.localNotificationController = [[HISLocalNotificationController alloc] init];
        }
        
        [self.localNotificationController cancelNotificationsForBuddy:self.buddy];
        NSLog(@"Affinity Added: old notifs canceled");
        
        self.buddy.dateOfLastCalculation = [NSDate date];
        
        [self.localNotificationController scheduleNotificationsForBuddy:self.buddy];
        NSLog(@"Affinity Added: new notifs scheduled");
        
        [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
    }
}

- (void)drainAffinity:(double)number
{
    self.buddy.affinity = self.buddy.affinity - number;
    [self.progressViewPie setProgress:self.buddy.affinity animated:YES];
    
    [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
}

- (void)createUndoAffinityObject:(double)number
{
    NSNumber *affinity = [NSNumber numberWithDouble:number];
    [self.weMoves addObject:affinity];
}

- (NSMutableArray *)weMoves
{
    if (!_weMoves) {
        _weMoves = [[NSMutableArray alloc] init];
    }
    return _weMoves;
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toEdit"]) {
        HISEditBuddyViewController *destVC = segue.destinationViewController;
        destVC.buddy = self.buddy;
    }
}

- (IBAction)editedFriend:(UIStoryboardSegue *)segue {
    if ([segue.sourceViewController isKindOfClass:[HISEditBuddyViewController class]]) {
        HISEditBuddyViewController *editBuddyViewController = (HISEditBuddyViewController *)segue.sourceViewController;
        self.buddy = editBuddyViewController.buddy;
        HISBuddy *editedBuddy = editBuddyViewController.editedBuddy;
        
        if (editedBuddy) {
            [[HISCollectionViewDataSource sharedDataSource].buddies removeObject:self.buddy];
            [[HISCollectionViewDataSource sharedDataSource].buddies insertObject:editedBuddy atIndex:self.indexPath.row];
            [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
            self.buddy = editedBuddy;
//            [self setOutletsWithBuddyDetails];
        }
    }
}

- (void)percentCounterDisplay {
    
}

#pragma mark - Commented Out

//- (IBAction)phoneButton:(id)sender {
//
//    if([MFMessageComposeViewController canSendText]) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Call", @"Text", nil];
//        [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
//    } else {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.buddy.phone]]];
//    }
//}

//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//
//    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Call"]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.buddy.phone]]];
//        [self addAffinity:.2];
//    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Text"]) {
//        [self showSMS:nil];
//    } else {
//        return;
//    }
//}

@end
