// ProfileViewController.h
//
// Copyright (c) 2010 wangyong

@class ButtonTypeQuadrantControl;

@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate> {
	UIImageView *_avatarImageView;
    UILabel *_nameLabel;
    UILabel *_twitterUsernameLabel;
    UILabel *_twitterUserIDLabel;

    ButtonTypeQuadrantControl *_quadrantControl;
}

@property (nonatomic, retain) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *twitterUsernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *twitterUserIDLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIView *firstView;
@property (nonatomic, retain) IBOutlet UIView *secondView;

@property (nonatomic, retain) IBOutlet ButtonTypeQuadrantControl *quadrantControl;

- (void)cameraBtnPushed;
@end
