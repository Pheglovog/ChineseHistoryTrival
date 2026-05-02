## ADDED Requirements

### Requirement: 历史人物数据模型
系统 SHALL 提供历史人物（HistoricalFigure）数据模型，包含 id、dynastyId、name、alias、title、birthYear、deathYear、description、biography 字段。

#### Scenario: 读取刘邦人物信息
- **WHEN** 查询 dynastyId=1 且 name="刘邦"的人物记录
- **THEN** 返回 name="刘邦"、alias="汉高祖"、title="皇帝"、birthYear=-256、deathYear=-195、description="汉朝开国皇帝"

### Requirement: 人物与地点多对多关联
系统 SHALL 提供 figure_location_relations 关联表，包含 id、figureId、locationId、relationType（born/battle/ruled/traveled/died/other）、description 字段。一个人物 SHALL 可关联多个地点，一个地点 SHALL 可关联多个人物。

#### Scenario: 查询刘邦关联地点
- **WHEN** 查询 figureId=刘邦 的所有关联
- **THEN** 返回沛县(born)、关中(traveled)、长安(ruled) 等多条关联记录

#### Scenario: 查询长安关联人物
- **WHEN** 查询 locationId=长安 的所有关联人物
- **THEN** 返回刘邦(ruled)、汉武帝(ruled)、司马迁(traveled)、张骞(traveled) 等多条关联记录

### Requirement: 历史人物种子数据导入
系统 SHALL 从 assets/data/han_historical_figures.json 导入汉代历史人物数据，包含至少 30 位重要人物及其地点关联。导入 SHALL 在种子数据版本升级时执行。

#### Scenario: 首次导入人物数据
- **WHEN** 应用检测到新种子数据版本
- **THEN** 读取 JSON 文件，插入 historical_figures 和 figure_location_relations 数据

### Requirement: 历史人物列表页
系统 SHALL 提供历史人物列表页面，按类别分组展示（帝王、文臣、武将、学者、其他），每组显示人物头像占位、姓名、头衔、简介。

#### Scenario: 浏览汉代人物列表
- **WHEN** 用户进入"历史人物"页面
- **THEN** 显示分组列表：帝王(刘邦、汉武帝、光武帝...)、文臣(萧何、张良...)、武将(韩信、卫青、霍去病...)、学者(司马迁、张衡...)

### Requirement: 历史人物详情页
系统 SHALL 提供人物详情页，展示人物姓名、别名、头衔、生卒年、简介、生平故事、关联地点列表。关联地点 SHALL 可点击跳转到地图定位。

#### Scenario: 查看张骞详情
- **WHEN** 用户点击张骞人物卡片
- **THEN** 显示详情页：姓名"张骞"、头衔"外交家"、生卒年"前164-前114"、简介"丝绸之路开拓者"，关联地点列表包含长安(出发)、陇西、敦煌、大宛等

#### Scenario: 从人物详情跳转地图
- **WHEN** 用户在张骞详情页点击"长安"关联地点
- **THEN** 跳转到地图页，定位到长安位置并高亮标记

### Requirement: 地点关联人物展示
系统 SHALL 在地点详情（底部弹窗和浏览详情页）中展示与该地点关联的历史人物列表，每个人物显示姓名、头衔、与该地点的关系描述。

#### Scenario: 查看长安关联人物
- **WHEN** 用户在地图上点击长安标记查看详情
- **THEN** 底部弹窗新增"历史人物"板块，显示刘邦(定都于此)、汉武帝(治理天下)、司马迁(著《史记》)等人物卡片
