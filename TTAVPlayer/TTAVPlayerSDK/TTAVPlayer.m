//
//  TTAVPlayer.m
//  Tiaooo
//
//  Created by ClaudeLi on 16/11/14.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "TTAVPlayer.h"
#import "TTAVPlayerSDK.h"

@interface TTAVPlayer ()

@property (nonatomic, strong) AVPlayer       *player;
@property (nonatomic, strong) AVPlayerItem   *playerItem;
@property (nonatomic, strong) AVURLAsset     *urlAsset;

@property (nonatomic, strong) id playTimeObserver;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSTimeInterval lastTime;

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
        self.backgroundColor = [UIColor blackColor];
        // 前后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActiveNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        // 注册监听，屏幕方向改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientChangeNotification) name:UIDeviceOrientationDidChangeNotification object:nil];
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
    TTLog(@"%s", __func__);
    if (self.playerDirectionChange) {
        self.playerDirectionChange();
    }
}

- (void)setUrlString:(NSString *)urlString{
    _urlString = urlString;
    [self _initPlayer];
}

- (void)_initPlayer{
    //限制锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if (_playerItem) {
        [self removePlayerObserver];
    }
    if (self.playerDelayPlay) {
        self.playerDelayPlay(NO);
    }
    _canPlay = NO;
    self.urlAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:_urlString] options:nil];
    _playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    [self addPlayerObserver];
    [self setPlayerLayer:self.player];
//    if (self.player.currentItem) {
//        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
//    }else {
//    }
}

- (void)addPlayerObserver{
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


-(void)playbackFinished:(NSNotification *)notification{
    TTLog(@"视频播放完成.");
    TT_WS(ws);
    _playerItem = [notification object];
    [_playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (ws.playerPlayEndBlock) {
            ws.playerPlayEndBlock();
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            _canPlay = YES;
            CMTime duration = _playerItem.duration; //获取视屏总长
            CGFloat totalSeconds = CMTimeGetSeconds(duration);//转换成秒
            if (self.playerTotalTimeBlock) {
                self.playerTotalTimeBlock(totalSeconds);
            }
            [self monitoringPlayback:_playerItem];//监听播放状态
        }else if (playerItem.status == AVPlayerItemStatusUnknown){
            TTLog(@"播放未知");
            _canPlay = NO;
        }else if (playerItem.status == AVPlayerStatusFailed){
            TTLog(@"播放失败");
            _canPlay = NO;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSTimeInterval timeInterval = [self availableDurationRanges];
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
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
        CGFloat currentPlayTime = (CGFloat)item.currentTime.value/(item.currentTime.timescale * 1.0);
        if (ws.playerCurrentTimeBlock) {
            ws.playerCurrentTimeBlock(currentPlayTime);
        }
    }];
}

- (void)update{
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
    //开启锁屏
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self removePlayerObserver];
    [self.player pause];
    [self.player setRate:0];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
    if (self.playerToStop) {
        self.playerToStop();
    }
}

- (CGFloat)currentTime {
    return CMTimeGetSeconds([self.player currentTime]);
}


- (CGFloat)totalTime {
    return CMTimeGetSeconds(self.player.currentItem.duration);
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
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        _playerItem = nil;
    }
    if (_playTimeObserver) {
        [_player removeTimeObserver:_playTimeObserver];
        _playTimeObserver = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)dealloc{
    TTLog(@"%s", __func__);
    [self removePlayerObserver];
    [self removeNotifications];
}

- (void)removeNotifications{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
