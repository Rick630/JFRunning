//
//  JFRecordDetailViewController.m
//  JFRunning
//
//  Created by huangzh on 17/1/20.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import "JFRecordDetailViewController.h"
#import <MapKit/MapKit.h>
#import "WGS84TOGCJ02.h"
#import "JFPublic.h"
#import "JFColorPolyline.h"
@interface JFRecordDetailViewController ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation JFRecordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performInit];
    [self setRegion];
    [self drawRecord];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performInit
{
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    [self.view addSubview:mapView];
    self.mapView = mapView;
    self.navigationItem.title = @"运动记录";
    
    self.mapView.delegate = self;
}

#pragma mark - drawing

- (void)setRegion
{
    CLLocationDegrees maxLat = 0.0, minLat = 9999.0, maxLont = 0, minLont = 9999.0;
    
    for(CFLocation *location in self.journey.locations)
    {
        CLLocationCoordinate2D formattedCoord = [WGS84TOGCJ02 transformToMars:CLLocationCoordinate2DMake(location.latitude, location.longitude)];

        maxLat = MAX(maxLat, formattedCoord.latitude);
        minLat = MIN(minLat, formattedCoord.latitude);
        maxLont = MAX(maxLont, formattedCoord.longitude);
        minLont = MIN(minLont, formattedCoord.longitude);
    }
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(minLat + (maxLat-minLat)*0.5, minLont + (maxLont-minLont)*0.5);
    
    CLLocationDegrees deltaLa = maxLat - minLat;
    CLLocationDegrees deltaLon = maxLont - minLont;
    
    MKCoordinateRegion region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(deltaLa*1.3, deltaLon*1.3));
    [self.mapView setRegion:region animated:NO];
    
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:center radius:100000000] level:1];
}

- (void)drawRecord
{
    double maxV = self.journey.maxV;
    double minV = self.journey.minV;
    
    NSMutableArray *lines = [NSMutableArray new];
    for(int i=0; i < self.journey.locations.count - 1; i++)
    {
        CFLocation *firstPoint = self.journey.locations[i];
        CFLocation *secondPoint = self.journey.locations[i+1];
        
        UIColor *lineColor = [self colorWithVelocity:secondPoint.velocity maxVelocity:maxV minVelocity:minV];
        JFColorPolyline *line = [self polyLineWithLocations:@[firstPoint, secondPoint] color:lineColor];
        
        [lines addObject:line];
    }
    
    [self.mapView addOverlays:lines];
}

- (UIColor *)colorWithVelocity:(double)velocity maxVelocity:(double)maxV minVelocity:(double)minV
{
    CGFloat max_H = 0;
    CGFloat min_H = 100;
    
    double percent = (velocity - minV)/(maxV - minV);
    
    CGFloat hue = min_H+(max_H-min_H)*percent;
    
    return [UIColor colorWithHue:hue/360.0 saturation:1 brightness:1 alpha:1.0];
}

- (JFColorPolyline *)polyLineWithLocations:(NSArray<CFLocation *> *)locations color:(UIColor *)color
{
    
    CLLocationCoordinate2D coords[locations.count];

    
    for(int i=0; i < locations.count; i++)
    {
        CFLocation *location = locations[i];
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        
        //转换后的coord
        CLLocationCoordinate2D formattedCoord = [WGS84TOGCJ02 transformToMars:coord];

        coords[i] = formattedCoord;
    }
    
    JFColorPolyline *line = [JFColorPolyline polylineWithCoordinates:coords count:locations.count];
    line.color = color;
        
    return line;
}

#pragma mark - mapView delegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if([overlay isKindOfClass:[JFColorPolyline class]])
    {
        MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        render.lineCap = kCGLineCapRound;
        render.lineJoin = kCGLineJoinBevel;
        render.lineWidth = 5;
        render.strokeColor = ((JFColorPolyline *)overlay).color;
        return render;
    }
    else if ([overlay isKindOfClass:[MKCircle class]]){
        //半透明蒙层
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.2];
        return circleRenderer;
    }
    
    return nil;
}


@end
