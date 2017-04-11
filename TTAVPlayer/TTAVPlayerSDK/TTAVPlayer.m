//
//  TTAVPlayer.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/14.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTAVPlayer.h"
#import "TTAVPlayerSDK.h"
#import "TTPlayerManager.h"

static void * TTAVPlayerStatusContext = &TTAVPlayerStatusContext;
static void * TTAVPlayerLoadedTimeRangesContext = &TTAVPlayerLoadedTimeRangesContext;

// 网络判断
#define  NetworkStatus  0

@interface TTAVPlayer ()<UIAlertViewDelegate>{
    NSFileManager *_fileManager;
    NSTimeInterval _rotateTime;
}

@property (nonatomic, strong) AVPlayer       *player;
@property (nonatomic, strong) AVPlayerItem   *playerItem;
@property (nonatomic, strong) AVURLAsset     *urlAsset;

@property (nonatomic, strong) id playTimeObserver;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (nonatomic, strong) TTVideoItem *lastVideoItem;

@property (nonatomic, assign) NSInteger lastIndex;

@end

@implementation TTAVPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayerLayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.index = -1;
        self.backgroundColor = [UIColor blackColor];
        _fileManager = [NSFileManager defaultManager];
        NSError *audioSessionError;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError];
        if (audioSessionError) {
            TTLog(@"%@", audioSessionError);
        }
        // 前后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        // 注册监听，屏幕方向改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientChangeNotification) name:UIDeviceOrientationDidChangeNotification object:nil];
        // 播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    }
    return self;
}

- (void)enterForegroundNotification{
    if (self.playerEnterForegroundBlock) {
        self.playerEnterForegroundBlock();
    }
}

- (void)resignActiveNotification{
    if (self.playerResignActiveBlock) {
        self.playerResignActiveBlock();
    }
}

- (void)deviceOrientChangeNotification{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if (nowTime - _rotateTime < 0.5) {
        _rotateTime = nowTime;
    }else{
        _rotateTime = nowTime;
        if (self.playerDirectionChange) {
            self.playerDirectionChange();
        }
    }
}

- (void)setItemArray:(NSArray *)itemArray{
    _itemArray = itemArray;
}

- (void)setIndex:(NSInteger)index{
    _index = index;
}

- (void)setVideoItem:(TTVideoItem *)videoItem{
    _videoItem = videoItem;
    [self _initPlayer];
}

- (void)_initPlayer{
    if (_playerItem) {
        [self removePlayerObserver];
    }
    if (self.playerDelayPlay) {
        self.playerDelayPlay(NO);
    }
    _canPlay = NO;
    self.lastVideoItem = [self getVideoItem];
    self.lastIndex = _index;
    self.urlAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.lastVideoItem.playUrl] options:nil];
    _playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    [self addPlayerObserver];
    [self setPlayerLayer:self.player];
    if (_rate) {
        self.player.rate = _rate;
    }
    if (self.playerReadyToPlay) {
        self.playerReadyToPlay();
    }
//    if (self.player.currentItem) {
//        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
//    }else {
//    }
}

- (TTVideoItem *)getVideoItem{
    NSString *path = [NSString stringWithFormat:@"%@/Documents/TTVideo/%@.mp4",NSHomeDirectory(), _videoItem.vid];
    BOOL exist = [_fileManager fileExistsAtPath:path];
    if (exist) { // 判读视频是否已下载
        _videoItem.playUrl = [[NSURL fileURLWithPath:path] absoluteString];
        _videoItem.isNetwork = NO;
    }else {
        _videoItem.playUrl = _videoItem.url;
        _videoItem.isNetwork = YES;
    }
    return _videoItem;
}

- (void)addPlayerObserver{
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:TTAVPlayerStatusContext];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:TTAVPlayerLoadedTimeRangesContext];
    [self monitoringPlayback:_playerItem];//监听播放状态
}


-(void)playbackFinished:(NSNotification *)notification{
    if ([notification object] == _playerItem) {
        TTLog(@"视频播放完成.");
        TT_WS(ws);
        [_playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            if (ws.playerPlayEndBlock) {
                ws.playerPlayEndBlock();
            }
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context{
    if (object == _playerItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
                _canPlay = YES;
                CMTime duration = _playerItem.duration; //获取视屏总长
                CGFloat totalSeconds = CMTimeGetSeconds(duration);//转换成秒
                if (self.playerTotalTimeBlock) {
                    self.playerTotalTimeBlock(totalSeconds);
                }
            }else if (_playerItem.status == AVPlayerItemStatusUnknown){
                _canPlay = NO;
                [self stop];
                if (self.playerToClosePlayer) {
                    self.playerToClosePlayer();
                }
                TTLog(@"未知错误,播放失败,请重试");
            }else if (_playerItem.status == AVPlayerStatusFailed){
                _canPlay = NO;
                [self stop];
                if (self.playerToClosePlayer) {
                    self.playerToClosePlayer();
                }
                TTLog(@"播放失败,请重试");
            }
        }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
            if (TTAVManager.isAllowedToPlay || !_videoItem.isNetwork) {
                [self startLoading];
            }else{
                if (NetworkStatus) { // 这里做网络判断流量还是wifi
                    [self stop];
                    if (IOS8) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您当前处于非WiFi网络" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                            TTAVManager.isAllowedToPlay = YES;
                            [self _initPlayer];
                        }];
                        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                            if (self.playerToClosePlayer) {
                                self.playerToClosePlayer();
                            }
                        }];
                        [alert addAction:action];
                        [alert addAction:action1];
                        [self.viewController presentViewController:alert animated:YES completion:nil];
                    }else{
                        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"您当前处于非WiFi网络" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil] show];
                    }
                }else{
                    [self startLoading];
                }
            }
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        TTAVManager.isAllowedToPlay = YES;
        [self _initPlayer];
    }else{
        if (self.playerToClosePlayer) {
            self.playerToClosePlayer();
        }
    }
}

- (void)startLoading{
    NSTimeInterval timeInterval = [self availableDurationRanges];
    CMTime duration = _playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    if (timeInterval > 0 && totalDuration > 0) {
        if (self.playerLoadedTimeBlock) {
            self.playerLoadedTimeBlock((CGFloat)timeInterval/(totalDuration*1.0));
        }
    }
}

- (NSTimeInterval)availableDurationRanges {
    NSArray *loadedTimeRanges = [_playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark -- _playTimeObserver
- (void)monitoringPlayback:(AVPlayerItem *)item {
    TT_WS(ws);
    //这里设置每秒执行30次
    _playTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 计算当前在第几秒
        CGFloat timescale = item.currentTime.timescale * 1.0;
        CGFloat currentPlayTime = (CGFloat)item.currentTime.value/timescale;
        if (currentPlayTime >= 0 && timescale > 0) {
            if (ws.playerCurrentTimeBlock) {
                ws.playerCurrentTimeBlock(currentPlayTime);
            }
        }
    }];
}

- (void)update{
    if (_player) {
        NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
        if (current == self.lastTime) {
            // 卡顿
            if (self.playerDelayPlay) {
                self.playerDelayPlay(YES);
            }
        }else{// 没有卡顿
            if (self.playerDelayPlay) {
                self.playerDelayPlay(NO);
            }
        }
        self.lastTime = current;
    }
}

#pragma mark -
#pragma mark -- 接口 --
- (void)play{
    [self.player play];
    if (!self.link) {
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];//和屏幕频率刷新相同的定时器
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)pause{
    if (self.link) {
        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        self.link = nil;
    }
    [self.player pause];
}


- (void)stop{
    [self removePlayerObserver];
    if (self.playerToStop) {
        self.playerToStop();
    }
}

- (void)cancleLoading{
    if (_player) {
        [_player.currentItem cancelPendingSeeks];
        [_player.currentItem.asset cancelLoading];
    }
}

- (CGFloat)currentTime {
    if (_player) {
        return CMTimeGetSeconds([self.player currentTime]);
    }
    return 0.0f;
}


- (CGFloat)totalTime {
    if (_player.currentItem) {
        return CMTimeGetSeconds(self.player.currentItem.duration);
    }
    return 0.0f;
}

- (void)seekToTime:(float)seconds completionHandler:(void (^)(BOOL finished))completionHandler{
    if (_canPlay) {
        //转换成CMTime才能给player来控制播放进度
        CMTime dragedCMTime = CMTimeMake(seconds, 1);
        [_playerItem seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
            if (completionHandler) {
                completionHandler(finished);
            }
        }];
    }
}

- (void)setRate:(CGFloat)rate{
    _rate = rate;
    self.player.rate = rate;
}

#pragma mark -
#pragma mark -- removeObserver --
- (void)removePlayerObserver{
    if (_player) {
        TTLog(@"%s", __func__);
        [self pause];
        [_player.currentItem cancelPendingSeeks];
//        [_player.currentItem.asset cancelLoading];
        [_player replaceCurrentItemWithPlayerItem:nil];
        if (_playTimeObserver) {
            [_player removeTimeObserver:_playTimeObserver];
            _playTimeObserver = nil;
        }
        if (_playerItem) {
            [_playerItem removeObserver:self forKeyPath:@"status" context:TTAVPlayerStatusContext];
            [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:TTAVPlayerLoadedTimeRangesContext];
            _playerItem = nil;
        }
        _player = nil;
    }
}

- (void)dealloc{
    TTLog(@"%s", __func__);
    [self close];
}

- (void)close{
    [self removePlayerObserver];
    [self removeNotifications];
}

- (void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)floatToString:(float)time{
    return [NSString stringWithFormat:@"%f", time];
}

@end
