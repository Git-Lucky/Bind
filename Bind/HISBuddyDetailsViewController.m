//
//  HISDetailsVC.m
//  Bind
//
//  Created by Tim Hise on 2/3/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISBuddyDetailsViewController.h"
#import "HISEditBuddyViewController.h"

@interface HISBuddyDetailsViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *affinityLevel;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

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
    
    self.navigationController.title = @"Your Buddy!";
    
    [HISCollectionViewDataSource makeRoundView:self.imageView];
    
    [self setOutletsWithBuddyDetails];
}

- (void)setOutletsWithBuddyDetails
{
    self.nameLabel.text = self.buddy.name;
    self.affinityLevel.progress = self.buddy.affinity;
    [self.phoneButton  setTitle:self.buddy.phone forState:UIControlStateNormal];
    [self.emailButton setTitle:self.buddy.email forState:UIControlStateNormal];
    self.emailButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.twitterButton setTitle:self.buddy.twitter forState:UIControlStateNormal];
    self.twitterButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    if (self.buddy.pic) {
        self.imageView.image = self.buddy.pic;
    } else if (self.buddy.imagePath) {
        self.imageView.image = [UIImage imageWithContentsOfFile:self.buddy.imagePath];
    } else {
        self.imageView.image = [UIImage imageNamed:@"placeholder.jpg"];
    }
}



- (IBAction)phoneButton:(id)sender {
    
    if([MFMessageComposeViewController canSendText]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Call", @"Text", nil];
        [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.buddy.phone]]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Call"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.buddy.phone]]];
        self.buddy.affinity = self.buddy.affinity + .2;
        self.affinityLevel.progress = self.buddy.affinity;
//        [HISCollectionViewDataSource saveRootObject:self.dataSource.buddies];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Text"]) {
        [self showSMS:nil];
        
    } else {
        return;
    }
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
            NSLog(@"affinity before: %f and progress bar %f", self.buddy.affinity, self.affinityLevel.progress);
            self.buddy.affinity = self.buddy.affinity + .12;
            self.affinityLevel.progress = self.buddy.affinity;
            NSLog(@"affinity after: %f and progress bar %f", self.buddy.affinity, self.affinityLevel.progress);
            break;
        }
            
        
        default:
            break;
    }
//    [HISCollectionViewDataSource saveRootObject:self.dataSource.buddies];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSMS:(NSString*)file {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
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
        NSString *emailTitle = @"BooYah";
        // Email Content
        NSString *messageBody = @"iOS programming is so fun!";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:self.buddy.email];
        
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = self;
        [mailComposeViewController setSubject:emailTitle];
        [mailComposeViewController setMessageBody:messageBody isHTML:NO];
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
            self.buddy.affinity = self.buddy.affinity + .08;
            self.affinityLevel.progress = self.buddy.affinity;
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
//    [HISCollectionViewDataSource saveRootObject:self.dataSource.buddies];
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)weHungOutButton:(id)sender {
    self.buddy.affinity = self.buddy.affinity + .25;
    self.affinityLevel.progress = self.buddy.affinity;
    [HISCollectionViewDataSource saveRootObject:self.dataSource.buddies];
}

- (IBAction)theyCalledMeButton:(id)sender {
    self.buddy.affinity = self.buddy.affinity + .12;
    self.affinityLevel.progress = self.buddy.affinity;
    [HISCollectionViewDataSource saveRootObject:self.dataSource.buddies];
}

- (IBAction)drainHalfAffinity:(id)sender {
    self.buddy.affinity = self.buddy.affinity - .25;
    self.affinityLevel.progress = self.buddy.affinity;
    [HISCollectionViewDataSource saveRootObject:self.dataSource.buddies];
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
            [self.dataSource.buddies removeObject:self.buddy];
            [self.dataSource.buddies addObject:editedBuddy];
            [HISCollectionViewDataSource saveRootObject:self.dataSource.buddies];
            self.buddy = editedBuddy;
            [self setOutletsWithBuddyDetails];
        }
    }
}

@end
