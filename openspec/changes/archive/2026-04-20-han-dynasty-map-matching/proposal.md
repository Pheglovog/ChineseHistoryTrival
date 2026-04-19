## Why

中国历史悠久，无数历史人物在全国各地留下了足迹，但目前缺乏一个将历史地理与现代旅游结合的产品。用户需要手动查找历史地点对应现代位置，自己规划行程。华夏足迹旨在填补这一空白——让用户跟随历史人物的脚步旅游，从地图探索到沉浸式体验，打造完整的"穿越式"旅游产品。

首期聚焦两个维度：
- **客户端 MVP**：汉代地名与现代地图位置的精确匹配与可视化展示
- **后端 AI 服务**：基于 LangChain 的智能旅游 Agent 系统，支撑路线生成、AI 换装、动态规划等核心 AI 能力

## What Changes

### 客户端 (Flutter)
- 新建 Flutter 项目，搭建完整的项目架构（数据层/领域层/展示层）
- 构建汉代地名数据库（13 州、~100 郡、~80 关键县），包含古今地名对照和 GPS 坐标
- 实现古今地名匹配引擎：本地数据库精确匹配 → 名称相似度匹配 → 已知映射字典 → 后端 AI API 兜底
- 集成高德地图 SDK，在现代地图上展示汉代行政区分级标记（州/郡/县三级缩放过滤）
- 实现层级浏览（州→郡→县）和搜索功能
- 采用古典中国美学 UI 设计（朱红/苍绿/宣纸色/水墨风格）

### 后端 (Python / FastAPI + LangChain)
- 搭建 FastAPI 后端服务，集成 LangChain 作为 AI 编排框架
- 实现历史路线规划 Agent：根据用户选择的朝代和人物，生成历史足迹路线
- 实现地理围栏通知服务：用户进入历史地点境内时推送通知
- 实现服装/摄影撮合系统：匹配当地汉服租赁、古装摄影服务商家
- 实现 AI 换装与场景生成：用户拍照上传后，AI 将服装替换为历史服饰并合成历史场景（如太监、宫女等陪侍人物）
- 实现动态行程规划 Agent：根据用户时间、预算、偏好动态调整行程，预订酒店和门票
- 实现行程总结生成：自动将旅行照片、足迹汇总为精美的足迹页面或短视频

## Capabilities

### New Capabilities
- `han-location-data`: 汉代地名数据模型、SQLite 数据库（Drift）、种子数据导入
- `location-matching`: 古今地名匹配引擎，支持本地匹配和后端 AI 兜底
- `amap-integration`: 高德地图集成，汉代标记展示，缩放级别过滤，标记交互
- `location-browse`: 州→郡→县层级浏览和搜索功能
- `classical-ui`: 古典中国美学主题系统（色彩、字体、装饰组件）
- `backend-infrastructure`: FastAPI + LangChain 后端服务架构、API 层、数据库、部署配置
- `historical-route-agent`: 历史路线规划 Agent，根据朝代/人物生成旅行路线
- `geofence-notification`: 地理围栏服务，用户进入历史地点境内时触发推送通知
- `matchmaking-service`: 服装/摄影撮合系统，匹配当地商家
- `ai-image-generation`: AI 换装与历史场景生成（Stable Diffusion + IP-Adapter + ControlNet）
- `dynamic-trip-planner`: 动态行程规划 Agent，根据预算/时间/偏好调整行程并预订酒店门票
- `trip-summary-generator`: 行程总结生成器，自动生成足迹页面或视频

### Modified Capabilities
<!-- 无已有能力需要修改，此为全新项目 -->

## Impact

- **新建项目**: Flutter 前端 + Python 后端，双端从零创建
- **前端依赖**: Flutter SDK, drift, riverpod, amap_map, go_router, freezed, dio
- **后端依赖**: Python 3.11+, FastAPI, LangChain, Stable Diffusion, PostgreSQL, Redis
- **平台**: 需配置高德地图 Android/iOS API Key、后端云服务器部署
- **数据**: 客户端预置 ~200 条汉代地名 JSON 种子数据，后端 PostgreSQL 存储完整历史地理数据
- **外部服务**: 高德地图 SDK（必需）、LangChain + LLM API（必需）、Stable Diffusion（必需）、酒店/门票 API（必需）
