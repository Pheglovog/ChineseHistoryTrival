## ADDED Requirements

### Requirement: 历史知识卡片数据
系统 SHALL 提供历史知识卡片（HistoryCard）数据模型，包含 id、dynastyId、title、content、figureId（可选）、locationId（可选）、dateHint（如"4月15日"关联历史事件的日期提示）、category（event/figure/culture/geography）字段。

#### Scenario: 读取知识卡片
- **WHEN** 查询 id=1 的知识卡片
- **THEN** 返回 title="罢黜百家，独尊儒术"、content="公元前134年..."、category="event"、dynastyId=1

### Requirement: 知识卡片种子数据
系统 SHALL 从 assets/data/history_cards.json 导入历史知识卡片数据，包含至少 60 条汉代知识卡片，涵盖历史事件、人物故事、文化典故、地理知识四类。

#### Scenario: 首次导入知识卡片
- **WHEN** 应用检测到新种子数据版本
- **THEN** 导入 history_cards 数据到 SQLite

### Requirement: 每日一史推送
系统 SHALL 在用户开启"每日一史"功能后，每天上午 9:00 通过本地通知推送一条历史知识卡片。推送 SHALL 按日期循环，不重复直到全部展示完毕。

#### Scenario: 开启每日一史
- **WHEN** 用户在设置中开启"每日一史"
- **THEN** 系统请求通知权限（如未授权），成功后调度每日 9:00 的本地通知

#### Scenario: 收到每日一史通知
- **WHEN** 每日上午 9:00 触发通知
- **THEN** 用户收到通知，标题为知识卡片的 title，内容为 content 前 50 字

#### Scenario: 通知权限被拒绝
- **WHEN** 用户拒绝通知权限
- **THEN** 每日一史功能仅在 App 内"每日一史"页面展示，不发送通知

### Requirement: 每日一史浏览页
系统 SHALL 在首页提供"每日一史"入口，展示当天和历史知识卡片列表。每张卡片显示标题、类别标签、简短内容，可展开查看完整内容和关联人物/地点。

#### Scenario: 查看今日知识
- **WHEN** 用户点击首页"每日一史"入口
- **THEN** 展示今日推荐的历史知识卡片，包含完整内容、关联人物（如有）和关联地点（如有）

#### Scenario: 查看历史知识列表
- **WHEN** 用户在每日一史页面向下滑动
- **THEN** 展示按日期排列的历史知识卡片列表，已读卡片和未读卡片使用不同视觉样式区分

#### Scenario: 从知识卡片跳转
- **WHEN** 用户点击知识卡片中关联的人物"张骞"
- **THEN** 跳转到张骞的人物详情页
