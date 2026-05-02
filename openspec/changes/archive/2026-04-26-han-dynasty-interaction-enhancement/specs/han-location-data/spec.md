## MODIFIED Requirements

### Requirement: 种子数据导入
系统 SHALL 在首次启动时从 assets/data/han_dynasty_locations.json 导入种子数据到 SQLite 数据库。数据 SHALL 包含至少 13 州、50 郡、30 关键县。后续启动 SHALL 检查 seed_version 避免重复导入。系统 SHALL 同时支持多朝代种子数据文件的导入。

#### Scenario: 首次启动导入数据
- **WHEN** 应用首次启动（SharedPreferences 中无 seed_version）
- **THEN** 读取所有朝代 JSON 文件（han_dynasty_locations.json、tang_dynasty_locations.json、song_dynasty_locations.json），在单个事务中插入所有朝代、古地名、现代地名、匹配关系数据，并设置 seed_version

#### Scenario: 非首次启动跳过导入
- **WHEN** 应用非首次启动（seed_version 已存在且版本匹配）
- **THEN** 跳过数据导入，直接使用现有数据库

#### Scenario: 新增朝代数据导入
- **WHEN** 应用更新后检测到新的朝代种子数据文件（如 tang_dynasty_locations.json）
- **THEN** 仅导入新增朝代的数据，不重复导入已有朝代数据

## ADDED Requirements

### Requirement: 人物关联种子数据
系统 SHALL 从 assets/data/han_historical_figures.json 导入历史人物和人物-地点关联数据。人物数据 SHALL 包含至少 30 位汉代重要人物。

#### Scenario: 导入人物关联数据
- **WHEN** 应用检测到人物数据版本升级
- **THEN** 读取 han_historical_figures.json，导入 historical_figures 和 figure_location_relations 数据

### Requirement: 路线种子数据导入
系统 SHALL 从 assets/data/han_travel_routes.json 导入汉代经典旅游路线和路线站点数据。

#### Scenario: 导入路线数据
- **WHEN** 应用检测到路线数据版本升级
- **THEN** 读取 han_travel_routes.json，导入 travel_routes 和 route_stops 数据

### Requirement: 历史知识卡片种子数据
系统 SHALL 从 assets/data/history_cards.json 导入历史知识卡片数据，包含至少 60 条汉代知识卡片。

#### Scenario: 导入知识卡片
- **WHEN** 应用检测到知识卡片数据版本升级
- **THEN** 读取 history_cards.json，导入 history_cards 数据

### Requirement: 用户数据表
系统 SHALL 提供 user_favorites 和 browse_history 两张 SQLite 表，用于存储用户收藏和浏览历史。user_favorites 包含 id、locationId、dynastyId、createdAt。browse_history 包含 id、locationId、dynastyId、visitedAt。

#### Scenario: 创建用户数据表
- **WHEN** 数据库初始化
- **THEN** 创建 user_favorites 和 browse_history 表及相应索引
