## ADDED Requirements

### Requirement: 本地精确名称匹配
系统 SHALL 优先通过本地数据库进行古今地名匹配。第一级匹配：直接比对古地名与现代地名（去除"市/区/县"后缀后比较）。

#### Scenario: 洛阳精确匹配
- **WHEN** 匹配古地名"洛阳"
- **THEN** 在 modern_locations 表中找到"洛阳市"，返回 confidence=0.95、source="manual"

#### Scenario: 成都精确匹配
- **WHEN** 匹配古地名"成都"
- **THEN** 在 modern_locations 表中找到"成都市"，返回 confidence=0.95、source="manual"

### Requirement: 名称相似度匹配
系统 SHALL 在精确匹配失败后，检查古地名是否为现代地名的子串，或现代地名是否包含古地名。

#### Scenario: 临淄子串匹配
- **WHEN** 匹配古地名"临淄"
- **THEN** 找到"淄博市临淄区"，返回 confidence=0.7、matchType="approximate"、source="manual"

### Requirement: 已知映射字典匹配
系统 SHALL 维护一个硬编码的古今地名映射字典，用于名称已完全变更的城市。

#### Scenario: 长安映射到西安
- **WHEN** 匹配古地名"长安"
- **THEN** 通过字典映射找到"西安市"，返回 confidence=0.9、matchType="exact"、source="manual"

#### Scenario: 彭城映射到徐州
- **WHEN** 匹配古地名"彭城"
- **THEN** 通过字典映射找到"徐州市"，返回 confidence=0.9、source="manual"

### Requirement: AI API 兜底匹配
系统 SHALL 在本地匹配全部失败后，调用 AI API 进行匹配。AI 匹配结果 SHALL 包含现代城市名、省份、经纬度、匹配置信度、匹配说明。所有 AI 匹配结果 SHALL 标记 source="ai"、verified=false。

#### Scenario: AI 成功匹配冷门地名
- **WHEN** 匹配一个本地数据库中无匹配记录的古地名
- **THEN** 调用 AI API，返回包含 modernName、latitude、longitude、confidence 的结果，并缓存到数据库

#### Scenario: AI 匹配失败
- **WHEN** AI API 调用超时或返回无效数据
- **THEN** 标记该古地名为 unmatched，不阻塞用户操作

#### Scenario: AI 结果坐标校验
- **WHEN** AI 返回的经纬度
- **THEN** 系统 SHALL 校验纬度在 [18, 54]、经度在 [73, 135] 范围内（中国领土范围），超出范围的 SHALL 被拒绝

### Requirement: 匹配结果缓存
系统 SHALL 将所有匹配结果（包括 AI 生成的）持久化到 location_matches 表，确保离线可用。已缓存的匹配 SHALL 直接从数据库读取，不重复调用 AI。

#### Scenario: 重复匹配直接读缓存
- **WHEN** 用户第二次查询同一个古地名的匹配
- **THEN** 直接从 location_matches 表返回结果，不调用 AI API

### Requirement: 离线优先匹配
系统 SHALL 在无网络连接时仍能完成本地匹配（精确/相似/字典三级）。AI 匹配仅在联网时可用，离线时标记为"需要联网匹配"。

#### Scenario: 离线状态下的匹配
- **WHEN** 设备无网络且古地名无法本地匹配
- **THEN** 返回部分结果（本地匹配成功的）+ 标记未匹配项为"待联网匹配"
