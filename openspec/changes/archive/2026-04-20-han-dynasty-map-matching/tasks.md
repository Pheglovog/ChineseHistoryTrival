## 1. Flutter 项目初始化

- [x] 1.1 使用 `flutter create` 创建 Flutter 项目
- [x] 1.2 配置 pubspec.yaml 添加所有依赖（drift, riverpod, amap_map, go_router, freezed, dio 等）
- [x] 1.3 创建项目目录结构（core/data/domain/presentation/router）
- [x] 1.4 配置高德地图 Android API Key（AndroidManifest.xml）
- [x] 1.5 配置高德地图 iOS API Key（Info.plist）

## 2. 主题与 UI 基础

- [x] 2.1 创建 app_colors.dart（朱红/苍绿/宣纸色/鎏金等传统色彩常量）
- [x] 2.2 创建 app_typography.dart（Noto Serif SC 字体样式定义）
- [x] 2.3 创建 app_theme.dart（MaterialDataTheme 配置）
- [x] 2.4 实现 ClassicalCard 组件（金边圆角卡片）
- [x] 2.5 实现 ClassicalAppBar 组件（深色背景 + 金色底边）
- [x] 2.6 实现 DynastyBadge 组件（朝代标签）
- [x] 2.7 实现 LoadingInkWash 组件（水墨扩散加载动画）

## 3. Flutter 数据层 - 数据模型

- [x] 3.1 定义 Drift 表：dynasties_table（朝代表）
- [x] 3.2 定义 Drift 表：ancient_locations_table（古地名表，含索引）
- [x] 3.3 定义 Drift 表：modern_locations_table（现代地名表，含坐标索引）
- [x] 3.4 定义 Drift 表：location_matches_table（匹配关系表，含唯一约束）
- [x] 3.5 创建 Domain 实体类（Dynasty, AncientLocation, ModernLocation, LocationMatch, AdminLevel, MatchType, MatchSource）
- [x] 3.6 创建 AppDatabase 类，注册所有表和 DAO

## 4. Flutter 数据层 - DAO

- [x] 4.1 实现 DynastyDao（CRUD + watch）
- [x] 4.2 实现 AncientLocationDao（按朝代查询、按级别查询、层级查询、watch）
- [x] 4.3 实现 ModernLocationDao（按名称查询、按坐标范围查询）
- [x] 4.4 实现 LocationMatchDao（按古地名查询、按置信度排序、缓存读写）

## 5. 种子数据

- [x] 5.1 编写 han_dynasty_locations.json（13 州 + 50 郡 + 30 关键县，含现代匹配坐标）
- [x] 5.2 实现 DataSeeder（JSON 解析 → 事务导入 SQLite，含 parent 引用解析）
- [x] 5.3 实现 seed_version 检查逻辑（SharedPreferences）

## 6. 匹配引擎

- [x] 6.1 实现 LocationRepository（封装 DAO 的仓库层，提供响应式数据流）
- [x] 6.2 实现 MatchingRepository 第一级：精确名称匹配（去后缀比较）
- [x] 6.3 实现 MatchingRepository 第二级：名称相似度/子串匹配
- [x] 6.4 实现 MatchingRepository 第三级：已知映射字典（长安→西安等）
- [x] 6.5 实现后端 AI Service 客户端（对接 FastAPI 后端 AI 匹配接口）
- [x] 6.6 实现 MatchingRepository 第四级：后端 AI API 兜底（含坐标校验和频率限制）
- [x] 6.7 实现匹配结果缓存（所有结果写入 location_matches 表）

## 7. Provider 层

- [x] 7.1 实现 databaseProvider（Drift 数据库单例）
- [x] 7.2 实现 currentDynastyProvider（当前朝代选择状态）
- [x] 7.3 实现 locationsByDynastyProvider（响应式地点列表）
- [x] 7.4 实现 mapStateProvider（地图相机位置、可见边界、筛选级别）
- [x] 7.5 实现 visibleMarkersProvider（根据地图状态计算可见标记）
- [x] 7.6 实现 matchingWorkflowProvider（匹配流程状态管理）

## 8. 页面 - 启动页与首页

- [x] 8.1 实现 SplashPage（水墨风格、数据库初始化、自动跳转）
- [x] 8.2 实现 HomePage（朝代横幅、功能入口卡片、统计数字）

## 9. 页面 - 地图

- [x] 9.1 实现 HanMapPage（高德地图基础渲染、隐私合规初始化）
- [x] 9.2 实现标记工厂（根据 AdminLevel 生成不同样式标记）
- [x] 9.3 实现缩放级别过滤逻辑（zoom < 6 州、6-9 郡、9+ 全部）
- [x] 9.4 实现视口过滤逻辑（onCameraMoveEnd 触发边界查询）
- [x] 9.5 实现行政级别筛选芯片（全部/州/郡/县）
- [x] 9.6 实现标记点击底部弹窗（BottomSheet 显示地点详情）
- [x] 9.7 实现快速跳转按钮（长安、洛阳等著名城市）
- [x] 9.8 实现地图页搜索栏（输入地名 → 飞到对应位置）

## 10. 页面 - 浏览与搜索

- [x] 10.1 实现 ZhouListPage（13 州网格卡片）
- [x] 10.2 实现 JunListPage（选中州的郡列表）
- [x] 10.3 实现 XianListPage（选中郡的县列表）
- [x] 10.4 实现层级导航（州→郡→县→地图跳转）
- [x] 10.5 实现 SearchPage（全文搜索、300ms 防抖、分组结果展示）

## 11. Flutter 路由与集成

- [x] 11.1 配置 GoRouter 路由（splash, home, map, browse, search, detail）
- [x] 11.2 配置 main.dart（ProviderScope + MaterialApp）
- [x] 11.3 实现页面过渡动画（淡入淡出水墨风格）
- [x] 11.4 运行 build_runner 生成代码（Drift + Riverpod + Freezed）

---

## 12. 后端项目初始化

- [x] 12.1 创建 Python 项目目录结构（backend/）
- [x] 12.2 配置 pyproject.toml（FastAPI, LangChain, SQLAlchemy, Redis, Stable Diffusion 等依赖）
- [x] 12.3 配置 Docker Compose（PostgreSQL + PostGIS + Redis + MinIO）
- [x] 12.4 创建 FastAPI 应用骨架（路由注册、中间件、异常处理）
- [x] 12.5 配置环境变量管理（.env / pydantic-settings）

## 13. 后端数据层

- [x] 13.1 定义 SQLAlchemy 模型：Dynasty, AncientLocation, ModernLocation, LocationMatch（与客户端对齐）
- [x] 13.2 定义 SQLAlchemy 模型：Merchant（商家）, Booking（预约）, GeneratedImage（AI 生成影像）
- [x] 13.3 定义 SQLAlchemy 模型：TripPlan（行程计划）, TripStop（行程站点）, TripSummary（行程总结）
- [x] 13.4 启用 PostGIS 扩展，为地理位置字段创建空间索引
- [x] 13.5 实现 Alembic 数据库迁移配置
- [x] 13.6 导入完整汉代历史地理数据到 PostgreSQL（扩展版，~500+ 条目）

## 14. LangChain Agent 基础架构

- [x] 14.1 实现 Agent 基类（BaseAgent），统一 LangChain Agent 的创建、执行、状态管理接口
- [x] 14.2 实现 Agent Hub（路由分发器），根据请求类型分发到对应 Agent
- [x] 14.3 配置 LangGraph 状态图，支持多步骤 Agent 工作流的暂停/恢复
- [x] 14.4 实现 LLM 抽象层，支持 DeepSeek / Claude / 通义千问 热切换配置
- [x] 14.5 实现通用 Tool 集：地图查询工具（高德 API）、地名匹配工具、天气查询工具

## 15. 历史路线规划 Agent

- [x] 15.1 实现路线规划 Agent（RoutePlanningAgent），基于 LangChain ReAct Agent
- [x] 15.2 实现路线生成 Prompt 模板（含历史人物知识、地理位置约束）
- [x] 15.3 实现多方案推荐逻辑（经典/深度/精华三个方案）
- [x] 15.4 实现路线地点匹配验证（校验每个推荐地点的现代可达性）
- [x] 15.5 实现 API 端点：POST /api/v1/routes/generate
- [x] 15.6 实现路线保存和分享图生成功能

## 16. 地理围栏服务

- [x] 16.1 实现围栏数据初始化：将所有历史地点坐标导入 Redis GEO
- [x] 16.2 实现围栏半径配置（州 50km / 郡 20km / 县 5km）
- [x] 16.3 实现位置上报 API：POST /api/v1/location/report
- [x] 16.4 实现围栏判定逻辑（Redis GEOADIUS 查询）
- [x] 16.5 实现通知触发与频率控制（24 小时去重）
- [x] 16.6 实现推送通知内容生成（LLM 生成古典文风通知文案）

## 17. 服装/摄影撮合服务

- [x] 17.1 实现商家数据模型和 CRUD API
- [x] 17.2 实现基于位置的商家推荐（距离 + 评分 + 朝代匹配排序）
- [x] 17.3 实现美团/大众点评 API 集成（冷启动数据补充）
- [x] 17.4 实现预约订单模型和创建/确认/取消 API
- [x] 17.5 实现 API 端点：GET /api/v1/merchants/nearby, POST /api/v1/bookings

## 18. AI 换装与场景生成

- [x] 18.1 搭建 Stable Diffusion XL 推理服务（ComfyUI 或 diffusers）
- [x] 18.2 集成 IP-Adapter (FaceID) 实现面部一致性保持
- [x] 18.3 集成 ControlNet (OpenPose) 实现姿势保持
- [x] 18.4 实现历史人物角色 Prompt 库（皇帝/文臣/武将/宫女/太监等角色的服装和场景描述）
- [x] 18.5 实现照片上传预处理（人脸检测、质量校验）
- [x] 18.6 实现异步处理队列（Redis Queue + Worker）
- [x] 18.7 实现 WebSocket 进度推送
- [x] 18.8 实现生成结果存储到 MinIO/OSS
- [x] 18.9 实现 API 端点：POST /api/v1/image/generate, GET /api/v1/image/{task_id}/status

## 19. 动态行程规划 Agent

- [x] 19.1 实现行程规划 Agent（TripPlanningAgent），基于 LangGraph 状态图
- [x] 19.2 实现预算动态分配算法
- [x] 19.3 实现酒店推荐模块（对接携程/美团 API 或自有数据）
- [x] 19.4 实现门票推荐模块
- [x] 19.5 实现行程对话接口（自然语言修改行程）
- [x] 19.6 实现实时调整逻辑（增删景点、修改预算后重新规划）
- [x] 19.7 实现天气联动（检测到恶劣天气自动建议室内替代方案）
- [x] 19.8 实现 API 端点：POST /api/v1/trips/plan, PUT /api/v1/trips/{id}/adjust

## 20. 行程总结生成

- [x] 20.1 实现足迹页面数据汇总逻辑（地点、照片、时间线、统计）
- [x] 20.2 实现古典风格足迹页面模板渲染
- [x] 20.3 实现视频生成管线（照片剪辑 + 转场动画 + 音乐 + 文字）
- [x] 20.4 实现古典游记风格文字生成（LLM Prompt）
- [x] 20.5 实现视频滤镜（水墨风/工笔画风等）
- [x] 20.6 实现异步视频生成 + WebSocket 进度推送
- [x] 20.7 实现社交分享功能（微信/微博分享卡片生成）
- [x] 20.8 实现 API 端点：POST /api/v1/summary/generate, GET /api/v1/summary/{id}

## 21. 后端基础设施

- [x] 21.1 实现 API Key 认证中间件
- [x] 21.2 实现请求限流（Redis 令牌桶）
- [x] 21.3 配置日志和监控（结构化日志 + Prometheus 指标）
- [x] 21.4 编写 Dockerfile（API 服务 + AI Worker 分别构建）
- [x] 21.5 配置 CI/CD 流水线

---

## 22. 测试与验证

- [x] 22.1 Flutter 数据层单元测试（DAO CRUD、种子数据导入、匹配算法）
- [x] 22.2 后端 API 单元测试（Agent 逻辑、围栏判定、撮合推荐）
- [x] 22.3 `flutter analyze` 无错误
- [x] 22.4 后端 pytest 全部通过
- [x] 22.5 模拟器端到端验证：启动→首页→地图→标记→搜索→浏览
- [x] 22.6 后端 API 端到端验证：路线生成→行程规划→AI 换装→总结生成
