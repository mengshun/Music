//
//  MusicPlayView.m
//  MusicDown
//
//  Created by 孟顺 on 2020/3/21.
//  Copyright © 2020 mengshun. All rights reserved.
//

#import "MusicPlayView.h"
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>

@interface MusicPlayView ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) NSButton *upMusictBtn;
@property (nonatomic, strong) NSButton *playMusictBtn;
@property (nonatomic, strong) NSButton *nextMusictBtn;

@property (nonatomic, strong) NSSlider *slider;

@property (nonatomic, strong) NSTextField *timeLabel;
@property (nonatomic, strong) NSTextField *nameLabel;

@property (nonatomic, assign) BOOL isDragSlider;    //是否正在拖动 进度条 如果正在拖动则无需 刷新进度条

@property (nonatomic, strong) id observer;

@property (nonatomic, copy) NSString *playerUrl;

@end

@implementation MusicPlayView

- (void)dealloc
{
    [self removeObserverAction];
}

- (void)removeObserverAction
{
    if (_observer) {
        [self.player removeTimeObserver:_observer];
        _observer = nil;
    }
}

- (void)playMusicWithUrl:(NSString *)musicUrl title:(NSString *)musicTitle
{
    if ([musicUrl isEqualToString:self.playerUrl]) {
        NSLog(@"已经正在播放了");
        return;
    } else {
        self.playerUrl = musicUrl;
    }
    self.timeLabel.stringValue = @"00:00/0:00";
    self.nameLabel.stringValue = musicTitle;
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:musicUrl]];
    [self.player replaceCurrentItemWithPlayerItem:item];
    [self.player play];
    
    [self removeObserverAction];
    __weak typeof(self) weakSelf = self;
    self.observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (!weakSelf.isDragSlider) {
            float current = CMTimeGetSeconds(time);
            float total = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
            weakSelf.timeLabel.stringValue = [NSString stringWithFormat:@"%@/%@", [weakSelf transformTime:(int)current], [weakSelf transformTime:(int)total]];
            weakSelf.slider.floatValue = current/total;
        }
    }];
    self.slider.enabled = YES;
    self.slider.floatValue = 0;
    [self.playMusictBtn setImage:[NSImage imageNamed:@"music_pause"]];
}

//格式化时间 将秒转化为 分秒格式
- (NSString *)transformTime:(int)time
{
    if (time < 0 || time/60/60 > 24) {
        return @"00:00";
    }
    return [NSString stringWithFormat:@"%02d:%02d", time/60, time%60];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:self.upMusictBtn];
    [self addSubview:self.playMusictBtn];
    [self addSubview:self.nextMusictBtn];
    [self addSubview:self.slider];
    [self addSubview:self.timeLabel];
    [self addSubview:self.nameLabel];
    
    [self.upMusictBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.mas_equalTo(0);
    }];
    [self.playMusictBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.upMusictBtn.mas_right).offset(15);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.mas_equalTo(0);
    }];
    [self.nextMusictBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playMusictBtn.mas_right).offset(15);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.mas_equalTo(0);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.left.equalTo(self.nextMusictBtn.mas_right).offset(20);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(-10);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider);
        make.centerY.mas_equalTo(10);
        make.width.mas_equalTo(90);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel.mas_right).offset(10);
        make.centerY.mas_equalTo(10);
        make.right.mas_equalTo(-20);
    }];
    
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)upAction
{
    
}

- (void)playAction
{
    if (self.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        [self.player play];
        [self.playMusictBtn setImage:[NSImage imageNamed:@"music_pause"]];
    } else if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        [self.player pause];
        [self.playMusictBtn setImage:[NSImage imageNamed:@"music_play"]];
    } else {
        NSLog(@"AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate");
    }
}

-(void)nextAction
{
    
}

- (void)sliderAction:(NSSlider *)sl
{
    if (self.player.currentItem) {
        NSEvent *event = [NSApplication sharedApplication].currentEvent;
        if (event.type == NSEventTypeLeftMouseUp) {
            self.isDragSlider = NO;
            float sliderValue = sl.floatValue;
            if (self.player.currentItem) {
                CMTime durationTime = self.player.currentItem.duration;
                CMTime currentTime = CMTimeMake(durationTime.value*sliderValue, durationTime.timescale);
                [self.player seekToTime:currentTime];
            }
        } else {
            self.isDragSlider = YES;
            float total = CMTimeGetSeconds(self.player.currentItem.duration);
            float current = total*sl.floatValue;
            self.timeLabel.stringValue = [NSString stringWithFormat:@"%@/%@", [self transformTime:(int)current], [self transformTime:(int)total]];
        }
    } else {
        sl.floatValue = 0;
    }
}

- (void)playbackFinished:(id)sender
{
    [self.playMusictBtn setImage:[NSImage imageNamed:@"music_play"]];
    self.slider.floatValue = 0;
    if (self.player.currentItem) {
        CMTime time = self.player.currentItem.duration;
        [self.player seekToTime:CMTimeMake(0, time.timescale)];
    }
}

- (NSButton *)upMusictBtn
{
    if (!_upMusictBtn) {
        _upMusictBtn = [NSButton buttonWithImage:[NSImage imageNamed:@"up_music_icon"] target:self action:@selector(upAction)];
    }
    return _upMusictBtn;
}

- (NSButton *)playMusictBtn
{
    if (!_playMusictBtn) {
        _playMusictBtn = [NSButton buttonWithImage:[NSImage imageNamed:@"music_play"] target:self action:@selector(playAction)];
    }
    return _playMusictBtn;
}

- (NSButton *)nextMusictBtn
{
    if (!_nextMusictBtn) {
        _nextMusictBtn = [NSButton buttonWithImage:[NSImage imageNamed:@"next_music_icon"] target:self action:@selector(nextAction)];
    }
    return _nextMusictBtn;
}

- (NSSlider *)slider
{
    if (!_slider) {
        _slider = [[NSSlider alloc] init];
        _slider.target = self;
        _slider.minValue = 0;
        _slider.maxValue = 1;
        [_slider setAction:@selector(sliderAction:)];
        _slider.enabled = NO;
    }
    return _slider;
}

- (NSTextField *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[NSTextField alloc] init];
        _timeLabel.editable = NO;
        _timeLabel.textColor = NSColor.blackColor;
        _timeLabel.bordered = NO;
        _timeLabel.drawsBackground = NO;
    }
    return _timeLabel;
}

- (NSTextField *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[NSTextField alloc] init];
        _nameLabel.editable = NO;
        _nameLabel.textColor = NSColor.blackColor;
        _nameLabel.bordered = NO;
        _nameLabel.drawsBackground = NO;
    }
    return _nameLabel;
}

- (AVPlayer *)player
{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return _player;
}

@end
