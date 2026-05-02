## ADDED Requirements

### Requirement: 旅游路线数据模型
系统 SHALL 提供 TravelRoute 数据模型，包含 id、dynastyId、name、description、figureId（可选，关联历史人物）、coverStory、difficulty（easy/medium/hard）、estimatedDays、isCustom、createdAt 字段。

#### Scenario: 查询张骞出使西域路线
- **WHEN** 查询 name="张骞出使西域" 的路线
- **THEN** 返回 dynastyId=1、figureId=张骞、difficulty="hard"、estimatedDays=30 的路线记录

### Requirement: 路线站点数据模型
系统 SHALL 提供 RouteStop 数据模型，包含 id、routeId、orderIndex、locationId（引用古代地点）、modernLocationId、title、description、arrivalStory、stayDuration（建议停留时间）字段。站点 SHALL 按 orderIndex 排序。

#### Scenario: 查询张骞路线站点
- **WHEN** 查询 routeId=张骞出使西域 的所有站点按 orderIndex 排序
- **THEN** 返回有序列表：1.长安(出发) → 2.陇西 → 3.武威 → 4.张掖 → 5.酒泉 → 6.敦煌 → 7.大宛...

### Requirement: 路线种子数据导入
系统 SHALL 从 assets/data/han_travel_routes.json 导入汉代经典路线数据，包含至少 5 条经典路线。导入 SHALL 在种子数据版本升级时执行。

#### Scenario: 导入经典路线
- **WHEN** 应用检测到新种子数据版本
- **THEN** 导入路线数据：张骞出使西域、丝绸之路、刘邦入关、汉武帝巡游、司马迁游历路线

### Requirement: 路线列表页
系统 SHALL 提供路线浏览页面，展示所有可用路线卡片。每张卡片显示路线名称、关联人物、难度等级、预计天数、简介。

#### Scenario: 浏览汉代路线
- **WHEN** 用户进入"古人足迹"路线页面
- **THEN** 显示路线卡片列表：张骞出使西域(困难/30天)、刘邦入关(中等/7天)、司马迁游历(中等/60天)...

### Requirement: 路线详情页
系统 SHALL 提供路线详情页，包含路线地图（显示全部站点和连线）、站点列表、路线故事介绍、关联历史人物信息。站点列表 SHALL 显示古今地名对照。

#### Scenario: 查看张骞路线详情
- **WHEN** 用户点击"张骞出使西域"路线卡片
- **THEN** 显示路线详情：地图上显示长安→陇西→武威→张掖→酒泉→敦煌的连线轨迹，下方为站点列表（每站显示古地名+现代城市名），顶部为张骞人物介绍

#### Scenario: 路线站点古今对照
- **WHEN** 路线详情页展示站点列表
- **THEN** 每个站点显示"古：武威郡 → 今：甘肃省武威市"的对照信息

### Requirement: 路线地图导航
系统 SHALL 在路线详情页地图上用折线连接所有站点，按顺序显示编号标记。用户点击站点标记 SHALL 弹出站点详情（古地名、现代地名、历史故事）。

#### Scenario: 路线地图显示
- **WHEN** 用户查看路线详情页的地图
- **THEN** 地图上显示编号标记（①②③...）并用彩色折线按顺序连接

#### Scenario: 点击路线站点
- **WHEN** 用户点击路线地图上的②号标记
- **THEN** 弹出底部弹窗：古地名"陇西"、今地名"甘肃省临洮县"、故事"张骞经陇西出塞..."

### Requirement: 自定义路线创建
系统 SHALL 允许用户从地点收藏列表或搜索结果中选择多个地点，创建自定义旅游路线。用户 SHALL 可拖拽排序站点顺序。

#### Scenario: 创建自定义路线
- **WHEN** 用户选择"长安"、"洛阳"、"南阳"三个地点并点击"创建路线"
- **THEN** 创建新的自定义路线记录（isCustom=true），用户可编辑路线名称

#### Scenario: 拖拽排序站点
- **WHEN** 用户在自定义路线编辑页长按并拖拽站点
- **THEN** 站点顺序随之更新，更新 RouteStop 的 orderIndex

### Requirement: 路线收藏
系统 SHALL 允许用户收藏路线（预置和自定义均可）。收藏的路线 SHALL 在路线列表页的"已收藏"标签下展示。

#### Scenario: 收藏路线
- **WHEN** 用户在路线详情页点击收藏按钮
- **THEN** 路线被添加到收藏列表，收藏按钮变为已收藏状态

#### Scenario: 查看收藏路线
- **WHEN** 用户切换到路线列表的"已收藏"标签
- **THEN** 仅显示用户收藏的路线
