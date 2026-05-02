## Context

华夏足迹是一个 Flutter App，让用户跟随古人脚步旅游。当前已完成汉代地名基础展示：地图标记（高德 SDK）、层级浏览（州/郡/县）、搜索、古典中国 UI 主题。数据存储在本地 SQLite，种子数据从 JSON 导入。

当前架构：Clean Architecture（domain/data/presentation 三层），Riverpod 状态管理，GoRouter 路由。当前 `currentDynastyIdProvider` 硬编码为 1（汉朝）。

本次改动聚焦于：
1. 深化汉代功能的交互性和沉浸感
2. 建立可扩展的多朝代架构基础

## Goals / Non-Goals

**Goals:**
- 让用户从"看地图"升级到"体验历史"——通过人物故事、路线规划、丰富交互
- 建立通用的朝代切换框架，使后续添加朝代仅需增加种子数据
- 所有新功能均在本地 SQLite 运行，不依赖后端
- 保持古典中国美学风格的一致性

**Non-Goals:**
- 不实现后端 API 集成（AI 匹配、LLM 路线生成等保留给后续迭代）
- 不实现 AR 功能（需要相机和传感器，复杂度高，后续迭代）
- 不实现用户账号系统（收藏和历史全部本地存储）
- 不实现付费/商业化功能

## Decisions

### 1. 数据层：扩展 SQLite schema 而非替换

**决策**: 在现有 SQLite 数据库上新增 3 张表（historical_figures, travel_routes, user_data），扩展现有表字段。

**理由**: 现有 sqflite 方案运行稳定，数据量可控（每个朝代 ~200 条），无需迁移到 Drift 或其他 ORM。保持技术栈一致性。

**替代方案**: 迁移到 Drift/Isar → 需要重写整个数据层，代价过大。

### 2. 历史人物数据模型设计

**决策**: HistoricalFigure 实体包含 id, dynastyId, name, alias, title, birthYear, deathYear, description, biography 字段。通过中间表 figure_location_relations 实现 person ↔ location 多对多关联。

**理由**: 一个人可关联多个地点（如刘邦：沛县起兵 → 关中入咸阳 → 长安定都），一个地点也可关联多个人物（长安关联刘邦、汉武帝、司马迁等）。

### 3. 旅游路线数据模型设计

**决策**: TravelRoute 实体（路线元数据）+ RouteStop 实体（路线站点，有序排列，引用 locationId）。预置路线和自定义路线使用同一数据结构，通过 `isCustom` 字段区分。

**理由**: 路线本质上是有序的地点序列。预置路线和用户自建路线在展示和导航逻辑上完全一致，只是数据来源不同。

### 4. 朝代切换架构

**决策**: 将 `currentDynastyIdProvider` 从硬编码改为用户可选的 StateProvider。所有数据查询 provider 依赖 `currentDynastyIdProvider`，切换朝代时自动刷新所有数据。

**理由**: Riverpod 的响应式机制天然支持这种模式——当 dynastyId 变化时，所有依赖它的 provider 自动重新计算。无需额外的状态管理框架。

**替代方案**: 使用多个独立页面 → 代码重复严重，维护成本高。

### 5. 地图双标注方案

**决策**: 使用高德地图的自定义 Marker View，每个标记显示两行文字：古地名（大字）+ 现代地名（小字），通过开关控制是否显示第二行。

**理由**: AMap 自定义 Marker 支持自定义 Widget 渲染，可以灵活控制布局。双标注放在同一个标记上比两个叠加标记性能更好。

### 6. 收藏和历史使用 SQLite 而非 SharedPreferences

**决策**: 新建 user_favorites 和 browse_history 两张 SQLite 表存储用户数据。

**理由**: 收藏和历史数据量可能较大（数百条），SharedPreferences 适合键值对而非列表数据。SQLite 支持分页查询和排序。

### 7. 每日一史使用本地数据 + 本地通知

**决策**: 预置 ~100 条历史知识卡片数据（JSON），使用 flutter_local_notifications 在每天指定时间推送。

**理由**: 不依赖后端，离线可用。100 条足够 3 个月不重复。

## Risks / Trade-offs

- **[数据量]** 预置 3 个朝代的种子数据会使 APK 体积增大 → 使用 JSON 而非数据库文件，压缩效率高。首批只加唐宋基础数据（每朝 ~30 个核心地点）。
- **[性能]** 历史人物多对多关联查询在 SQLite 中需要 JOIN → 数据量可控（每个朝代 ~50 人物），性能不是问题。
- **[地图标记密度]** 双标注增加标记面积 → 仅在 zoom >= 8 时显示双标注，低缩放级别只显示古地名。
- **[通知权限]** Android 13+ 需要通知权限 → 首次启用"每日一史"时请求权限，用户拒绝则仅 App 内展示。
- **[朝代数据质量]** 唐宋朝代数据需要准确的历史地理坐标 → 先收录核心地点（每朝 ~30 个），后续迭代逐步补充。
