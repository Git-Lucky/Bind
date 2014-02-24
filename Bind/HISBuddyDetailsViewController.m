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

//*****************************************
// Icon and Animation Constants
    const int   ACTIVITIES_ICON_SIZE = 60;
    const float HYPOTENUSE = 75;
//*****************************************

@interface HISBuddyDetailsViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>{
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

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (nonatomic, readwrite) CGRect phoneButtonBounds;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *progressViewPie;
@property (weak, nonatomic) IBOutlet UIButton *composeMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *textMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) HISLocalNotificationController *localNotificationController;
@property (weak, nonatomic) IBOutlet UIView *innerGreyView;
@property (weak, nonatomic) IBOutlet UIView *outerGreyView;
@property (weak, nonatomic) IBOutletCollection(UILabel) NSArray *actionLabels;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *textView;
@property (weak, nonatomic) IBOutlet UIView *tweetView;
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (nonatomic) CGPoint phoneViewStart;
@property (nonatomic) CGPoint textViewStart;
@property (nonatomic) CGPoint tweetViewStart;
@property (nonatomic) CGPoint emailViewStart;


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
    
    self.navigationItem.title = self.buddy.name;
    
    [HISCollectionViewDataSource makeRoundView:self.imageView];
    
    [self setOutletsWithBuddyDetails];
    [self processAndDisplayBackgroundImage:backgroundImage];
    
    self.phoneButtonBounds = self.phoneButton.bounds;
    self.phoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.phoneButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    self.innerGreyView.backgroundColor = [UIColor clearColor];
    self.outerGreyView.backgroundColor = [UIColor clearColor];
    self.innerGreyView.layer.cornerRadius = self.innerGreyView.frame.size.height / 2;
    self.outerGreyView.layer.cornerRadius = self.outerGreyView.frame.size.height / 2;
    
    self.localNotificationController = [[HISLocalNotificationController alloc] init];
    
    // RPL Animation
    _buttonsOut = NO;
    float vwMainBtnSide = 60;
    float vwMainBtnX = (self.view.frame.size.width/2) - (vwMainBtnSide/2);
    float vwMainBtnY = (self.view.frame.size.height - vwMainBtnSide - 5); // 10 Padding
    
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
//    self.view0o.backgroundColor = [UIColor greenColor];
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
//    self.view45o.backgroundColor = [UIColor greenColor];
//    self.view45o.layer.masksToBounds = YES;
//    self.view45o.layer.cornerRadius = ACTIVITIES_ICON_SIZE/2;
    [self.view addSubview:self.view45o];
    
    UIButton *btn45o = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btn45o setTitle:@"Wrote" forState:UIControlStateNormal];
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
//    self.view90o.backgroundColor = [UIColor greenColor];
//    self.view90o.layer.masksToBounds = YES;
//    self.view90o.layer.cornerRadius = ACTIVITIES_ICON_SIZE/2;
    [self.view addSubview:self.view90o];
    
    UIButton *btn90o = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btn90o setTitle:@"Hang" forState:UIControlStateNormal];
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
//    self.view135o.backgroundColor = [UIColor greenColor];
//    self.view135o.layer.masksToBounds = YES;
//    self.view135o.layer.cornerRadius = ACTIVITIES_ICON_SIZE/2;
    [self.view addSubview:self.view135o];
    
    UIButton *btn135o = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btn135o setTitle:@"Gifted" forState:UIControlStateNormal];
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
//    self.view180o.backgroundColor = [UIColor greenColor];
//    self.view180o.layer.masksToBounds = YES;
//    self.view180o.layer.cornerRadius = ACTIVITIES_ICON_SIZE/2;
    [self.view addSubview:self.view180o];
    
    UIButton *btn180o = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [btn180o setTitle:@"Social" forState:UIControlStateNormal];
    [btn180o setBackgroundImage:[UIImage imageNamed:@"we_called_icon.png"] forState:UIControlStateNormal];
    [btn180o addTarget:self action:@selector(pressed180oButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn180o setFrame:CGRectMake(0, 0, self.view180o.frame.size.width, self.view180o.frame.size.height)];
    btn180o.layer.cornerRadius = btn90o.layer.frame.size.height / 2;
    btn180o.layer.borderColor = [[UIColor whiteColor] CGColor];
    btn180o.layer.borderWidth = 2;
    [self.view180o addSubview:btn180o];
    
    // Set starting points for the buttons under circle pic
    self.phoneViewStart = CGPointMake(self.phoneView.frame.origin.x + self.phoneView.frame.size.width/2, self.phoneView.frame.origin.y + self.phoneView.frame.size.height/2);
    self.textViewStart = CGPointMake(self.textView.frame.origin.x + self.textView.frame.size.width/2, self.textView.frame.origin.y + self.textView.frame.size.height/2);
    self.tweetViewStart = CGPointMake(self.tweetView.frame.origin.x + self.tweetView.frame.size.width/2, self.tweetView.frame.origin.y + self.tweetView.frame.size.height/2);
    self.emailViewStart = CGPointMake(self.emailView.frame.origin.x + self.emailView.frame.size.width/2, self.emailView.frame.origin.y + self.emailView.frame.size.height/2);

    // Add "We" View
    [self.view addSubview:self.vwMainBtn];
    
    // Dynamics
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
}

- (void)setOutletsWithBuddyDetails
{
    if (self.buddy.pic) {
        self.imageView.image = self.buddy.pic;
    } else if (self.buddy.imagePath) {
        self.imageView.image = [UIImage imageWithContentsOfFile:self.buddy.imagePath];
    } else {
        self.imageView.image = [UIImage imageNamed:@"placeholder.jpg"];
    }
    
    [self.progressViewPie setProgress:self.buddy.affinity animated:NO];
    
//    [self makeButtonRoundWithWhiteBorder:self.phoneButton];
//    [self makeButtonRoundWithWhiteBorder:self.textMessageButton];
//    [self makeButtonRoundWithWhiteBorder:self.composeMessageButton];
//    [self makeButtonRoundWithWhiteBorder:self.twitterButton];
}

- (void)makeButtonRoundWithWhiteBorder:(UIButton *)button
{
    button.layer.borderWidth = 2;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.cornerRadius = button.frame.size.width / 2;
}

- (void)processAndDisplayBackgroundImage:(NSString *)imageName
{
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:imageName] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}

#pragma mark - Action Buttons

- (IBAction)phoneButton:(id)sender
{
    NSString *phoneString = self.buddy.phone;
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneString = [phoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [self addAffinity:.2];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneString]]];
}

- (IBAction)tweetButton:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *address = [NSString stringWithFormat:@"%@ ",self.buddy.twitter];
        [tweetSheet setInitialText:address];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}

- (IBAction)facebookButton:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Hello"];
        [self presentViewController:controller animated:YES completion:Nil];
    }
}

- (IBAction)textButton:(id)sender
{
//    [[UINavigationBar appearance] setTranslucent:NO];
    [self showSMS:nil];
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
        
        UISnapBehavior *phoneSnap = [[UISnapBehavior alloc] initWithItem:self.phoneView snapToPoint:self.imageView.center];
        UISnapBehavior *textSnap = [[UISnapBehavior alloc] initWithItem:self.textView snapToPoint:self.imageView.center];
        UISnapBehavior *tweetSnap = [[UISnapBehavior alloc] initWithItem:self.tweetView snapToPoint:self.imageView.center];
        UISnapBehavior *emailSnap = [[UISnapBehavior alloc] initWithItem:self.emailView snapToPoint:self.imageView.center];
        
        [_snap0o setDamping:0.5];
        [_snap45o setDamping:0.5];
        [_snap90o setDamping:0.5];
        [_snap135o setDamping:0.5];
        [_snap180o setDamping:0.5];
        [phoneSnap setDamping:1];
        [tweetSnap setDamping:1];
        [textSnap setDamping:1];
        [emailSnap setDamping:1];
        
        [_animator addBehavior:_snap0o];
        [_animator addBehavior:_snap45o];
        [_animator addBehavior:_snap90o];
        [_animator addBehavior:_snap135o];
        [_animator addBehavior:_snap180o];
        [_animator addBehavior:phoneSnap];
        [_animator addBehavior:textSnap];
        [_animator addBehavior:tweetSnap];
        [_animator addBehavior:emailSnap];
        
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
        
        UISnapBehavior *phoneSnap = [[UISnapBehavior alloc] initWithItem:self.phoneView snapToPoint:self.phoneViewStart];
        UISnapBehavior *textSnap = [[UISnapBehavior alloc] initWithItem:self.textView snapToPoint:self.textViewStart];
        UISnapBehavior *tweetSnap = [[UISnapBehavior alloc] initWithItem:self.tweetView snapToPoint:self.tweetViewStart];
        UISnapBehavior *emailSnap = [[UISnapBehavior alloc] initWithItem:self.emailView snapToPoint:self.emailViewStart];
    
        [snap0oBack setDamping:0.5];
        [snap45o setDamping:0.5];
        [snap90o setDamping:0.5];
        [snap135o setDamping:0.5];
        [snap180o setDamping:0.5];
        [phoneSnap setDamping:1];
        [tweetSnap setDamping:1];
        [textSnap setDamping:1];
        [emailSnap setDamping:1];
        
        [_animator addBehavior:snap0oBack];
        [_animator addBehavior:snap45o];
        [_animator addBehavior:snap90o];
        [_animator addBehavior:snap135o];
        [_animator addBehavior:snap180o];
        [_animator addBehavior:phoneSnap];
        [_animator addBehavior:textSnap];
        [_animator addBehavior:tweetSnap];
        [_animator addBehavior:emailSnap];
        
        _buttonsOut = NO;
    }
}

-(void)pressed0oButton:(UIButton *)sender //gifted
{
    [self addAffinity:.28];
}

-(void)pressed45oButton:(UIButton *)sender //socialed
{
    [self addAffinity:.1];
}

-(void)pressed90oButton:(UIButton *)sender // Hang
{
    [self addAffinity:.4];
}

-(void)pressed135oButton:(UIButton *)sender // messaged
{
    [self addAffinity:.15];
}

-(void)pressed180oButton:(UIButton *)sender // talked
{
    [self addAffinity:.2];
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
    NSString *message = @"I really miss you buddy";
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];

}

- (IBAction)emailNow:(id)sender {
        // Email Subject
//        NSString *emailTitle = @"BooYah";
        // Email Content
//        NSString *messageBody = @"iOS programming is so fun!";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:self.buddy.email];
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = self;
//        [mailComposeViewController setSubject:emailTitle];
//        [mailComposeViewController setMessageBody:messageBody isHTML:NO];
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
            [self addAffinity:.08];
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

- (IBAction)drainAffinity:(id)sender {
    self.buddy.affinity = self.buddy.affinity - .25;
    [self.progressViewPie setProgress:self.buddy.affinity animated:YES];
    self.buddy.hasChanged = YES;
    [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
}

- (void)addAffinity:(double)number
{
    if (self.buddy.affinity < 1) {
        self.buddy.affinity = self.buddy.affinity + number;
        [self.progressViewPie setProgress:self.buddy.affinity animated:YES];
        self.buddy.hasChanged = YES;
        
        [self.localNotificationController cancelNotificationsForBuddy:self.buddy];
        
        self.buddy.dateOfLastInteraction = [NSDate date];
        
        [self.localNotificationController scheduleNotificationsForBuddy:self.buddy];
        
        [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
    }
}

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
//            [self.dataSource.buddies removeObject:self.buddy];
//            [self.dataSource.buddies insertObject:editedBuddy atIndex:self.indexPath.row];
            [[HISCollectionViewDataSource sharedDataSource].buddies removeObject:self.buddy];
            [[HISCollectionViewDataSource sharedDataSource].buddies insertObject:editedBuddy atIndex:self.indexPath.row];
            [[HISCollectionViewDataSource sharedDataSource] saveRootObject];
            self.buddy = editedBuddy;
            [self setOutletsWithBuddyDetails];
        }
    }
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
