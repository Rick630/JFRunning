//
//  JFHistoryViewController.m
//  JFRunning
//
//  Created by huangzh on 17/1/20.
//  Copyright © 2017年 RIck. All rights reserved.
//

#import "JFHistoryViewController.h"
#import "JFRecordDetailViewController.h"
#import "JFRecordCell.h"
#import "CFJourneyDao.h"
#import "JFRecordShowModel.h"
#import "JFPublic.h"
@interface JFHistoryViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) CFJourneyDao *dao;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) JFRecordShowModel *showModel;
@end

@implementation JFHistoryViewController

#pragma mark - lazy loading

- (CFJourneyDao *)dao
{
    if(_dao == nil)
    {
        _dao = [CFJourneyDao new];
    }
    
    return _dao;
}

- (JFRecordShowModel *)showModel
{
    if(_showModel) return _showModel;
    
    _showModel = [JFRecordShowModel new];
    
    return _showModel;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.01)];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - data loading
- (void)reloadData
{
    [self loadHistoryWithPage:0];
}
- (void)loadHistoryWithPage:(NSInteger)page
{
    if(page == 0)
    {
        [self.showModel clear];
    }
    NSArray *r = [self.dao queryWithPage:0];
    if(r.count == 0) return;
    
    
    [self.showModel appendData:r];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    UIVisualEffectView *header = [[UIVisualEffectView alloc] initWithEffect:blur];
        
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 40)];
    title.textColor = [UIColor whiteColor];
    title.text = [self.showModel titleOfSection:section];
    
    [header.contentView addSubview:title];
    
    return header;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.showModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.showModel numberOfRowsForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JFRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.journey = [self.showModel journeyOfIndexPath:indexPath];;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JFRecordDetailViewController *destinationVC = [[JFRecordDetailViewController alloc] init];
    destinationVC.journey = [self.showModel journeyOfIndexPath:indexPath];
    destinationVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:destinationVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(NSArray<UITableViewRowAction*>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                            title:@"删除"    handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                                [weakSelf tableView:weakSelf.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
                                                                            }];
    delAction.backgroundColor = HexRGBAlpha(0x262626, 0.3);
    
    return @[delAction];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dao deleteJourney:[self.showModel journeyOfIndexPath:indexPath]];
    
    // 从数据源中删除
    NSInteger rows = [self.showModel numberOfRowsForSection:indexPath.section];
    [self.showModel removeJourneyAtIndexPath:indexPath];

    if(rows == 1)
    {
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // 从列表中删除
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
