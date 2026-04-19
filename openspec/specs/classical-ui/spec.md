## ADDED Requirements

### Requirement: 古典色彩主题
系统 SHALL 使用中国传统色彩作为主题色：主色朱红(#C3272B)、辅色苍绿(#2C5F34)、背景宣纸色(#F5F0E8)、文字墨褐(#3B2E1E)、装饰鎏金(#8B6914)。

#### Scenario: 首页主题渲染
- **WHEN** 用户打开应用首页
- **THEN** 页面背景为宣纸色(#F5F0E8)，标题使用墨褐色文字，按钮使用朱红色背景

### Requirement: 宋体风格字体
系统 SHALL 使用 Noto Serif SC 作为主要字体，标题 24-28sp/w700，正文 14-16sp/w400，说明文字 12sp/w300。

#### Scenario: 地点名称字体渲染
- **WHEN** 显示古地名"长安"
- **THEN** 使用 Noto Serif SC 字体、24sp、FontWeight.w700 渲染

### Requirement: 水墨风格启动页
系统 SHALL 显示水墨画风格的启动页，包含应用名称"华夏足迹"和副标题"踏寻千年足迹"，使用淡入动画，后台执行数据库初始化。

#### Scenario: 首次启动加载
- **WHEN** 应用首次启动
- **THEN** 显示水墨风格启动页，应用名称淡入显示，数据库初始化完成后自动跳转首页

### Requirement: 古典装饰组件
系统 SHALL 提供古典风格的 UI 组件：含金边的古典卡片（ClassicalCard）、带云纹的 AppBar（ClassicalAppBar）、朝代徽章（DynastyBadge）。

#### Scenario: 古典卡片渲染
- **WHEN** 显示州级地点卡片
- **THEN** 卡片具有圆角、细金边(#B8860B)、轻微阴影的古典样式

### Requirement: 加载动画
系统 SHALL 使用水墨扩散效果作为加载动画（CustomPainter + AnimationController 实现）。

#### Scenario: 数据加载中
- **WHEN** 数据正在加载（如首次导入种子数据）
- **THEN** 显示水墨扩散风格的加载动画

### Requirement: 页面过渡动画
系统 SHALL 使用淡入淡出（类似水墨消融）的页面过渡动画，非默认的滑动效果。

#### Scenario: 从首页进入地图页
- **WHEN** 用户从首页点击"地图探索"
- **THEN** 页面以淡入淡出效果过渡到地图页
