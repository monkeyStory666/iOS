#import "MEGAAVViewController.h"

#import "LTHPasscodeViewController.h"

#import "Helper.h"
#import "MEGANode+MNZCategory.h"
#import "NSString+MNZCategory.h"
#import "NSURL+MNZCategory.h"
#import "UIApplication+MNZCategory.h"
#import "MEGAStore.h"
#import "MEGA-Swift.h"

@import MEGAL10nObjc;

static const NSUInteger MIN_SECOND = 10; // Save only where the users were playing the file, if the streaming second is greater than this value.
static const NSTimeInterval SEEK_TIMEOUT = 10.0; // 10 seconds timeout for seek operations

@interface MEGAAVViewController () <AVPlayerViewControllerDelegate>

@property (nonatomic, assign, getter=isViewDidAppearFirstTime) BOOL viewDidAppearFirstTime;
@property (nonatomic, strong) NSMutableSet *subscriptions;
@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) BOOL isPlayerPreparing;
@property (nonatomic, strong) dispatch_queue_t playerQueue;
@property (nonatomic, strong) NSTimer *seekTimeoutTimer;

@end

@implementation MEGAAVViewController

- (instancetype)initWithURL:(NSURL *)fileUrl {
    self = [super init];
    
    if (self) {
        self.viewModel = [self makeViewModel];
        MEGALogInfo(@"[MEGAAVViewController] init with url: %@", fileUrl);
        self.fileUrl    = fileUrl;
        self.node       = nil;
        _isFolderLink   = NO;
        _subscriptions = [[NSMutableSet alloc] init];
        _hasPlayedOnceBefore = NO;
        _isSeeking = NO;
        _isPlayerPreparing = NO;
        _playerQueue = dispatch_queue_create("com.mega.avplayer.queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (instancetype)initWithNode:(MEGANode *)node folderLink:(BOOL)folderLink apiForStreaming:(MEGASdk *)apiForStreaming {
    self = [super init];
    
    if (self) {
        self.viewModel = [self makeViewModel];
        _apiForStreaming = apiForStreaming;
        self.node            = folderLink ? [MEGASdk.sharedFolderLink authorizeNode:node] : node;
        _isFolderLink        = folderLink;
        self.fileUrl         = [self streamingPathWithNode:node];
        MEGALogInfo(@"[MEGAAVViewController] init with node %@, is folderLink: %d, fileUrl: %@, apiForStreaming: %@", self.node, folderLink, self.fileUrl, apiForStreaming);
        _hasPlayedOnceBefore = NO;
        _isSeeking = NO;
        _isPlayerPreparing = NO;
        _playerQueue = dispatch_queue_create("com.mega.avplayer.queue", DISPATCH_QUEUE_SERIAL);
    }
        
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewModel onViewDidLoad];
    [self checkIsFileViolatesTermsOfService];
    [AudioSessionUseCaseOCWrapper.alloc.init configureVideoAudioSession];
    
    if ([AudioPlayerManager.shared isPlayerAlive]) {
        [AudioPlayerManager.shared audioInterruptionDidStart];
    }

    self.viewDidAppearFirstTime = YES;
    
    self.subscriptions = [self bindToSubscriptionsWithMovieStalled:^{
        [self movieStalledCallback];
    }];
    
    [self configureActivityIndicator];
    
    [self configureViewColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 检查视图控制器状态，避免在转换期间执行seek操作
    if (![self isViewVisible]) {
        MEGALogWarning(@"[MEGAAVViewController] View not visible, deferring seek operation");
        return;
    }
    
    NSString *fingerprint = [self fileFingerprint];

    if (self.isViewDidAppearFirstTime) {
        if (fingerprint && ![fingerprint isEqualToString:@""]) {
            MOMediaDestination *mediaDestination;
            if (self.node) {
                mediaDestination = [[MEGAStore shareInstance] fetchRecentlyOpenedNodeWithFingerprint:fingerprint].mediaDestination;
            } else {
                mediaDestination = [[MEGAStore shareInstance] fetchMediaDestinationWithFingerprint:fingerprint];
            }
            if (mediaDestination.destination.longLongValue > 0 && mediaDestination.timescale.intValue > 0) {
                if ([FileExtensionGroupOCWrapper verifyIsVideo:[self fileName]]) {
                    NSString *infoVideoDestination = LocalizedString(@"video.alert.resumeVideo.message", @"Message to show the user info (video name and time) about the resume of the video");
                    infoVideoDestination = [infoVideoDestination stringByReplacingOccurrencesOfString:@"%1$s" withString:[self fileName]];
                    infoVideoDestination = [infoVideoDestination stringByReplacingOccurrencesOfString:@"%2$s" withString:[self timeForMediaDestination:mediaDestination]];
                    UIAlertController *resumeOrRestartAlert = [UIAlertController alertControllerWithTitle:LocalizedString(@"video.alert.resumeVideo.title", @"Alert title shown for video with options to resume playing the video or start from the beginning") message:infoVideoDestination preferredStyle:UIAlertControllerStyleAlert];
                    [resumeOrRestartAlert addAction:[UIAlertAction actionWithTitle:LocalizedString(@"video.alert.resumeVideo.button.restart", @"Alert button title that will start playing the video from the beginning") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self seekToDestination:nil play:YES];
                    }]];
                    [resumeOrRestartAlert addAction:[UIAlertAction actionWithTitle:LocalizedString(@"video.alert.resumeVideo.button.resume", @"Alert button title that will resume playing the video") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self seekToDestination:mediaDestination play:YES];
                    }]];
                    [self presentViewController:resumeOrRestartAlert animated:YES completion:nil];
                } else {
                    [self seekToDestination:mediaDestination play:NO];
                }
            } else {
                [self seekToDestination:nil play:YES];
            }
        } else {
            [self seekToDestination:nil play:YES];
        }
    }
    
    [[AVPlayerManager shared] assignDelegateTo:self];
    
    self.viewDidAppearFirstTime = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([[AVPlayerManager shared] isPIPModeActiveFor:self]) {
        return;
    }
    
    // 取消正在进行的seek操作
    [self cancelSeekOperation];
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        [self stopStreaming];

        if (![AudioPlayerManager.shared isPlayerAlive]) {
            [AudioSessionUseCaseOCWrapper.alloc.init configureDefaultAudioSession];
        }

        if ([AudioPlayerManager.shared isPlayerAlive]) {
            [AudioPlayerManager.shared audioInterruptionDidEndNeedToResume:YES];
        }
    });
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"presentPasscodeLater"] && [LTHPasscodeViewController doesPasscodeExist]) {
        [[LTHPasscodeViewController sharedUser] showLockScreenOver:UIApplication.mnz_presentingViewController.view
                                                     withAnimation:YES
                                                        withLogout:YES
                                                    andLogoutTitle:LocalizedString(@"logoutLabel", @"")];
    }
    
    [self deallocPlayer];
    [self cancelPlayerProcess];
    self.player = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([[AVPlayerManager shared] isPIPModeActiveFor:self]) {
        return;
    }

    CMTime mediaTime = CMTimeMake(self.player.currentTime.value, self.player.currentTime.timescale);
    Float64 second = CMTimeGetSeconds(mediaTime);
    
    NSString *fingerprint = [self fileFingerprint];
    
    if (fingerprint && ![fingerprint isEqualToString:@""]) {
        if (self.isEndPlaying || second <= MIN_SECOND) {
            [[MEGAStore shareInstance] deleteMediaDestinationWithFingerprint:fingerprint];
            [self saveRecentlyWatchedVideoWithDestination:[NSNumber numberWithInt:0]
                                                timescale:nil];
        } else {
            if (self.node) {
                [self saveRecentlyWatchedVideoWithDestination:[NSNumber numberWithLongLong:self.player.currentTime.value]
                                                    timescale:[NSNumber numberWithInt:self.player.currentTime.timescale]];
            } else {
                [[MEGAStore shareInstance] insertOrUpdateMediaDestinationWithFingerprint:fingerprint destination:[NSNumber numberWithLongLong:self.player.currentTime.value] timescale:[NSNumber numberWithInt:self.player.currentTime.timescale]];
            }
        }
    }
}

#pragma mark - Private

- (void)seekToDestination:(MOMediaDestination *)mediaDestination play:(BOOL)play {
    if (!self.fileUrl) {
        MEGALogWarning(@"[MEGAAVViewController] seekToDestination called with nil fileUrl");
        return;
    }
    
    // 防止重复调用
    if (self.isSeeking || self.isPlayerPreparing) {
        MEGALogWarning(@"[MEGAAVViewController] seekToDestination called while operation in progress");
        return;
    }
    
    // 检查视图控制器状态
    if (![self isViewVisible]) {
        MEGALogWarning(@"[MEGAAVViewController] seekToDestination called when view not visible");
        return;
    }
    
    self.isPlayerPreparing = YES;
    [self willStartPlayer];
    
    // 异步创建AVAsset和AVPlayerItem，避免阻塞主线程
    dispatch_async(self.playerQueue, ^{
        MEGALogInfo(@"[MEGAAVViewController] Creating AVAsset on background queue");
        
        AVAsset *asset = [AVAsset assetWithURL:self.fileUrl];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        // 回到主线程设置播放器和元数据
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupPlayerWithItem:playerItem mediaDestination:mediaDestination play:play];
        });
    });
}

- (void)setupPlayerWithItem:(AVPlayerItem *)playerItem mediaDestination:(MOMediaDestination *)mediaDestination play:(BOOL)play {
    // 再次检查视图状态
    if (![self isViewVisible]) {
        MEGALogWarning(@"[MEGAAVViewController] setupPlayerWithItem called when view not visible");
        self.isPlayerPreparing = NO;
        return;
    }
    
    [self setPlayerItemMetadataWithPlayerItem:playerItem node:self.node];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    [self.subscriptions addObject:[self bindPlayerItemStatusWithPlayerItem:playerItem]];
    
    // 使用已存在的seekTo方法，而不是未实现的seekToMediaDestination
    [self seekTo:mediaDestination];
    
    if (play) {
        // 检查播放器状态后再播放
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        } else {
            MEGALogWarning(@"[MEGAAVViewController] Player not ready to play, status: %ld", (long)self.player.currentItem.status);
        }
    }
    
    [self.subscriptions addObject:[self bindPlayerTimeControlStatus]];
    
    self.isPlayerPreparing = NO;
    MEGALogInfo(@"[MEGAAVViewController] Player setup completed");
}

- (void)cancelSeekOperation {
    if (self.isSeeking) {
        MEGALogInfo(@"[MEGAAVViewController] Cancelling seek operation");
        [self.player.currentItem cancelPendingSeeks];
        self.isSeeking = NO;
    }
    
    if (self.isPlayerPreparing) {
        MEGALogInfo(@"[MEGAAVViewController] Cancelling player preparation");
        self.isPlayerPreparing = NO;
    }
    
    [self cancelSeekTimeoutTimer];
}

- (void)startSeekTimeoutTimer {
    [self cancelSeekTimeoutTimer];
    self.seekTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:SEEK_TIMEOUT
                                                             target:self
                                                           selector:@selector(seekTimeoutHandler)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (void)cancelSeekTimeoutTimer {
    if (self.seekTimeoutTimer) {
        [self.seekTimeoutTimer invalidate];
        self.seekTimeoutTimer = nil;
    }
}

- (void)seekTimeoutHandler {
    MEGALogError(@"[MEGAAVViewController] Seek operation timed out");
    [self cancelSeekOperation];
    
    // 显示错误提示
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizedString(@"error", @"")
                                                                       message:LocalizedString(@"video.seek.timeout", @"Seek operation timed out")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:LocalizedString(@"ok", @"")
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (BOOL)isViewVisible {
    return self.view.window != nil && !self.isBeingDismissed && !self.isMovingFromParentViewController;
}

- (void)replayVideo {
    if (self.player) {
        [self cancelSeekOperation];
        [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.player play];
                    self.isEndPlaying = NO;
                });
            }
        }];
    }
}

- (void)stopStreaming {
    if (self.node) {
        [self.apiForStreaming httpServerStop];
    }
}

- (NSString *)timeForMediaDestination:(MOMediaDestination *)mediaDestination {
    CMTime mediaTime = CMTimeMake(mediaDestination.destination.longLongValue, mediaDestination.timescale.intValue);
    NSTimeInterval durationSeconds = (NSTimeInterval)CMTimeGetSeconds(mediaTime);
    return [NSString mnz_stringFromTimeInterval:durationSeconds];
}

- (NSString *)fileName {
    if (self.node) {
        return self.node.name;
    } else {
        return self.fileUrl.lastPathComponent;
    }
}

- (NSString *)fileFingerprint {
    NSString *fingerprint;

    if (self.node) {
        MEGALogInfo(@"[MEGAAVViewController] Getting fileFingerprint from node %@", self.node);
        fingerprint = self.node.fingerprint;
    } else {
        fingerprint = [MEGASdk.shared fingerprintForFilePath:self.fileUrl.path];
        MEGALogInfo(@"[MEGAAVViewController] Getting fileFingerprint from sdk with result %@", fingerprint);
    }
    
    return fingerprint;
}

- (void)dealloc {
    [self cancelSeekOperation];
    [self cancelSeekTimeoutTimer];
    MEGALogInfo(@"[MEGAAVViewController] dealloc");
}

@end
