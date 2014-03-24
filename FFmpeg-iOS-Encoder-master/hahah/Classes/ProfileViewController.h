// ProfileViewController.h
//
// Copyright (c) 2010 wangyong

#import <UIKit/UIKit.h>

@class TTTQuadrantControl;

@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UIImageView *_avatarImageView;
    UILabel *_nameLabel;
    UILabel *_twitterUsernameLabel;
    UILabel *_twitterUserIDLabel;
    
    TTTQuadrantControl *_quadrantControl;
}

@property (nonatomic, retain) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *twitterUsernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *twitterUserIDLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet TTTQuadrantControl *quadrantControl;


@end
