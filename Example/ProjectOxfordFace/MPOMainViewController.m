// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license.
//
// Microsoft Cognitive Services (formerly Project Oxford): https://www.microsoft.com/cognitive-services
//
// Microsoft Cognitive Services (formerly Project Oxford) GitHub:
// https://github.com/Microsoft/Cognitive-Face-iOS
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MPOMainViewController.h"
#import "MPODetectionViewController.h"
#import "MPOVerificationViewController.h"
#import "MPOGroupingViewController.h"
#import "MPOSimilarFaceViewController.h"
#import "MPOIdentificationViewController.h"
#import <ProjectOxfordFace/MPOFaceSDK.h>
#import <ProjectOxfordFace_Example-Swift.h> //ADDED STUDF
#import "PersonFace.h"
#import "PersonGroup.h"
#import "GroupPerson.h"
//#import "F"

@interface MPOMainViewController () <UIActionSheetDelegate>

//@property(nonatomic, strong) NSString *email; //ADDED STUFFF

//@property(nonatomic, strong) FirebaseBrain *brain;

@end

@implementation MPOMainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"back";
    self.navigationItem.backBarButtonItem = backItem;
    NSLog(@"create instance");
    [self buildMainUI];
    FirebaseBrain *brain = [[FirebaseBrain alloc] init];
    [brain retrieve: _email];
}

- (void)buildMainUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
    
    /*UIButton * detectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     UIButton * verificationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     UIButton * groupingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     UIButton * similarFaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];*/
    UIButton * identificationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    /*UILabel * detectionLabel = [[UILabel alloc] init];
     UILabel * verificationLabel = [[UILabel alloc] init];
     UILabel * groupingLabel = [[UILabel alloc] init];
     UILabel * similarLabel = [[UILabel alloc] init];*/
    UILabel * identificationLabel = [[UILabel alloc] init];
    //UILabel * descriptionLabel = [[UILabel alloc] init];
    /*UILabel * instructionsLabel = [[UILabel alloc] init];
     UILabel * instructionsLabel2 = [[UILabel alloc] init];
     UILabel * instructionsLabel2a = [[UILabel alloc] init];
     UILabel * instructionsLabel2b = [[UILabel alloc] init];
     UILabel * instructionsLabel3 = [[UILabel alloc] init];*/
    
    UIImageView *instructionsImgInit = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AttendanceAssure"]];
    
    
    
    UIImage *instructions = [self imageWithImage:instructionsImgInit.image convertToSize:CGSizeMake(scrollView.width-30, scrollView.height-100)];
    UIImageView *instructionsImg = [[UIImageView alloc] initWithImage:instructions];
    
    
    
    
    
    
    /*NSString * detectionHint = @"Detect faces, face landmarks, pose, gender, and age.";
     NSString * verificationHint = @"Check if two faces belong to the same person.";
     NSString * groupingHint = @"Group faces based on similarity.";
     NSString * SimilarFaceHint = @"Search for similar-looking faces.";*/
    NSString * identificationHint = @"Identify the person from a face.";
    //NSString * descriptionHint = @"Microsoft will receive the images you upload and may use them to improve Face API and related services. By submitting an image, you confirm that you have consent from everyone in it.";
    /* NSString * instructionsText = @"Welcome to our iOS Attendance App! ";
     NSString * instructionsText2 = @"To add a class: Click on “Manage Groups” and create a group by";
     NSString * instructionsText2a = @"naming the group and adding students to it. Each student you";
     NSString * instructionsText2b = @"add must have name and picture associated with him/her. ";
     NSString * instructionsText3 = @"To take attendance : Take a picture of your class and let the app work it’s magic*! ";*/
    
    CGFloat btnWidth = SCREEN_WIDTH / 2 - 20;
    CGFloat btnHeight = btnWidth / 3;
    identificationBtn.width = btnWidth;
    identificationBtn.height = btnHeight;
    /*detectionBtn.width = verificationBtn.width = groupingBtn.width = similarFaceBtn.width = identificationBtn.width = btnWidth;
     detectionBtn.height = verificationBtn.height = groupingBtn.height = similarFaceBtn.height = identificationBtn.height = btnHeight;*/
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    /*[detectionBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
     [verificationBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
     [groupingBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
     [similarFaceBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];*/
    [identificationBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    /*[detectionBtn setTitle:@"DETECTION" forState:UIControlStateNormal];
     [verificationBtn setTitle:@"VERIFICATION" forState:UIControlStateNormal];
     [groupingBtn setTitle:@"GROUPING" forState:UIControlStateNormal];
     [similarFaceBtn setTitle:@"FIND SIMILAR FACES" forState:UIControlStateNormal];
     similarFaceBtn.titleLabel.adjustsFontSizeToFitWidth = YES;*/
    [identificationBtn setTitle:@"GO" forState:UIControlStateNormal];
    /*[instructionsLabel setText:instructionsText];
     [instructionsLabel2 setText:instructionsText2];
     [instructionsLabel2a setText:instructionsText2a];
     [instructionsLabel2b setText:instructionsText2b];
     [instructionsLabel3 setText:instructionsText3];*/
    
    /*detectionBtn.right = verificationBtn.right = groupingBtn.right = similarFaceBtn.right = identificationBtn.right = scrollView.width - 20;
     
     detectionLabel.top = detectionBtn.top = 20;
     verificationLabel.top =  verificationBtn.top = detectionBtn.bottom + 20;
     groupingLabel.top = groupingBtn.top = verificationBtn.bottom + 20;
     similarLabel.top = similarFaceBtn.top = groupingBtn.bottom + 20;*/
    identificationBtn.center = identificationLabel.center = scrollView.center;
    identificationBtn.top = SCREEN_HEIGHT-150;
    instructionsImg.center = scrollView.center;
    instructionsImg.top = 0;
    
    
    /*[detectionLabel setText:detectionHint];
     [verificationLabel setText:verificationHint];
     [groupingLabel setText:groupingHint];
     [similarLabel setText:SimilarFaceHint];*/
    [identificationLabel setText:identificationHint];
    //[descriptionLabel setText:descriptionHint];
    
    /*descriptionLabel.numberOfLines = detectionLabel.numberOfLines = verificationLabel.numberOfLines = groupingLabel.numberOfLines = similarLabel.numberOfLines = identificationLabel.numberOfLines = 0;
     descriptionLabel.font = detectionLabel.font = verificationLabel.font = groupingLabel.font = similarLabel.font = identificationLabel.font = descriptionLabel.font = [UIFont systemFontOfSize:12];*/
    identificationLabel.font = [UIFont systemFontOfSize:12];
    /*instructionsLabel.font = [UIFont systemFontOfSize:12];
     instructionsLabel2.font = [UIFont systemFontOfSize:12];
     instructionsLabel2a.font = [UIFont systemFontOfSize:12];
     instructionsLabel2b.font = [UIFont systemFontOfSize:12];
     instructionsLabel3.font = [UIFont systemFontOfSize:12];*/
    
    
    /*detectionLabel.width = verificationLabel.width = groupingLabel.width = similarLabel.width = identificationLabel.width = btnWidth - 10;
     */
    /*instructionsLabel.width = SCREEN_WIDTH - 10;
     instructionsLabel.top = 50;
     instructionsLabel2.width = SCREEN_WIDTH - 10;
     instructionsLabel2.top = 100;
     instructionsLabel2a.width = SCREEN_WIDTH - 10;
     instructionsLabel2a.top = 150;
     instructionsLabel2b.width = SCREEN_WIDTH - 10;
     instructionsLabel2b.top = 200;
     instructionsLabel3.width = SCREEN_WIDTH - 10;
     instructionsLabel3.top = 250;*/
    
    
    identificationLabel.width = btnWidth - 10;
    identificationLabel.height = btnHeight;
    /*detectionLabel.height = verificationLabel.height = groupingLabel.height = similarLabel.height = identificationLabel.height = btnHeight;
     detectionLabel.left = verificationLabel.left = groupingLabel.left = similarLabel.left = identificationLabel.left = 20;
     descriptionLabel.width = SCREEN_WIDTH - 20 * 2;
     [descriptionLabel sizeToFit];
     descriptionLabel.top = identificationBtn.bottom + 20;
     descriptionLabel.left = 20;
     
     [detectionBtn addTarget:self action:@selector(detectionAction:) forControlEvents:UIControlEventTouchUpInside];
     [verificationBtn addTarget:self action:@selector(verificationAction:) forControlEvents:UIControlEventTouchUpInside];
     [groupingBtn addTarget:self action:@selector(groupingAction:) forControlEvents:UIControlEventTouchUpInside];
     [similarFaceBtn addTarget:self action:@selector(similarFaceAction:) forControlEvents:UIControlEventTouchUpInside];*/
    [identificationBtn addTarget:self action:@selector(identificationAction:) forControlEvents:UIControlEventTouchUpInside];
    
    /*[scrollView addSubview:detectionBtn];
     [scrollView addSubview:verificationBtn];
     [scrollView addSubview:groupingBtn];
     [scrollView addSubview:similarFaceBtn];*/
    /*[scrollView addSubview:instructionsLabel];
     [scrollView addSubview:instructionsLabel2];
     [scrollView addSubview:instructionsLabel2a];
     [scrollView addSubview:instructionsLabel2b];
     
     [scrollView addSubview:instructionsLabel3];*/
    
    [scrollView addSubview:identificationBtn];
    [scrollView addSubview: instructionsImg];
    /*[scrollView addSubview:detectionLabel];
     [scrollView addSubview:verificationLabel];
     [scrollView addSubview:groupingLabel];
     [scrollView addSubview:similarLabel];*/
    //0[scrollView addSubview:identificationLabel];
    //[scrollView addSubview:descriptionLabel];
    
    scrollView.contentSize = CGSizeMake(scrollView.width, SCREEN_HEIGHT - 20);
    [self.view addSubview:scrollView];
    
    if ([ProjectOxfordFaceSubscriptionKey isEqualToString:@"Your Subscription Key"]) {
        /*detectionBtn.enabled = NO;
         verificationBtn.enabled = NO;
         groupingBtn.enabled = NO;
         similarFaceBtn.enabled = NO;*/
        identificationBtn.enabled = NO;
        [CommonUtil simpleDialog:@"You haven't input the subscription key. Please specify the subscription key in MPOAppDelegate.h"];
    }
}

- (void)detectionAction:(id)sender {
    UIViewController * controller = [[MPODetectionViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)verificationAction:(id)sender {
    UIActionSheet * verification_type_sheet = [[UIActionSheet alloc]
                                               initWithTitle:@"Choose verification type"
                                               delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                               otherButtonTitles:@"face and face", @"face and person",nil];
    [verification_type_sheet showInView:self.view];
}

- (void)groupingAction:(id)sender {
    UIViewController * controller = [[MPOGroupingViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)similarFaceAction:(id)sender {
    UIViewController * controller = [[MPOSimilarFaceViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)identificationAction:(id)sender {
    MPOIdentificationViewController * controller = [[MPOIdentificationViewController alloc] init];
    [controller saveEmail: _email];
    //NSLog(@"create instance");
    //NSLog(@"%@", _email);
    //controller.email=_email;
    //[controller saveEmail: _email];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        UIViewController * controller = [[MPOVerificationViewController alloc] initWithVerificationType:VerificationTypeFaceAndFace];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (buttonIndex == 1) {
        UIViewController * controller = [[MPOVerificationViewController alloc] initWithVerificationType:VerificationTypeFaceAndPerson];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

@end
