/*// Copyright (c) Microsoft. All rights reserved.
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

#import "MPOIdentificationViewController.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Crop.h"
#import "ImageHelper.h"
#import "MPOPersonGroupListController.h"
#import "PersonGroup.h"
#import "GroupPerson.h"
#import "PersonFace.h"
#import "MPOSimpleFaceCell.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>
#import "MBProgressHUD.h"
#import <ProjectOxfordFace/MPOFaceSDK.h>
//#import <ProjectOxfordFace_Example-Swift.h> //ADDED STUDF

#define MAX_RESULT_COUNT 20

@interface MPOIdentificationViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource> {
    UITableView * _groupListView;
    UITableView * _resultListView;
    UICollectionView * _imageContainer;
    UIButton * _identifyBtn;
    NSMutableArray * _faces;
    NSMutableArray * results;
}
//ADDED STUFF
//@property(nonatomic, strong) Test *test;
//@property(nonatomic, strong) FirebaseBrain *brain;

@end

@implementation MPOIdentificationViewController

- (void) saveEmail: (NSString*) m{
    _email=m;
    //NSLog(@"%@", _email);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Identification";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"back";
    self.navigationItem.backBarButtonItem = backItem;
    NSLog(@"indentification");
    [self buildMainUI];
    results = [[NSMutableArray alloc] init];
    _faces = [[NSMutableArray alloc] init];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_groupListView reloadData];
}


- (void)identify:(id)sender {
    NSIndexPath * indexPath = _groupListView.indexPathForSelectedRow;
    
    if (indexPath == nil) {
        [CommonUtil simpleDialog:@"please select a group"];
        return;
    }
    
    NSMutableArray *faceIds = [[NSMutableArray alloc] init];
    
    for (PersonFace *obj in _faces) {
        [faceIds addObject:obj.face.faceId];
    }
    
    PersonGroup * group = GLOBAL.groups[indexPath.row];
    //NSArray * results = [FaceSdkUtil getFaceIndentificationResultsFromPeople:groupPeople andFace:_faces[_selectedTargetIndex]];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Identifying faces";
    [HUD show: YES];
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    [client identifyWithLargePersonGroupId:group.groupId faceIds:faceIds maxNumberOfCandidates:group.people.count completionBlock:^(NSArray<MPOIdentifyResult *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Failed in Indentification" forController:self.navigationController];
            return;
        }
        [results removeAllObjects];
        for (MPOIdentifyResult * idRestult in collection) {
            
            PersonFace * face = [self getFaceByFaceId:idRestult.faceId];
            
            for (MPOCandidate * candidate in idRestult.candidates) {
                GroupPerson * person = [self getPersonInGroup:group withPersonId:candidate.personId];
                [results addObject:@{@"face" : face, @"personName": person.personName, @"confidence" : candidate.confidence}];
            }
        }
        
        if (collection.count == 0) {
            [CommonUtil showSimpleHUD:@"No result." forController:self.navigationController];
        }
        
        [_resultListView reloadData];
    }];
}

- (PersonFace*) getFaceByFaceId: (NSString*) faceId {
    for (PersonFace * face in _faces) {
        if ([face.face.faceId isEqualToString:faceId]) {
            return face;
        }
    }
    return nil;
}

- (GroupPerson*) getPersonInGroup:(PersonGroup*)group withPersonId: (NSString*) personId {
    for (GroupPerson * person in group.people) {
        if ([person.personId isEqualToString:personId]) {
            return person;
        }
    }
    return nil;
}

- (void)chooseImage: (id)sender {
    UIActionSheet * choose_photo_sheet = [[UIActionSheet alloc]
                                          initWithTitle:@"Select Image"
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"Select from album", @"Take a photo",nil];
    [choose_photo_sheet showInView:self.view];
}

- (void)pickImage {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    
    //ADDED STUFF TEST
    //_test=[[Test alloc] init];
    //_test.view.backgroundColor=[UIColor purpleColor];
    //[self presentViewController:_test animated:YES completion:nil];
    //_brain=[[FirebaseBrain alloc] init];
    //[_brain save];
    
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)snapImage {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)ManagePersonGroupAction:(id)sender {
    MPOPersonGroupListController * controller = [[MPOPersonGroupListController alloc] init];
    [controller saveEmailPersonGroup: _email];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildMainUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
    
    UILabel * label = [[UILabel alloc] init];
    label.text = @"Target Image:";
    label.left = 20;
    label.top = 20;
    [scrollView addSubview:label];
    [label sizeToFit];
    
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    UIButton * addFacesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addFacesBtn.titleLabel.numberOfLines = 0;
    [addFacesBtn setTitle:@"Select Image" forState:UIControlStateNormal];
    addFacesBtn.width = SCREEN_WIDTH / 3 - 20;
    addFacesBtn.height = addFacesBtn.width * 3 / 7;
    addFacesBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    addFacesBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addFacesBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [addFacesBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    label.width = addFacesBtn.width;
    label.adjustsFontSizeToFitWidth = YES;
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    _imageContainer = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _imageContainer.width = SCREEN_WIDTH - addFacesBtn.width - 20 - 10 - 20;
    _imageContainer.height = _imageContainer.width * 3 / 5;
    _imageContainer.top = 20;
    _imageContainer.right = SCREEN_WIDTH - 20;
    _imageContainer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_imageContainer registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _imageContainer.dataSource = self;
    _imageContainer.delegate = self;
    
    addFacesBtn.center = _imageContainer.center;
    addFacesBtn.left = 20;
    [scrollView addSubview:addFacesBtn];
    [scrollView addSubview:_imageContainer];
    
    label = [[UILabel alloc] init];
    label.text = @"Person group to use:";
    label.left = 20;
    label.top = _imageContainer.bottom + 10;
    [scrollView addSubview:label];
    [label sizeToFit];
    
    UIButton * manageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    manageBtn.titleLabel.numberOfLines = 0;
    [manageBtn setTitle:@"Manage Person Groups" forState:UIControlStateNormal];
    manageBtn.width = SCREEN_WIDTH / 3 - 20;
    manageBtn.height = manageBtn.width * 4 / 7;
    manageBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    manageBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [manageBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [manageBtn addTarget:self action:@selector(ManagePersonGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    label.width = manageBtn.width;
    label.adjustsFontSizeToFitWidth = YES;
    
    _groupListView = [[UITableView alloc] init];
    _groupListView.width = SCREEN_WIDTH - manageBtn.width - 20 - 10 - 20;
    _groupListView.height = _groupListView.width * 1 / 2;
    _groupListView.top = label.top;
    _groupListView.right = SCREEN_WIDTH - 20;
    _groupListView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    _groupListView.tableFooterView = [[UIView alloc] init];
    _groupListView.dataSource = self;
    _groupListView.delegate = self;
    
    manageBtn.center = _groupListView.center;
    manageBtn.left = 20;
    manageBtn.top += 10;
    [scrollView addSubview:manageBtn];
    [scrollView addSubview:_groupListView];
    
    label = [[UILabel alloc] init];
    label.text = @"Result:";
    [label sizeToFit];
    label.left = 20;
    label.top = _groupListView.bottom + 10;
    [scrollView addSubview:label];
    
    _resultListView = [[UITableView alloc] init];
    _resultListView.width = SCREEN_WIDTH - 20 - 20;
    _resultListView.height = _imageContainer.width * 5 / 7;
    _resultListView.top = label.bottom + 5;
    _resultListView.left = 20;
    _resultListView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    _resultListView.tableFooterView = [[UIView alloc] init];
    _resultListView.dataSource = self;
    _resultListView.delegate = self;
    _resultListView.allowsSelection = NO;
    [scrollView addSubview:_resultListView];
    
    _identifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _identifyBtn.height = addFacesBtn.height;
    _identifyBtn.width = SCREEN_WIDTH - 40;
    [_identifyBtn setTitle:@"Identify" forState:UIControlStateNormal];
    [_identifyBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    _identifyBtn.left = 20;
    _identifyBtn.top = _resultListView.bottom + 30;
    _identifyBtn.enabled = NO;
    [_identifyBtn addTarget:self action:@selector(identify:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:_identifyBtn];

    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _identifyBtn.bottom + 20);
    [self.view addSubview:scrollView];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self pickImage];
    } else if (buttonIndex == 1) {
        [self snapImage];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage * image;
    if (info[UIImagePickerControllerEditedImage]) {
        image = info[UIImagePickerControllerEditedImage];
    } else {
        image = info[UIImagePickerControllerOriginalImage];
    }
    [image fixOrientation];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"detecting faces";
    [HUD show: YES];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    [client detectWithData:data returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"detection failed" forController:self.navigationController];
            return;
        }
        [_faces removeAllObjects];
        for (MPOFace *face in collection) {
            UIImage *croppedImage = [image crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
            PersonFace *obj = [[PersonFace alloc] init];
            obj.image = croppedImage;
            obj.face = face;
            [_faces addObject:obj];
        }
        _identifyBtn.enabled = NO;
        [_imageContainer reloadData];
        if (collection.count == 0) {
            [CommonUtil showSimpleHUD:@"No face detected." forController:self.navigationController];
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:image forKey:@"UIImagePickerControllerOriginalImage"];
    [self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error){
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:@"Image written to photo album" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }else{
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Error writing to photo album: %@",[error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _groupListView)
        return GLOBAL.groups.count;
    else
        return results.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _groupListView)
        return 35;
    else
        return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * groupCellIdentifier = @"groupCell";
    static NSString * resultCellIdentifier = @"resultCell";
    if (tableView == _groupListView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:groupCellIdentifier];
        }
        cell.textLabel.text = ((PersonGroup*)GLOBAL.groups[indexPath.row]).groupName;
        NSLog(@"%@", GLOBAL.groups);
        //NSLog(@"%@", GLOBAL.groups.);
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:resultCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupCellIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", results[indexPath.row][@"personName"], results[indexPath.row][@"confidence"]];
        cell.imageView.image = ((PersonFace*)results[indexPath.row][@"face"]).image;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _groupListView && _faces.count > 0) {
        _identifyBtn.enabled = YES;
    }
}

#pragma mark -CollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _faces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPOSimpleFaceCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    cell.imageView.image = ((PersonFace*)_faces[indexPath.row]).image;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.width / 3 - 10, collectionView.width / 3 - 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//@end







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

#import "MPOIdentificationViewController.h"
#import "UIImage+FixOrientation.h"
#import "UIImage+Crop.h"
#import "ImageHelper.h"
#import "MPOPersonGroupListController.h"
#import "PersonGroup.h"
#import "GroupPerson.h"
#import "PersonFace.h"
#import "MPOSimpleFaceCell.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>
#import "MBProgressHUD.h"
#import <ProjectOxfordFace/MPOFaceSDK.h>

#define MAX_RESULT_COUNT 20

@interface MPOIdentificationViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource> {
    UITableView * _groupListView;
    UITableView * _resultListView;
    UICollectionView * _imageContainer;
    UIImageView *imageView;
    UIButton * _identifyBtn;
    NSMutableArray * _faces;
    NSMutableArray * _listOfAbsentPpl;
    NSMutableArray *collectionArray;
    NSMutableArray *allFacesArray;
    BOOL thereWereNoFacesDetected;
    NSMutableArray *resultsNamesArr;
    NSMutableArray * results;


}
//@property (strong, nonatomic) UITableView *_resultListView;
//@property (strong, nonatomic) NSMutableArray *_listOfAbsentPpl;



@end

@implementation MPOIdentificationViewController

- (void) saveEmail: (NSString*) m{
    _email=m;
    NSLog(@"%@", _email);
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.content = _listOfAbsentPpl;
//    self._resultListView.delegate = self;
//    self._resultListView.dataSource = self;
//    [self.view addSubview:self._resultListView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Identification";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"back";
    self.navigationItem.backBarButtonItem = backItem;
    [self buildMainUI];
    results = [[NSMutableArray alloc] init];
    _listOfAbsentPpl = [[NSMutableArray alloc] init];
    _faces = [[NSMutableArray alloc] init];
    NSString *str = @"ehoisfjas";
    printf("%s\n", [str UTF8String]);
    resultsNamesArr = [[NSMutableArray alloc] init];
    //imageView = [[UIImageView alloc]init];
//    imageView.image = [UIImage imageNamed:@"people1"];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_groupListView reloadData];
}

- (void)identify:(id)sender {
    NSIndexPath * indexPath = _groupListView.indexPathForSelectedRow;
    
    if (indexPath == nil) {
        [CommonUtil simpleDialog:@"please select a group"];
        return;
    }
    
    NSMutableArray *faceIds = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOfFaceIds = [[NSMutableArray alloc] init];
    
    
    for (int l=0; l<[_faces count]; l++){
//        printf("testa");
        if (l%6==0){
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            [arrayOfFaceIds addObject:temp];
//            printf("testb");
        }
        PersonFace *obj = _faces[l];
        [arrayOfFaceIds[l/6] addObject:obj.face.faceId];
        //printf("testc");
        
    }
    
//    for (PersonFace *obj in _faces) {
//
//        [faceIds addObject:obj.face.faceId];
//    }
    
    PersonGroup * group = GLOBAL.groups[indexPath.row];
    //NSArray * results = [FaceSdkUtil getFaceIndentificationResultsFromPeople:groupPeople andFace:_faces[_selectedTargetIndex]];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Identifying faces";
    [HUD show: YES];
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    
    [results removeAllObjects];
    [resultsNamesArr removeAllObjects];
//    printf("test1");
    for (int j=0; j<[arrayOfFaceIds count]; j++){
        printf("%d", j);

        [client identifyWithLargePersonGroupId:group.groupId faceIds:arrayOfFaceIds[j] maxNumberOfCandidates:group.people.count completionBlock:^(NSArray<MPOIdentifyResult *> *collection, NSError *error) {
            if (error) {
               // [CommonUtil showSimpleHUD:@"Failed in Indentification" forController:self.navigationController];
//                [_listOfAbsentPpl removeAllObjects];
//                for (int a=0; a<group.people.count; a++){
//                    GroupPerson *person = group.people[a];
//                    NSString *nameOfCurrentPerson = person.personName;
//                    printf("Adding when all ppl r absent");
//                    printf("%s\n", [nameOfCurrentPerson UTF8String]);
//                    [_listOfAbsentPpl addObject:nameOfCurrentPerson];
//                }
//                [_resultListView reloadData];
                return;
            }
            for (MPOIdentifyResult * idRestult in collection) {
                
                PersonFace * face = [self getFaceByFaceId:idRestult.faceId];
                
                
                
                for (MPOCandidate * candidate in idRestult.candidates) {
                    GroupPerson * person = [self getPersonInGroup:group withPersonId:candidate.personId];
                    if (person!=nil){
                        [results addObject:@{@"face" : face, @"personName": person.personName, @"confidence" : candidate.confidence}];
                        [resultsNamesArr addObject:person.personName];
                    }
                    
                
                }
                
                [_listOfAbsentPpl removeAllObjects];
                for (int a=0; a<group.people.count; a++){
                    int ifExistsInGroup = 0;//0 is false, 1 is true
                    printf("test1");
                    printf("%lu", (unsigned long)results.count);
                    printf("%lu", (unsigned long)[results count]);
                    for (int b=0; b<resultsNamesArr.count; b++){
                        printf("test2");
                        GroupPerson *person = group.people[a];
                        NSString *nameOfCurrentPerson = person.personName;
                       // GroupPerson *person2 = results[b];
                        //printf("person2");
                       // printf("%s", person2);
                        //printf("%s\n", [person2.personName UTF8String]);
                        printf("test3");
                       // NSString *nameOfCurrentPerson2 = person2.personName;
                         NSString *nameOfCurrentPerson2 = resultsNamesArr[b];
                        printf("comparing names:");
                        
                        printf("%s\n", [nameOfCurrentPerson UTF8String]);
                        printf("comparing names2:");
                        printf("%s\n", [nameOfCurrentPerson2 UTF8String]);
                        
                        if ([nameOfCurrentPerson isEqualToString:nameOfCurrentPerson2]){
                            printf("comparing namesWHIUSFHLJFHAD YFK SUFGJD:");
                            printf("%s\n", [nameOfCurrentPerson UTF8String]);
                            printf("comparing names2FUYGDSKJDYYHKGUYDF");
                            printf("%s\n", [nameOfCurrentPerson2 UTF8String]);
                            ifExistsInGroup = 1;
                        }
                        printf("test4");
                    }
                    if (ifExistsInGroup==0){
                        printf("test5");
                        GroupPerson *person = group.people[a];
                        NSString *nameOfCurrentPerson = person.personName;
                        printf("%s\n", [nameOfCurrentPerson UTF8String]);
                        [_listOfAbsentPpl addObject:nameOfCurrentPerson];
                        
                    }
                }
//                [results removeAllObjects];
                for (int abc = 0; abc<[_listOfAbsentPpl count]; abc++){
                    printf("tryna print absent ppl again");
                    printf("%s\n", [_listOfAbsentPpl[abc] UTF8String]);
//                    [results addObject:@{@"face" : [[PersonFace alloc]init], @"personName":[[NSMutableString alloc]init], @"confidence" : [[NSNumber alloc]init]}];
                }
//                [_resultListView reloadData];
                
            }
                
            
            if (collection.count == 0) {
               // [CommonUtil showSimpleHUD:@"No result." forController:self.navigationController];
            }
            
            [_resultListView reloadData];
            
            if (j==[arrayOfFaceIds count]-1){
                printf("narwhals1");
               // [self findAbsentees:group];
                printf("narwhalsdone");
//                [_resultListView reloadData];
                
                if ([_listOfAbsentPpl count]==0){
                    printf("should display a hud rn");
                    [CommonUtil showSimpleHUD:@"All students are present." forController:self.navigationController];
                }


            }
                
        }];
        [_resultListView reloadData];

    }
      [HUD removeFromSuperview];


    
}

-(void) findAbsentees: (PersonGroup*) group{
    
    
    
}
- (PersonFace*) getFaceByFaceId: (NSString*) faceId {
    for (PersonFace * face in _faces) {
        if ([face.face.faceId isEqualToString:faceId]) {
            return face;
        }
    }
    return nil;
}

- (GroupPerson*) getPersonInGroup:(PersonGroup*)group withPersonId: (NSString*) personId {
    for (GroupPerson * person in group.people) {
        if ([person.personId isEqualToString:personId]) {
            return person;
        }
    }
    return nil;
}

- (void)chooseImage: (id)sender {
    UIActionSheet * choose_photo_sheet = [[UIActionSheet alloc]
                                          initWithTitle:@"Select Image"
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"Select from album", @"Take a photo",nil];
    [choose_photo_sheet showInView:self.view];
}

- (void)pickImage {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)snapImage {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)ManagePersonGroupAction:(id)sender {
    MPOPersonGroupListController * controller = [[MPOPersonGroupListController alloc] init];
    [controller saveEmailPersonGroup:_email];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildMainUI {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
    
    UILabel * label = [[UILabel alloc] init];
    label.text = @"Target Image:";
    label.left = 20;
    label.top = 20;
    [scrollView addSubview:label];
    [label sizeToFit];
    
    UIImage * btnBackImage = [CommonUtil imageWithColor:[UIColor robinEggColor]];
    UIButton * addFacesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addFacesBtn.titleLabel.numberOfLines = 0;
    [addFacesBtn setTitle:@"Select Image" forState:UIControlStateNormal];
    addFacesBtn.width = SCREEN_WIDTH / 3 - 20;
    addFacesBtn.height = addFacesBtn.width * 3 / 7;
    addFacesBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    addFacesBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [addFacesBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [addFacesBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    label.width = addFacesBtn.width;
    label.adjustsFontSizeToFitWidth = YES;
    
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc] init];
    _imageContainer = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    imageView = [[UIImageView alloc]init];
    _imageContainer.width = SCREEN_WIDTH - addFacesBtn.width - 20 - 10 - 20;
    imageView.width =SCREEN_WIDTH - addFacesBtn.width - 20 - 10 - 20;
    _imageContainer.height = _imageContainer.width * 3 / 5;
    imageView.height =_imageContainer.width * 3 / 5;
    _imageContainer.top = 20;
    imageView.top = 20;
    _imageContainer.right = SCREEN_WIDTH - 20;
    imageView.right = SCREEN_WIDTH-20;
    _imageContainer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    imageView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [_imageContainer registerNib:[UINib nibWithNibName:@"MPOSimpleFaceCell" bundle:nil] forCellWithReuseIdentifier:@"faceCell"];
    _imageContainer.dataSource = self;
    _imageContainer.delegate = self;
    
    addFacesBtn.center = _imageContainer.center;
    addFacesBtn.left = 20;
    [scrollView addSubview:addFacesBtn];
    [scrollView addSubview:_imageContainer];
    [scrollView addSubview:imageView];
    
    
    label = [[UILabel alloc] init];
    label.text = @"Group to use:";
    label.left = 20;
    label.top = _imageContainer.bottom + 10;
    [scrollView addSubview:label];
    [label sizeToFit];
    
    UIButton * manageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    manageBtn.titleLabel.numberOfLines = 0;
    [manageBtn setTitle:@"Manage Groups" forState:UIControlStateNormal];
    manageBtn.width = SCREEN_WIDTH / 3 - 20;
    manageBtn.height = manageBtn.width * 4 / 7;
    manageBtn.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    manageBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [manageBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    [manageBtn addTarget:self action:@selector(ManagePersonGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    label.width = manageBtn.width;
    label.adjustsFontSizeToFitWidth = YES;
    
    _groupListView = [[UITableView alloc] init];
    _groupListView.width = SCREEN_WIDTH - manageBtn.width - 20 - 10 - 20;
    _groupListView.height = _groupListView.width * 1 / 2;
    _groupListView.top = label.top;
    _groupListView.right = SCREEN_WIDTH - 20;
    _groupListView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    _groupListView.tableFooterView = [[UIView alloc] init];
    _groupListView.dataSource = self;
    _groupListView.delegate = self;
    
    manageBtn.center = _groupListView.center;
    manageBtn.left = 20;
    manageBtn.top += 10;
    [scrollView addSubview:manageBtn];
    [scrollView addSubview:_groupListView];
    
    label = [[UILabel alloc] init];
    label.text = @"List of Absentees:";
    [label sizeToFit];
    label.left = 20;
    label.top = _groupListView.bottom + 10;
    [scrollView addSubview:label];
    
    _resultListView = [[UITableView alloc] init];
    _resultListView.width = SCREEN_WIDTH - 20 - 20;
    _resultListView.height = _imageContainer.width * 5 / 7;
    _resultListView.top = label.bottom + 5;
    _resultListView.left = 20;
    _resultListView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    _resultListView.tableFooterView = [[UIView alloc] init];
    _resultListView.dataSource = self;
    _resultListView.delegate = self;
    _resultListView.allowsSelection = NO;
    //_resultListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [scrollView addSubview:_resultListView];
    
    _identifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _identifyBtn.height = addFacesBtn.height;
    _identifyBtn.width = SCREEN_WIDTH - 40;
    [_identifyBtn setTitle:@"Identify" forState:UIControlStateNormal];
    [_identifyBtn setBackgroundImage:btnBackImage forState:UIControlStateNormal];
    _identifyBtn.left = 20;
    _identifyBtn.top = _resultListView.bottom + 30;
    _identifyBtn.enabled = NO;
    [_identifyBtn addTarget:self action:@selector(identify:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:_identifyBtn];
    
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, _identifyBtn.bottom + 20);
    [self.view addSubview:scrollView];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self pickImage];
    } else if (buttonIndex == 1) {
        [self snapImage];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage * image;
    if (info[UIImagePickerControllerEditedImage]) {
        image = info[UIImagePickerControllerEditedImage];
    } else {
        image = info[UIImagePickerControllerOriginalImage];
    }
    [image fixOrientation];
    imageView.image = image;

    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"detecting faces";
    [HUD show: YES];
    
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithEndpointAndSubscriptionKey:ProjectOxfordFaceEndpoint key:ProjectOxfordFaceSubscriptionKey];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray * imageArray = [[NSMutableArray alloc] init];
    NSMutableArray * imageArray2 = [[NSMutableArray alloc] init];
    NSMutableArray * imageArray3 = [[NSMutableArray alloc] init];
    NSMutableArray * imageArray4 = [[NSMutableArray alloc] init];
    NSMutableArray * imageArray5 = [[NSMutableArray alloc] init];


    //to add the images to the array ->
//    UIImage *image1 = [UIImage imageNamed:@"people1"];
//    UIImage *image2 = [UIImage imageNamed:@"people2"];

    //[imageArray addObject: image1];
   // [image1 fixOrientation];
    
    //image = image1;
    
    
    UIImage *imageScaled = [self imageWithImage:image convertToSize:CGSizeMake(image.size.width*4, image.size.height*4)];

    
    
    
    imageArray2 = [self getImagesFromImage:imageScaled withRow:2 withColumn: 2];
    imageArray3 = [self getImagesFromImage:imageScaled withRow:3 withColumn: 3];
//    imageArray4 = [self getImagesFromImage:imageScaled withRow:4 withColumn: 4];
    //imageArray5 = [self getImagesFromImage:imageScaled withRow:5 withColumn: 5];

    [imageArray addObject:imageScaled];
    
    
    
    for (int i=0; i<[imageArray2 count]; i++){
        [imageArray addObject:imageArray2[i]];
        printf("abcd1");
    }

//    for (int i=0; i<[imageArray3 count]; i++){
//        [imageArray addObject:imageArray3[i]];
//        printf("abcd2");
//    }
//    for (int i=0; i<[imageArray4 count]; i++){
//        [imageArray addObject:imageArray4[i]];
//        printf("3");
//    }
//    for (int i=0; i<[imageArray5 count]; i++){
//        [imageArray addObject:imageArray5[i]];
//        printf("4");
//    }
//    [imageArray addObject: imageArray2[1]];
    
    
//    [imageArray addObject: imageArray2[2]];


    //remove all the faces
    [_faces removeAllObjects];
    
    //loop through
    
    collectionArray = [[NSMutableArray alloc] init];
    allFacesArray = [[NSMutableArray alloc] init];
    __block int *imageArrayLengthLoop = [imageArray count];

    
    for (UIImage *specImage in imageArray){
        NSData *data = UIImageJPEGRepresentation(specImage, 0.8);
        [client detectWithData:data returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
            printf("adf");

//            if (error) {
//                //[CommonUtil showSimpleHUD:@"detection failed" forController:self.navigationController];
//                return;
//            }
            for (MPOFace *face in collection) {
                UIImage *croppedImage = [specImage crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
                PersonFace *obj = [[PersonFace alloc] init];
                obj.image = croppedImage;
                obj.face = face;
                [_faces addObject:obj];
                printf("srutdryjhi");
                [allFacesArray addObject:obj];
                thereWereNoFacesDetected = false;

            }
            _identifyBtn.enabled = NO;
            [_imageContainer reloadData];
//            if (collection.count == 0) {
//                [CommonUtil showSimpleHUD:@"No face detected." forController:self.navigationController];
//            }
//            imageArrayLengthLoop--;

            [collectionArray addObject:collection];
            
            printf("sruthi2");

            printf("%u\n", imageArrayLengthLoop);
            if (imageArrayLengthLoop==1) {
                printf("dhruvi");
                [self finalPicture];
                [HUD removeFromSuperview];
                
            }
            imageArrayLengthLoop--;
            printf("sruthi");
            
            printf("%u\n", imageArrayLengthLoop);
            
           
        }];
       
    }
    

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:image forKey:@"UIImagePickerControllerOriginalImage"];
    [self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error){
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:@"Image written to photo album" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }else{
        UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Error writing to photo album: %@",[error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
}

#pragma mark - UITableViewDataSource

-(void)finalPicture{
    BOOL checkIfEmpty;
    checkIfEmpty = true;
    printf("numbersuhflusfhaulis");
    printf("%lu\n", (unsigned long)_faces.count);
    if (allFacesArray.count==0){
        [CommonUtil showSimpleHUD:@"There was an error with the API, please wait a few seconds and select the image again." forController:self.navigationController];

        
    }
    if (thereWereNoFacesDetected){
        printf("crying");
    }
//    for (int i=0; i<[collectionArray count]; i++){
//        if ([(NSArray *)collectionArray[i] count] != 0) {
//            checkIfEmpty = false;
//            printf("hellloooooo");
//            printf("%u\n",i);
//        }
//    }
    
    
//    if (checkIfEmpty){
//        [CommonUtil showSimpleHUD:@"No face detected." forController:self.navigationController];
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _groupListView)
        return GLOBAL.groups.count;
    else
        return _listOfAbsentPpl.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _groupListView)
        return 35;
    else
        return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * groupCellIdentifier = @"groupCell";
    static NSString * resultCellIdentifier = @"resultCell";
    printf("yay its kinda working");
    
    if (tableView == _groupListView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:groupCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:groupCellIdentifier];
        }
        cell.textLabel.text = ((PersonGroup*)GLOBAL.groups[indexPath.row]).groupName;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else if (tableView==_resultListView){
        printf("yay its working");
        printf("countingstuff");
        printf("%lu", (unsigned long)[_listOfAbsentPpl count]);
        if ([_listOfAbsentPpl count] == 0){
//            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//            [self.navigationController.view addSubview:HUD];
//            HUD.labelText = @"Identifying faces";
//            [HUD show: YES];
//            [HUD removeFromSuperView];
//            printf("should display a hud rn");
//            [CommonUtil showSimpleHUD:@"Empty." forController:self.navigationController];

//
        }
        for (int abc = 0; abc<[_listOfAbsentPpl count]; abc++){
            printf("tryna print absent ppl");
            printf("%s\n", [_listOfAbsentPpl[abc] UTF8String]);
        }
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:resultCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:resultCellIdentifier];
        }
//        if (indexPath.row<=[_listOfAbsentPpl count]-1){
            cell.textLabel.text = _listOfAbsentPpl[indexPath.row];
//        }else{
//            cell.textLabel.text = @"";

//        }
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else {
        printf("boo its not working");
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:resultCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupCellIdentifier];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", _listOfAbsentPpl[indexPath.row][@"personName"], results[indexPath.row][@"confidence"]];
        cell.imageView.image = ((PersonFace*)results[indexPath.row][@"face"]).image;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _groupListView && _faces.count > 0) {
        _identifyBtn.enabled = YES;
    }
}

#pragma mark -CollectionView datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _faces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MPOSimpleFaceCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    cell.imageView.image = ((PersonFace*)_faces[indexPath.row]).image;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.width / 3 - 10, collectionView.width / 3 - 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(NSMutableArray *)getImagesFromImage:(UIImage *)image withRow:(NSInteger)rows withColumn:(NSInteger)columns
{
    NSMutableArray *images = [NSMutableArray array];
    CGSize imageSize = image.size;
    CGFloat xPos = 0.0, yPos = 0.0;
    CGFloat width = imageSize.width/rows;
    CGFloat height = imageSize.height/columns;
    for (int y = 0; y < columns; y++) {
        xPos = 0.0;
        for (int x = 0; x < rows; x++) {
            
            CGRect rect = CGRectMake(xPos, yPos, width, height);
            CGImageRef cImage = CGImageCreateWithImageInRect([image CGImage],  rect);
            
            UIImage *dImage = [[UIImage alloc] initWithCGImage:cImage];
            [images addObject:dImage];
            xPos += width;
        }
        yPos += height;
    }
    return images;
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}


@end

