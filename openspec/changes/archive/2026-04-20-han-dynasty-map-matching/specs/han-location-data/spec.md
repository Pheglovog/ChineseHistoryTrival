## ADDED Requirements

### Requirement: 汉代朝代数据模型
系统 SHALL 提供朝代（Dynasty）数据模型，包含 id、name、nameEn、startYear、endYear、subPeriod、description 字段。汉朝数据 SHALL 包含 startYear=-202、endYear=220。

#### Scenario: 读取汉朝朝代信息
- **WHEN** 应用启动并加载朝代数据
- **THEN** 返回 id=1、name="汉朝"、startYear=-202、endYear=220 的朝代记录

### Requirement: 汉代古地名数据模型
系统 SHALL 提供古地名（AncientLocation）数据模型，包含 id、dynastyId、name、alias、adminLevel（zhou/jun/xian）、parentLocationId、description、yearEstablished、yearAbolished、historicalSignificance 字段。

#### Scenario: 查询汉代州级地名
- **WHEN** 按 dynastyId=1 且 adminLevel="zhou" 查询
- **THEN** 返回 13 条州级记录（司隶校尉部、豫州、兖州、徐州、青州、凉州、并州、冀州、幽州、益州、荆州、扬州、交州）

#### Scenario: 查询郡级地名及其上级州
- **WHEN** 查询"京兆尹"并关联 parentLocationId
- **THEN** 返回 name="京兆尹"、adminLevel="jun"、parentLocation.name="司隶校尉部"

### Requirement: 现代地名数据模型
系统 SHALL 提供现代地名（ModernLocation）数据模型，包含 id、name、province、city、district、latitude、longitude、amapPoiId、source、confidence、verified 字段。

#### Scenario: 查询现代城市坐标
- **WHEN** 查询 name="西安市"
- **THEN** 返回 province="陕西省"、latitude≈34.26、longitude≈108.93

### Requirement: 古今地名匹配关系数据模型
系统 SHALL 提供匹配关系（LocationMatch）数据模型，包含 id、ancientLocationId、modernLocationId、matchType（exact/approximate/regional）、confidence、source（manual/ai/geocoding）、notes、verified、createdAt 字段。

#### Scenario: 查询长安的现代匹配
- **WHEN** 查询 ancientLocation.name="长安"的匹配关系
- **THEN** 返回 modernLocation.name="西安市未央区"、matchType="exact"、confidence=1.0、source="manual"

### Requirement: 种子数据导入
系统 SHALL 在首次启动时从 assets/data/han_dynasty_locations.json 导入种子数据到 SQLite 数据库。数据 SHALL 包含至少 13 州、50 郡、30 关键县。后续启动 SHALL 检查 seed_version 避免重复导入。

#### Scenario: 首次启动导入数据
- **WHEN** 应用首次启动（SharedPreferences 中无 seed_version）
- **THEN** 读取 JSON 文件，在单个事务中插入所有朝代、古地名、现代地名、匹配关系数据，并设置 seed_version=1

#### Scenario: 非首次启动跳过导入
- **WHEN** 应用非首次启动（seed_version 已存在且版本匹配）
- **THEN** 跳过数据导入，直接使用现有数据库

### Requirement: 数据库响应式查询
系统 SHALL 通过 Drift 的 `.watch()` 方法提供响应式数据流，当数据变更时自动通知 UI 层更新。

#### Scenario: 新增匹配后 UI 自动更新
- **WHEN** 用户触发 AI 匹配并写入新的 LocationMatch 记录
- **THEN** 正在 `.watch()` 该查询的 UI 组件自动收到新数据并刷新
