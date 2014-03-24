// ProfileViewController.m
//
// Copyright (c) 2010 wangyong

#import <QuartzCore/QuartzCore.h>
#import "ProfileViewController.h"
#import "ButtonTypeQuadrantControl.h"
#import "ImageShowViewController.h"

enum {
	InformationSectionIndex,
} ProfileSectionIndicies;

enum {
	BioRowIndex,
	LocationRowIndex,
	WebsiteRowIndex,
} InformationSectionRowIndicies;

@implementation ProfileViewController
@synthesize avatarImageView = _avatarImageView;
@synthesize nameLabel = _nameLabel;
@synthesize twitterUsernameLabel = _twitterUsernameLabel;
@synthesize twitterUserIDLabel = _twitterUserIDLabel;
@synthesize quadrantControl = _quadrantControl;
@synthesize tableView = _tableView;
@synthesize firstView = _firstView;
@synthesize secondView = _secondView;

- (id)init {
    self = [super initWithNibName:@"ProfileViewController" bundle:nil];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)dealloc {
    [_avatarImageView release];
    [_nameLabel release];
    [_twitterUsernameLabel release];
    [_twitterUserIDLabel release];
	[_quadrantControl release];
    [_firstView release];
    [_secondView release];
    [_tableView release];
    [super dealloc];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setScrollEnabled:NO];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    self.tableView.rowHeight = 44.0f;
    
	self.avatarImageView.layer.cornerRadius = 30.0f;
	self.avatarImageView.layer.borderWidth = 1.0f;
	self.avatarImageView.layer.masksToBounds = YES;
	self.avatarImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.avatarImageView setImage:[UIImage imageNamed:@"psb.jpg"]];
    
    
    self.quadrantControl.delegate = self;
	[self.quadrantControl setNumber:[NSNumber numberWithInt:190]
                            caption:@"following"
                             action:@selector(didSelectFollowingQuadrant)
                        forLocation:TopLeftLocation];
	
	[self.quadrantControl setNumber:[NSNumber numberWithInt:2969]
                            caption:@"tweets" 
                             action:@selector(didSelectTweetsQuadrant)
                        forLocation:TopRightLocation];
	
	[self.quadrantControl setNumber:[NSNumber numberWithInt:1013] 
                            caption:@"followers" 
                             action:@selector(didSelectFollowersQuadrant)
                        forLocation:BottomLeftLocation];
	
	[self.quadrantControl setNumber:[NSNumber numberWithInt:115] 
                            caption:@"listed" 
                             action:@selector(didSelectListedQuadrant)
                        forLocation:BottomRightLocation];	
    
    UIView *viewBK = [[[UIView alloc] initWithFrame:CGRectMake(0, 40, 320, 70)] autorelease];
    [viewBK setBackgroundColor:[UIColor blackColor]];
    [viewBK setAlpha:.1];
    [self.firstView insertSubview:viewBK atIndex:0];
    [self.secondView setTop:self.firstView.bottom];
    [self.tableView setTop:self.secondView.bottom];
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, self.firstView.bottom, 320, 480)] autorelease]; 
    [imageView setImage:[UIImage imageNamed:@"ProfileViewBk"]];
    [self.view insertSubview:imageView atIndex:0];
    
    UITapGestureRecognizer *recognizer=[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraBtnPushed)] autorelease];
  
    [self.avatarImageView setUserInteractionEnabled:YES];
    
    [self.avatarImageView addGestureRecognizer:recognizer];
    
  
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _avatarImageView = nil;
    _nameLabel = nil;
    _twitterUsernameLabel = nil;
    _twitterUserIDLabel = nil;
    _quadrantControl = nil;
    _firstView = nil;
    _secondView = nil;
    _tableView = nil;
    
}

#pragma mark - Actions

- (void)didSelectFollowingQuadrant {
	NSLog(@"Following");
}

- (void)didSelectTweetsQuadrant {
	NSLog(@"Tweets");
}

- (void)didSelectFollowersQuadrant {
	NSLog(@"Followers");
}

- (void)didSelectListedQuadrant {
	NSLog(@"Listed");
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case BioRowIndex:
            return 77.0f;
        default:
            return tableView.rowHeight;
    }
}

- (void)cameraBtnPushed {
    
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"更改头像"
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"从我的相簿中选取", @"拍一张", nil] autorelease];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:[self.view window]];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 2 && [UIImagePickerController isSourceTypeAvailable:buttonIndex])
    {
        
        UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.delegate = (id)self;
        picker.sourceType = buttonIndex;
    
        [self.view.window.rootViewController presentModalViewController:picker animated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    ImageShowViewController *imageShowCropViewController = [[[ImageShowViewController alloc] initWithImage:image] autorelease];
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        [picker presentModalViewController:imageShowCropViewController animated:YES];
    }
    else
    {
        [picker pushViewController:imageShowCropViewController animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = nil;

	switch (indexPath.row) {
		case BioRowIndex:
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
										   reuseIdentifier:nil] autorelease];
			cell.textLabel.text = NSLocalizedString(@"Kainan Wang from the Haidian, living in Beijing, @austinrb", nil);
			cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.numberOfLines = 0;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			break;
		case LocationRowIndex:
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
										   reuseIdentifier:nil] autorelease];
			cell.textLabel.text = NSLocalizedString(@"location", nil);
			cell.detailTextLabel.text = NSLocalizedString(@"Haidian Beijing, TX", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
		case WebsiteRowIndex:
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
										   reuseIdentifier:nil] autorelease];
			cell.textLabel.text = @"web";
			cell.detailTextLabel.text = @"http://ssnhitfkgdgd.me";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			break;
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

