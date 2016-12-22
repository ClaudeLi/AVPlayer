# AVPlayer
视频播放器，基于AVFoundation框架，实现类似腾讯视频的全屏播放及小屏播放 

        类似效果
        ![](https://github.com/ClaudeLi/AVPlayer/blob/master/20141121215131793.png)
        ![](https://github.com/ClaudeLi/AVPlayer/blob/master/20141121215205505.png)

        1.旋转至全屏
        - (void)setLandscapeController:(TTPlayerOrientation)toOrientation{
            CGFloat angle = -M_PI_2;
            if (toOrientation == TTPlayerOrientationHomeRight) {
                angle = -M_PI_2;
            }else if (toOrientation == TTPlayerOrientationHomeLeft){
                angle = M_PI_2;
            }else{
                return;
            }
            _isFullScreen = YES;
            landscapeViewController.orientation = toOrientation;
            [_parentView.viewController presentViewController:landscapeViewController animated:NO completion:^{
            [self.view removeFromSuperview];
            [self removeFromParentViewController];

            [landscapeViewController addChildViewController:self];
            [landscapeViewController.view addSubview:self.view];

            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [self.playerView setLandscapeLayout];

            //旋转前
            CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
            transform = CGAffineTransformScale(transform, 1.0, 1.0);
            self.view.transform = transform;
            self.view.center = landscapeViewController.view.center;
            //旋转动画
            [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] animations:^{
            self.view.transform = CGAffineTransformIdentity;
            self.view.frame = landscapeViewController.view.bounds;
            }completion:^(BOOL finished) {
            //            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            }];
            }];
        }
        
        2.旋转至竖屏
        - (void)setPortraitController:(TTPlayerOrientation)fromOrientation{
            CGFloat angle = M_PI_2;
            if (fromOrientation == TTPlayerOrientationHomeLeft) {
                angle = -M_PI_2;
            }else if (fromOrientation == TTPlayerOrientationHomeRight){
                angle = M_PI_2;
            }else{
                return;
            }
            [landscapeViewController dismissViewControllerAnimated:NO completion:^{
            [self.view removeFromSuperview];
            [self removeFromParentViewController];

            [_parentView.viewController addChildViewController:self];
            [_parentView addSubview:self.view];

            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self.playerView setPortraitLayout];
            //缩放动画
            CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.view.transform = transform;
            self.view.frame = _frame;
            self.view.transform = CGAffineTransformRotate(transform, angle);

            [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration]
            animations:^{
            self.view.transform = CGAffineTransformIdentity;
            }
            completion:^(BOOL finished) {
            self.view.frame = _frame;
            }];
            }];
        }
        
