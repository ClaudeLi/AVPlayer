//
//  PlayerViewController.m
//  AVPlayer
//
//  Created by ClaudeLi on 16/4/13.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "PlayerViewController.h"
#import "CLRotatingScreen.h"
#define MovieURL @"http://7s1sjv.com2.z0.glb.qiniucdn.com/9F76A25D-9509-DEE9-3D8A-E93F360BB0E5.mp4"

static NSString *cellIdentifier = @"cellIdentifier";

@interface PlayerViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UIInterfaceOrientation   _lastOrientation;
    BOOL _isRoting;
}
@property (weak, nonatomic) IBOutlet UIView *downBGView;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatTableView];
    [self.videoPlayer updatePlayerWith:[NSURL URLWithString:MovieURL]];
    [CLRotatingScreen forceOrientation: UIInterfaceOrientationPortrait];
}

- (void)dealloc{
    [self.videoPlayer removeObserverAndNotification];
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//iOS8旋转动作的具体执行
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator: coordinator];
    // 监察者将执行： 1.旋转前的动作  2.旋转后的动作（completion）
    [coordinator animateAlongsideTransition: ^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         if ([CLRotatingScreen isOrientationLandscape]) {
             _lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
             [self p_prepareFullScreen];
         }
         else {
             [self p_prepareSmallScreen];
         }
     } completion: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
     }];
    
}

//iOS7旋转动作的具体执行
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeRight || toInterfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        _lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
        [self p_prepareFullScreen];
    }
    else {
        [self p_prepareSmallScreen];
    }
}

#pragma mark - Private

// 切换成全屏的准备工作
- (void)p_prepareFullScreen {
    self.downBGView.hidden = YES;
    _headerHeight.constant = 0;
    [self.videoPlayer setlandscapeLayout];
}

// 切换成小屏的准备工作
- (void)p_prepareSmallScreen {
    self.downBGView.hidden = NO;
    _headerHeight.constant = KNavigatHeight;
    [self.videoPlayer setPortraitLayout];
}

- (BOOL)shouldAutorotate{
    return !self.videoPlayer.isLockScreen;
}

- (void)creatTableView
{
    UITableView *videoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - KNavigatHeight - KScreenWidth/16*9) style:UITableViewStylePlain];
    videoTableView.backgroundColor = [UIColor whiteColor];
    videoTableView.delegate = self;
    videoTableView.dataSource = self;
    videoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.downBGView addSubview:videoTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor randomColor];
    cell.textLabel.text = integerToString(indexPath.row);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
