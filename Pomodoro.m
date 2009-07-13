// Pomodoro Desktop - Copyright (c) 2009, Ugo Landini (ugol@computer.org)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
// * Neither the name of the <organization> nor the
// names of its contributors may be used to endorse or promote products
// derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "Pomodoro.h"


@implementation Pomodoro

@synthesize duration, oneSecTimer, breakTimer, interruptionTimer, delegate;

- (id) init { 
    if ( self = [super init] ) {
        [self initWithDuration:25];
    }
    return self;
}

- (id) initWithDuration:(NSInteger) durationTime { 
    if ( self = [super init] ) {
        duration = durationTime;
    }
    return self;
}

-(void) startFor: (NSInteger) seconds {
	time = seconds; 
	oneSecTimer = [[NSTimer timerWithTimeInterval:1
											   target:self
											 selector:@selector(oncePersecond:)													 
											 userInfo:nil
										  repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:oneSecTimer forMode:NSRunLoopCommonModes];	

}

-(void) start {
	if (duration > 0) {
		[self startFor: duration*60];
		if ([delegate respondsToSelector: @selector(pomodoroStarted)]) {
			[delegate pomodoroStarted];
		}
	}
}

-(void) breakFor:(NSInteger)breakMinutes {
	if (![oneSecTimer isValid]) {
		time = breakMinutes * 60;
		breakTimer = [NSTimer timerWithTimeInterval:1
											  target:self
											selector:@selector(oncePersecondBreak:)													 
											userInfo:nil
											 repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:breakTimer forMode:NSRunLoopCommonModes];
		
		if ([delegate respondsToSelector: @selector(breakStarted)]) {
			[delegate breakStarted];
		}
	}
}

-(void) reset {
    [oneSecTimer invalidate];			
	if ([delegate respondsToSelector: @selector(pomodoroReset)]) {
        [delegate pomodoroReset];
	}
}

-(void) interruptFor:(NSInteger) seconds {
	[oneSecTimer invalidate];
	interruptionTimer = [NSTimer timerWithTimeInterval:seconds
										  target:self
											  selector:@selector(interruptFinished:)													 
										userInfo:nil
										 repeats:NO];	
	[[NSRunLoop currentRunLoop] addTimer:interruptionTimer forMode:NSRunLoopCommonModes];
	if ([delegate respondsToSelector: @selector(pomodoroInterrupted)]) {
        [delegate pomodoroInterrupted];
	}
}

-(void) resume {
	[interruptionTimer invalidate];
	[self startFor: time];
	if ([delegate respondsToSelector: @selector(pomodoroResumed)]) {
        [delegate pomodoroResumed];		
	}
}

-(void) complete {
	time = 0;
	[oneSecTimer invalidate];
	if ([delegate respondsToSelector: @selector(pomodoroFinished)]) {
		[delegate pomodoroFinished];		
	}	
}

- (void) checkIfFinished {
	if (time == 0) {
		[oneSecTimer invalidate];			
		if ([delegate respondsToSelector: @selector(pomodoroFinished)]) {
			[delegate pomodoroFinished];		
		}		
	}
}

- (void) checkIfBreakFinished {
	if (time == 0) {
		[breakTimer invalidate];			
		if ([delegate respondsToSelector: @selector(breakFinished)]) {
			[delegate breakFinished];		
		}		
	}
}

- (void)oncePersecond:(NSTimer *)aTimer
{
	time--;
	//time=time-10;
	[delegate oncePerSecond:time];		
	[self checkIfFinished];		
}

- (void)oncePersecondBreak:(NSTimer *)aTimer
{
	time--;
	//time=time-10;
	[delegate oncePerSecondBreak:time];		
	[self checkIfBreakFinished];		
}

-(void) interruptFinished:(NSTimer *)aTimer {
	[oneSecTimer invalidate];
	if ([delegate respondsToSelector: @selector(pomodoroInterruptionMaxTimeIsOver)]) {
        [delegate pomodoroInterruptionMaxTimeIsOver];		
	}
}

-(void)dealloc {
	[oneSecTimer release];
	[breakTimer release];
	[interruptionTimer release];
	[super dealloc];
}

@end

