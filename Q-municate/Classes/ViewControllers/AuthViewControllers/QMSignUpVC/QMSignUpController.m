//
//  QMSignUpController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSignUpController.h"
#import "QMWelcomeScreenViewController.h"
#import "QMLicenseAgreementViewController.h"
#import "QMSettingsManager.h"
#import "UIImage+Cropper.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "QMApi.h"
#import "QMImagePicker.h"
#import "REActionSheet.h"

@interface QMSignUpController ()

@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;


@property (strong, nonatomic) UIImage *cachedPicture;

- (IBAction)chooseUserPicture:(id)sender;
- (IBAction)signUp:(id)sender;

@end

@implementation QMSignUpController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
    self.userImage.layer.masksToBounds = YES;

    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)chooseUserPicture:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    
    [QMImagePicker chooseSourceTypeInVC:self allowsEditing:YES result:^(UIImage *image) {

        [weakSelf.userImage setImage:image];
        weakSelf.cachedPicture = image;
    }];
}

- (IBAction)signUp:(id)sender
{
    __weak __typeof(self)weakSelf = self;
    [self checkForAcceptedUserAgreement:^(BOOL success) {
        if (success) {
            [weakSelf fireSignUp];
        }
    }];
}

- (void)fireSignUp
{
    NSString *fullName = self.fullNameField.text;
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (fullName.length == 0 || password.length == 0 || email.length == 0) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
        return;
    }
    
    QBUUser *newUser = [QBUUser user];
    
    newUser.fullName = fullName;
    newUser.email = email;
    newUser.password = password;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    __weak __typeof(self)weakSelf = self;
    
    void (^presentTabBar)(void) = ^(void) {
        
        [SVProgressHUD dismiss];
        [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
    };
    
    [[QMApi instance] signUpAndLoginWithUser:newUser rememberMe:YES completion:^(BOOL success) {
        
        if (success) {
            
            if (weakSelf.cachedPicture) {
                
                [SVProgressHUD showProgress:0.f status:nil maskType:SVProgressHUDMaskTypeClear];
                [[QMApi instance] updateUser:nil image:weakSelf.cachedPicture progress:^(float progress) {
                    [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
                } completion:^(BOOL updateUserSuccess) {
                    presentTabBar();
                }];
            }
            else {
                presentTabBar();
            }
        }
        else {
            [SVProgressHUD dismiss];
        }
    }];
}

- (void)checkForAcceptedUserAgreement:(void(^)(BOOL success))completion {
    
    BOOL licenceAccepted = [[QMApi instance].settingsManager userAgreementAccepted];
    if (licenceAccepted) {
        completion(YES);
    }
    else {
        QMLicenseAgreementViewController *licenceController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"QMLicenceAgreementControllerID"];
        licenceController.licenceCompletionBlock = completion;
        [self.navigationController pushViewController:licenceController animated:YES];
    }
}
@end