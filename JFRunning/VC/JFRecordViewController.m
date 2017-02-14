//
//  JFRecordViewController.m
//  JFRunning
//
//  Created by huangzh on 17/1/19.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import "JFRecordViewController.h"
#import "CFJourney.h"
#import <CoreLocation/CoreLocation.h>
#import "CFJourneyDao.h"
#import <AVFoundation/AVFoundation.h>
#import "JFPublic.h"

@interface JFRecordViewController ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) CFJourney *currentJourney;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, strong) CFJourneyDao *dao;
@property (nonatomic, strong) NSTimer *counter;
@property (nonatomic, strong) NSMutableArray *velocities;

@property (weak, nonatomic) IBOutlet UILabel *labDistance;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labSpeed;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@end


@implementation JFRecordViewController
{
    NSInteger checkPoint;
}
#pragma mark - lazy loading

- (NSMutableArray *)velocities
{
    if(_velocities) return _velocities;
    
    _velocities = [NSMutableArray new];
    
    return _velocities;
}

- (CFJourneyDao *)dao
{
    if(_dao == nil)
    {
        _dao = [CFJourneyDao new];
    }
    
    return _dao;
}

- (CLLocationManager *)locationManager
{
    if(_locationManager == nil)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        //后台更新
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        if([_locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
        {
            [_locationManager setAllowsBackgroundLocationUpdates:YES];
        }
    }
    
    return _locationManager;
}

- (NSMutableArray *)locations
{
    if(_locations == nil)
    {
        _locations = [NSMutableArray new];
    }
    
    return _locations;
}

- (NSTimer *)counter
{
    if(_counter)
    {
        return _counter;
    }
    
    _counter = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    return _counter;
}
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnRecord.layer.cornerRadius = 50;
    self.btnRecord.layer.masksToBounds = YES;
    
    self.labDistance.font = [UIFont fontWithName:@"DINOT-Bold" size:80];
    self.labTime.font = [UIFont fontWithName:@"DINOT-Bold" size:20];
    self.labSpeed.font = [UIFont fontWithName:@"DINOT-Bold" size:20];

    NSError *error = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error) {
        // Do some error handling
    }
    [session setActive:YES error:&error];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNoti:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNoti:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.locationManager requestAlwaysAuthorization];
    }
}

#pragma mark - notification
- (void)handleNoti:(NSNotification *)noti
{
    if(self.recording == NO) return;
//    if(noti.name == UIApplicationDidEnterBackgroundNotification)
//    {
//        if([CLLocationManager significantLocationChangeMonitoringAvailable])
//        {
//            [self.locationManager stopUpdatingLocation];
//            [self.locationManager startMonitoringSignificantLocationChanges];
//        }
//    }
//    else if(noti.name == UIApplicationDidBecomeActiveNotification)
//    {
//        if([CLLocationManager significantLocationChangeMonitoringAvailable])
//        {
//            [self.locationManager stopMonitoringSignificantLocationChanges];
//            [self.locationManager startUpdatingLocation];
//        }
//    }
}

#pragma mark - action
- (IBAction)recordAction:(UIButton *)sender {
    
    if(self.recording == NO)
    {
        [self playStartAnimation:^{
            [self startRecord];
        }];
    }
    else
    {
        [self stopRecord];
    }
    
}

- (void)playStartAnimation:(void(^)())complete
{
    UIView *animatedView = [UIView new];
    animatedView.frame = self.btnRecord.frame;
    animatedView.backgroundColor = self.btnRecord.backgroundColor;
    animatedView.layer.cornerRadius = self.btnRecord.layer.cornerRadius;
    animatedView.layer.masksToBounds = YES;
    
    [self.view insertSubview:animatedView belowSubview:self.btnRecord];
    
    CGRect frameInWindow = [animatedView convertRect:animatedView.frame toView:APP_DELEGATE.window];
    CGFloat offset = fabs(CGRectGetMidY(frameInWindow) - 0.5*CGRectGetHeight([UIScreen mainScreen].bounds));
    CGFloat scale = (CGRectGetHeight([UIScreen mainScreen].bounds)+offset)/CGRectGetHeight(animatedView.frame);
    
    
    [UIView animateWithDuration:1.0 animations:^{
        self.tabBarController.tabBar.alpha = 0.0;
        self.btnRecord.alpha = 0.0;
        
        animatedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    } completion:^(BOOL finished) {
        [self countDown:3 complete:^{
            [UIView animateWithDuration:1.0 animations:^{
                animatedView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);

            } completion:^(BOOL finished) {
                self.tabBarController.tabBar.alpha = 1.0;
                self.btnRecord.alpha = 1.0;

                if(complete)
                {
                    complete();
                }
            }];
        }];
    }];
}

- (void)refresh:(NSTimer *)timer
{
    NSDate *now = [NSDate new];
    NSDateComponents *component = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.currentJourney.startTime toDate:now options:0];
    
    NSString *timeText = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)component.hour, (int)component.minute, (int)component.second];
    self.labTime.text = timeText;
}
- (void)reset
{
    self.labDistance.text = @"0.00";
    self.labTime.text = @"00:00:00";
    
    [self.locations removeAllObjects];
    [self.velocities removeAllObjects];

    checkPoint = 1;
}
#pragma mark - recording
- (void)startRecord
{
    [self.btnRecord setTitle:@"Stop" forState:UIControlStateNormal];
    
    self.recording = YES;
    
    CFJourney *journey = [CFJourney new];
    journey.maxV = 0.0;
    journey.minV = 999999.99;
    journey.startTime = [NSDate date];
    self.currentJourney = journey;
    
    [self.locationManager startUpdatingLocation];
    
    [self reset];
    //timer
    [[NSRunLoop mainRunLoop] addTimer:self.counter forMode:NSRunLoopCommonModes];
}

- (void)stopRecord
{
    [self.btnRecord setTitle:@"Start" forState:UIControlStateNormal];

    self.recording = NO;
    
    self.currentJourney.finishTime = [NSDate date];
    self.currentJourney.locations = self.locations;
    
    [self.locationManager stopUpdatingLocation];
    
    [self saveJourney:self.currentJourney];
    
    //timer
    [_counter invalidate];
    _counter = nil;
    
    [self reset];
}

- (void)appendLocation:(CLLocation *)location
{
    NSLog(@"%f", location.horizontalAccuracy);

    if(location.horizontalAccuracy > 50) return;    //GPS精准度不达标
    
    NSDate *eventDate = location.timestamp;
    NSTimeInterval timeOffset = [eventDate timeIntervalSinceNow];
    
    if(fabs(timeOffset) > 2.0) return;  //定位时间偏差太大的过滤
    
    CFLocation *savedLocation = [CFLocation location:location];
    
    if(self.locations.count > 0)
    {
        CFLocation *lastCFLation = self.locations.lastObject;
        CLLocation *lastCLLocation = [[CLLocation alloc] initWithLatitude:lastCFLation.latitude longitude:lastCFLation.longitude];
        
        //与上一个点距离
        CLLocationDistance distance = [location distanceFromLocation:lastCLLocation];
        
        //总距离
        self.currentJourney.distance += distance;
        
        if(self.currentJourney.distance >= (checkPoint*1000.0))
        {
            [self speakMsgInChinese:[NSString stringWithFormat:@"你已经跑步%d公里", (int)checkPoint]];
            checkPoint ++;
        }
        //速度
        double velocity = fabs(distance/(location.timestamp.timeIntervalSince1970-lastCLLocation.timestamp.timeIntervalSince1970));   // 单位： 米/秒
        
        //缓和速度曲线，取近10个速度的平均速度为当前速度
        double parsedVelocity = [self parseVelocity:velocity];
        
        self.currentJourney.maxV = MAX(self.currentJourney.maxV, parsedVelocity);
        self.currentJourney.minV = MIN(self.currentJourney.minV, parsedVelocity);
        savedLocation.velocity = parsedVelocity;
        self.labSpeed.text = [self speedStrWithTimeOffset:(long)(velocity/1000.0)];   //单位转成 公里/秒
        
        self.labDistance.text = [NSString stringWithFormat:@"%.2f", self.currentJourney.distance/1000];
    }
    [self.locations addObject:savedLocation];
}

- (double)parseVelocity:(double)velocity
{
    NSInteger velocityCount = self.velocities.count;
    if(velocityCount >= 10)
    {
        [self.velocities removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, velocityCount-9)]];
    }
    
    [self.velocities addObject:@(velocity)];
    
    double averVelocity = [[self.velocities valueForKeyPath:@"@avg.doubleValue"] doubleValue];
    
    return averVelocity;
}
- (NSString *)speedStrWithTimeOffset:(long)offset
{
    long minute, second;
    minute = 0; second = 0;
    
    NSInteger minuteUnit = 60;
    minute = offset/minuteUnit;
    NSInteger minuteLeft = offset%minuteUnit;
    
    if(minuteLeft)
    {
        second = minuteLeft;
    }
    
    return [NSString stringWithFormat:@"%02ld'%02ld''", minute, second];
}

#pragma mark - save
- (void)saveJourney:(CFJourney *)journey
{
    if(journey.distance == 0)
    {
        NSLog(@"距离太短，无法保存");
        return;
    }
    
    [self.dao insertJourney:journey];
    
}

#pragma mark - delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if(locations.count == 0) return;

    for(CLLocation *location in locations)
    {
        [self appendLocation:location];
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}
#pragma mark - Voice
- (void)speakMsgInChinese:(NSString *)msg
{
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:msg];
    
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    //获取当前系统语音
    NSString *preferredLang = @"zh-CN";
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:[NSString stringWithFormat:@"%@",preferredLang]];
    utterance.voice = voice;
    [synth speakUtterance:utterance];
}

-(void)countDown:(int)count complete:(void(^)())complete
{
    
    if(count <=0){
        
        if(complete)
        {
            complete();
        }
        
        return;
    }
    
    
    UILabel* lblCountDown = [[UILabel alloc] initWithFrame:CGRectMake(260, 120, 50, 50)];
    lblCountDown.textColor = [UIColor whiteColor];
    lblCountDown.font = [UIFont fontWithName:@"DINOT-Bold" size:400];
    lblCountDown.backgroundColor = [UIColor clearColor];
    lblCountDown.text = [NSString stringWithFormat:@"%d", count];
    lblCountDown.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:lblCountDown attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:lblCountDown attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

    [self.view addSubview:lblCountDown];
    [self.view addConstraints:@[centerX, centerY]];
    
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         lblCountDown.alpha = 0;
                         lblCountDown.transform =CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
                     }
                     completion:^(BOOL finished) {
                         [lblCountDown removeFromSuperview];
                         //递归调用，直到计时为零
                         [self countDown:count -1 complete:complete];
                     }
     ];
}

@end
