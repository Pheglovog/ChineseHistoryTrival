## ADDED Requirements

### Requirement: 地点收藏数据模型
系统 SHALL 提供 user_favorites 表，包含 id、locationId、dynastyId、createdAt 字段。同一地点 SHALL 不可重复收藏。

#### Scenario: 收藏地点
- **WHEN** 用户在地点详情页点击收藏按钮
- **THEN** 插入一条 user_favorites 记录，收藏按钮切换为已收藏状态

#### Scenario: 取消收藏
- **WHEN** 用户再次点击已收藏地点的收藏按钮
- **THEN** 删除对应的 user_favorites 记录，收藏按钮恢复未收藏状态

#### Scenario: 防止重复收藏
- **WHEN** 用户尝试收藏已收藏的地点
- **THEN** 系统忽略操作或切换为取消收藏（toggle 行为）

### Requirement: 收藏列表页
系统 SHALL 提供收藏列表页面，按朝代分组展示用户收藏的地点。每组显示朝代名和地点数量。每个地点条目显示古地名、现代地名、行政级别。

#### Scenario: 浏览收藏列表
- **WHEN** 用户进入"我的收藏"页面
- **THEN** 显示按朝代分组的收藏列表，如"汉朝(12)"、"唐朝(3)"

#### Scenario: 从收藏跳转地图
- **WHEN** 用户在收藏列表中点击"长安"
- **THEN** 跳转到地图页，定位到长安位置

### Requirement: 浏览历史数据模型
系统 SHALL 提供 browse_history 表，包含 id、locationId、dynastyId、visitedAt 字段。同一地点多次访问 SHALL 只保留最近一条记录（UPSERT 行为）。

#### Scenario: 记录浏览历史
- **WHEN** 用户查看某个地点的详情页
- **THEN** 系统自动插入或更新 browse_history 记录，visitedAt 为当前时间

#### Scenario: 更新已存在的历史记录
- **WHEN** 用户再次查看已浏览过的"长安"
- **THEN** 系统更新该记录的 visitedAt 为当前时间，不新增记录

### Requirement: 浏览历史列表页
系统 SHALL 提供浏览历史页面，按访问时间倒序展示用户浏览过的地点。支持清除全部历史。

#### Scenario: 浏览历史记录
- **WHEN** 用户进入"浏览历史"页面
- **THEN** 显示按时间倒序排列的地点列表，每条显示古地名、现代地名、浏览时间

#### Scenario: 清除浏览历史
- **WHEN** 用户点击"清除全部历史"
- **THEN** 弹出确认弹窗，确认后删除所有 browse_history 记录

### Requirement: 搜索结果筛选与排序
系统 SHALL 在搜索结果页提供行政级别筛选（全部/州/郡/县）和排序选项（相关度/名称/行政级别）。

#### Scenario: 筛选搜索结果
- **WHEN** 用户搜索"阳"并选择"郡"级别筛选
- **THEN** 仅显示包含"阳"字的郡级地名

#### Scenario: 按名称排序
- **WHEN** 用户在搜索结果中选择"按名称排序"
- **THEN** 搜索结果按拼音首字母排序展示

### Requirement: 分享功能
系统 SHALL 允许用户分享地点信息，生成包含古地名、现代地名、坐标、朝代的精美图片卡片。使用 Flutter RenderRepaint 生成图片，通过 share_plus 调用系统分享。

#### Scenario: 分享地点卡片
- **WHEN** 用户在地点详情页点击分享按钮
- **THEN** 系统生成包含古地名、现代地名、朝代、古典边框装饰的图片，调起系统分享面板

#### Scenario: 分享图片内容
- **WHEN** 分享图片生成完成
- **THEN** 图片包含：古地名（大字）、现代地名（副标题）、朝代标签、坐标信息、古典风格边框和背景
