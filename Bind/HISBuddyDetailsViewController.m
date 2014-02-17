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

@interface HISBuddyDetailsViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (nonatomic, readwrite) CGRect phoneButtonBounds;
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *progressViewPie;
@property (weak, nonatomic) IBOutlet UIButton *composeMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *textMessageButton;
@property (strong, nonatomic) HISLocalNotificationController *localNotificationController;

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
    [self processAndDisplayBackgroundImage:@"BlueGradient.png"];
    
    self.phoneButtonBounds = self.phoneButton.bounds;
    self.phoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.phoneButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    self.localNotificationController = [[HISLocalNotificationController alloc] init];
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
    
    [self makeButtonRoundWithWhiteBorder:self.phoneButton];
    [self makeButtonRoundWithWhiteBorder:self.textMessageButton];
    [self makeButtonRoundWithWhiteBorder:self.composeMessageButton];
}

- (void)makeButtonRoundWithWhiteBorder:(UIButton *)button
{
    button.layer.borderWidth = 1;
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

- (IBAction)textButton:(id)sender
{
//    [[UINavigationBar appearance] setTranslucent:NO];
    
    [self showSMS:nil];
}

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

- (IBAction)weHungOutButton:(id)sender {
    [self addAffinity:.25];
}

- (IBAction)theyCalledMeButton:(id)sender {
    [self addAffinity:.12];
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

@end
