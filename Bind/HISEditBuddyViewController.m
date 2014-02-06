//
//  HISEditBuddyViewController.m
//  Bind
//
//  Created by Tim Hise on 2/4/14.
//  Copyright (c) 2014 CleverKnot. All rights reserved.
//

#import "HISEditBuddyViewController.h"
#import "HISCollectionViewDataSource.h"

@interface HISEditBuddyViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *twitterField;
@property (weak, nonatomic) IBOutlet UIImageView *editedImageView;
@property (weak, nonatomic) IBOutlet UIButton *startPickerButton;

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
    
    [self.startPickerButton setTitle:@"Camera Icon Here" forState:UIControlStateNormal];
    
    [HISCollectionViewDataSource makeRoundView:self.currentImageView];
    [HISCollectionViewDataSource makeRoundView:self.editedImageView];
}

- (void)setPlaceholdersWithBuddyDetails
{
    self.nameField.placeholder = self.buddy.name;
    self.phoneField.placeholder = self.buddy.phone;
    self.emailField.placeholder = self.buddy.email;
    self.twitterField.placeholder = self.buddy.twitter;
    
    if (self.buddy.pic) {
        self.currentImageView.image = self.buddy.pic;
    } else if (self.buddy.imagePath) {
        self.currentImageView.image = [UIImage imageWithContentsOfFile:self.buddy.imagePath];
    } else {
        // TODO: put placeholder image here
        self.currentImageView.image = nil;
    }
}

- (IBAction)saveButton:(id)sender
{
    self.editedBuddy = [[HISBuddy alloc] init];
    
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

#pragma mark - Toolbar

- (IBAction)cancel:(id)sender {
    //TODO: add a warning if any info has changed
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"removedFriend"]) {
        //TODO: add a warning here before allowing segue
    }
}
@end
