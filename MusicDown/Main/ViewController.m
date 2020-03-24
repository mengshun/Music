//
//  ViewController.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/11.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "ViewController.h"
#import "ViewModel/MusicViewModel.h"
#import "DowningView.h"
#import "DownCompleteView.h"
#import "DownLoadMgr.h"
#import <AVFoundation/AVFoundation.h>
#import "MusicPlayView.h"

@interface ViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *searchTextField;
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) MusicViewModel *viewModel;
@property (weak) IBOutlet BaseNSView *contentView;
@property (nonatomic, strong) DowningView *downingView;
@property (nonatomic, strong) DownCompleteView *downCompleteView;
@property (weak) IBOutlet NSTextField *lujingLabel;

@property (weak) IBOutlet MusicPlayView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewModel];
    [self initMusicDirectory];
}

- (void)initViewModel
{
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(doubleClick:)];
    self.viewModel = [[MusicViewModel alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.viewModel setSearchKeyWordBlock:^NSString *{
        return weakSelf.searchTextField.stringValue;
    }];
    
    [self.viewModel setRefreshBlock:^{
        [weakSelf.tableView reloadData];
    }];
    [self.searchTextField setTarget:self];
    [self.searchTextField setAction:@selector(searchEnterAction)];
}

- (void)initMusicDirectory
{
    self.lujingLabel.stringValue = [[DownLoadMgr shareInstance] downLoadPath];
}

- (IBAction)clickSearchAction:(id)sender {
    if (self.searchTextField.stringValue.length == 0) {
        NSLog(@"请输入相关信息");
    } else {
        [self.viewModel fetchLatest];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)searchEnterAction
{
    [self clickSearchAction:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.viewModel contentCount];
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 30;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (!cellView) {
        cellView = [[NSTableCellView alloc] init];
        cellView.identifier = tableView.identifier;
        NSTextField *text = [[NSTextField alloc] init];
        text.frame = CGRectMake(0, 0, 100, 20);
        [cellView addSubview:text];
        text.stringValue = [NSString stringWithFormat:@"cell %ld",(long)row+1];;
    }
    NSString *tableColumnID = tableColumn.identifier;
    NSInteger identifierIdx = [tableColumnID componentsSeparatedByString:@"."].lastObject.integerValue;
    WangyiYinYueModel *model = [self.viewModel modelAtIndex:row];
    switch (identifierIdx) {
            case 0:
            {
                cellView.textField.stringValue = [NSString stringWithFormat:@"%ld",(long)row+1];
            }
            break;
            case 1:
            {
                cellView.textField.stringValue = model.title;
            }
                break;
            case 2:
            {
                cellView.textField.stringValue = model.author;
            }
                break;
            case 3:
            {
                cellView.textField.stringValue = model.type;
            }
            break;
            case 4:
            {
                cellView.textField.stringValue = model.songid;
            }
                break;
            case 5:
            {
                switch (model.downType) {
                        case MusicDownLoadTypeURLError:
                        {
                            cellView.textField.stringValue = @"无法下载";
                            cellView.textField.textColor = NSColor.lightGrayColor;
                        }
                        break;
                        case MusicDownLoadTypeURLCanDownLoad:
                        {
                            cellView.textField.stringValue = @"可以下载";
                            cellView.textField.textColor = NSColor.greenColor;
                        }
                            break;
                        case MusicDownLoadTypeURLDowning:
                        {
                            cellView.textField.stringValue = @"正在下载";
                            cellView.textField.textColor = NSColor.orangeColor;
                        }
                            break;
                        case MusicDownLoadTypeURLHasDownComplete:
                        {
                            cellView.textField.stringValue = @"下载完成";
                            cellView.textField.textColor = NSColor.purpleColor;
                        }
                            break;
                    default:
                        break;
                }
            }
                    break;
        default:
            break;
    }
//    cellView.wantsLayer = YES;
//    cellView.layer.backgroundColor = [NSColor greenColor].CGColor;
    return cellView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableView *tableView = notification.object;
    WangyiYinYueModel *model = [self.viewModel modelAtIndex:tableView.selectedRow];
    NSLog(@"didSelect：%@",model.title);
    if (model.downType != MusicDownLoadTypeURLError) {
        [self.playerView playMusicWithUrl:model.url title:[NSString stringWithFormat:@"%@-%@", model.title, model.author]];
        
    }
}

- (void)doubleClick:(id)sender
{
    NSInteger rowNumber = [self.tableView clickedRow];
    WangyiYinYueModel *model = [self.viewModel modelAtIndex:rowNumber];
    if (model.downType == MusicDownLoadTypeURLCanDownLoad) {
        NSLog(@"开始下载: %@", model.title);
        __weak typeof(self) weakSelf = self;
        [[DownLoadMgr shareInstance] downLoadUrl:model.url title:[NSString stringWithFormat:@"%@-%@", model.title, model.author] complete:^{
            [model reloadDownState];
            [weakSelf.tableView reloadData];
        }];
    } else if (model.downType == MusicDownLoadTypeURLDowning) {
        NSLog(@"正在下载: %@", model.title);
    } else if (model.downType == MusicDownLoadTypeURLHasDownComplete) {
        NSLog(@"下载已经完成: %@", model.title);
    }  else if (model.downType == MusicDownLoadTypeURLError) {
        NSLog(@"无法下载: %@", model.title);
    }
}

- (IBAction)downingAction:(id)sender {
    NSLog(@"正在下载 列表");
//    self.downingView.frame = self.contentView.bounds;
//    [self.contentView addSubview:self.downingView];
    
//    [[DownLoadMgr shareInstance] addDownLoadUrl:@"https://note.youdao.com/yws/public/resource/13250e360babc7f20c4d37aaeffdef8e/xmlnote/794FBBFB32654DC698733B7CF88A2B41/6929" title:@"天"];
    
}

- (IBAction)downCompletAction:(id)sender {
    NSLog(@"下载完成列表");
    self.downCompleteView.frame = self.contentView.bounds;
    [self.contentView addSubview:self.downCompleteView];
}

- (DowningView *)downingView
{
    if (!_downingView) {
        _downingView = [DowningView new];
    }
    return _downingView;
}

- (DownCompleteView *)downCompleteView
{
    if (!_downCompleteView) {
        _downCompleteView = [DownCompleteView new];
    }
    return _downCompleteView;
}

@end
