//
//  EKChartViewController.m
//  TrackMyTime
//
//  Created by Evgeny Karkan on 14.12.13.
//  Copyright (c) 2013 EvgenyKarkan. All rights reserved.
//

#import "EKChartViewController.h"
#import "EKAppDelegate.h"
#import "EKRecordModel.h"
#import "EKDateModel.h"
#import "EKChartView.h"
#import "NSString+TimeFormate.h"
#import "EKActivityProvider.h"

@interface EKChartViewController ()<XYPieChartDelegate, XYPieChartDataSource>

@property (nonatomic, strong) EKAppDelegate *appDelegate;
@property (nonatomic, strong) EKChartView *chartView;

@end

@implementation EKChartViewController;

#pragma mark - Life cycle

- (void)loadView
{
	EKChartView *view = [[EKChartView alloc] init];
	self.view = view;
	self.chartView = view;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	self.appDelegate = (EKAppDelegate *)[[UIApplication sharedApplication] delegate];
	[self.appDelegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    
	[self.chartView.chart setDelegate:self];
	[self.chartView.chart setDataSource:self];
    
	[self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:YES];
	[self.appDelegate.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar];
    
	[self endDataReadyForChart];
	[self.chartView.chart reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - UI

- (void)setUpUI
{
	self.view.backgroundColor = [UIColor colorWithRed:0.898039f green:0.898039f blue:0.898039f alpha:1.0f];
    
	UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:nil];
	[[self navigationItem] setRightBarButtonItem:newBackButton];
}

#pragma mark - Prepare data for chart

- (NSMutableSet *)activitiesNoDuplicates
{
	NSMutableSet *noDuplicates = [[NSMutableSet alloc] init];
    
	for (EKDateModel *date in self.dateModels) {
		for (EKRecordModel *record in [date.toRecord allObjects]) {
            if (record.activity != nil) {
                [noDuplicates addObject:record.activity];
            }
		}
	}
	return noDuplicates;
}

- (NSArray *)recordsFromGivenDates
{
	NSMutableArray *records = [@[] mutableCopy];
    
	for (EKDateModel *date in self.dateModels) {
		for (EKRecordModel *record in [date.toRecord allObjects]) {
			[records addObject:record];
		}
	}
	return [records copy];
}

- (NSArray *)filteredRecordsGroupedByName
{
	NSMutableArray *result = [@[] mutableCopy];
    
	for (NSInteger i = 0; i < [[[self activitiesNoDuplicates] allObjects] count]; i++) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"activity == %@", [[self activitiesNoDuplicates] allObjects][i]];
		NSArray *mock = [[self recordsFromGivenDates] filteredArrayUsingPredicate:predicate];
		[result addObject:mock];
	}
        //    NSLog(@"Resulted array aft pred %@", [result description]);
	return [result copy];
}

- (NSArray *)endDataReadyForChart
{
	unsigned long long sum = 0;
	EKRecordModel *mock = nil;
	NSMutableArray *endData = [@[] mutableCopy];
    
	for (NSArray *arrayObject in [self filteredRecordsGroupedByName]) {
		for (EKRecordModel *record in arrayObject) {
			mock = record;
			sum = sum + [record.duration unsignedLongLongValue];
		}
		[endData addObject:@{ mock.activity : @(sum) }];
            //        NSLog(@"SUM for %@ is %@",mock.activity, @(sum));
		sum = 0;
	}
        //    NSLog(@"END DATA %@", [endData description]);
	return [endData copy];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
	return [[self endDataReadyForChart] count];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
	return [[[self endDataReadyForChart][index] allValues][0] unsignedLongLongValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
	return [EKActivityProvider colorForActivity:[[self endDataReadyForChart][index] allKeys][0]];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
	return [NSString timeFormattedStringForValue:[[[self endDataReadyForChart][index] allValues][0] unsignedLongLongValue]];
}

#pragma mark - XYPieChart Delegate

- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
	NSLog(@"did deselect slice at index %d", index);
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
	NSLog(@"did select slice at index %d", index);
}

@end