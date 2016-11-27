# videoPlayer
一个支持各种手势, 旋转屏, 画中画播放器 <br/>
水平滑动: 快进快退 <br/>
滑动屏幕左侧: 调整亮度 <br/>
滑动屏幕右侧: 调整声音 <br/>
单机屏幕: 显示或者隐藏控制栏 <br/>
双击屏幕: 暂停/播放视频 <br/>
点击全屏/退出全屏按钮, 或者旋转屏幕: 进行全屏和普通状态切换 <br/>
点击画中画: 进行画中画 <br/>

1.1版本更新:<br/>
1. 对播放功能部分进行封装, 是UI部分与播放器处理部分分离, LRLVideoPlayerSDK 处理的是播放功能部分,  LRLVideoPlayerView 是 对 LRLVideoPlayerSDK 进行UI手势的封装, 也可单独使用LRLVideoPlayerSDK;<br/>
2. 新添加h后台播放功能, 开启后可以在程序进入后台后继续播放声音<br/>


