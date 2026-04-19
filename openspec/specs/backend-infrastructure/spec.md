## ADDED Requirements

### Requirement: FastAPI 服务框架
系统 SHALL 使用 FastAPI 作为后端 Web 框架，提供 RESTful API 接口供 Flutter 客户端调用。所有 API SHALL 遵循 OpenAPI 3.0 规范，自动生成文档。

#### Scenario: API 文档自动生成
- **WHEN** 开发者访问 /docs 路径
- **THEN** 显示 Swagger UI 格式的完整 API 文档

#### Scenario: 健康检查
- **WHEN** 客户端调用 GET /health
- **THEN** 返回 {"status": "ok", "version": "1.0.0"}

### Requirement: LangChain Agent 编排
系统 SHALL 使用 LangChain + LangGraph 作为 AI Agent 编排框架。每个业务功能（路线规划、行程规划、图像生成等）SHALL 作为独立的 Agent 实现，通过统一的 Agent Hub 调度。

#### Scenario: Agent 路由分发
- **WHEN** 客户端发送 POST /api/v1/agents/route-plan 请求
- **THEN** Agent Hub 将请求路由到历史路线规划 Agent 处理

#### Scenario: Agent 状态管理
- **WHEN** 一个多步骤 Agent 任务执行中（如动态行程规划）
- **THEN** LangGraph 维护对话状态，支持暂停/恢复

### Requirement: PostgreSQL 数据库
系统 SHALL 使用 PostgreSQL 作为后端主数据库，存储完整的历史地理数据、用户数据、商家数据。SHALL 启用 PostGIS 扩展支持地理空间查询。

#### Scenario: 按地理范围查询历史地点
- **WHEN** 查询经纬度 34.26,108.93 半径 50km 内的汉代地点
- **THEN** 使用 PostGIS ST_DWithin 返回结果，包含距离排序

### Requirement: Redis 缓存与队列
系统 SHALL 使用 Redis 作为缓存层和任务队列。SHALL 使用 Redis GEO 存储历史地点坐标用于地理围栏判定，使用 Redis 作为 LangChain 对话记忆存储。

#### Scenario: 匹配结果缓存
- **WHEN** 同一古今地名匹配请求在 24 小时内重复到达
- **THEN** 直接从 Redis 缓存返回结果，不触发 LLM 调用

#### Scenario: 异步任务入队
- **WHEN** 用户提交 AI 换装请求
- **THEN** 任务写入 Redis 队列，返回 task_id，客户端通过 WebSocket 获取进度

### Requirement: LLM 多模型支持
系统 SHALL 通过 LangChain 抽象层支持多个 LLM 提供商（DeepSeek、Claude、通义千问），不同 Agent 可配置使用不同模型。

#### Scenario: 路线规划使用强推理模型
- **WHEN** 路线规划 Agent 需要复杂推理
- **THEN** 使用 DeepSeek/Claude 等强推理模型

#### Scenario: 简单匹配使用轻量模型
- **WHEN** 地名匹配 Agent 只需简单判断
- **THEN** 使用更轻量/便宜的模型

### Requirement: 对象存储集成
系统 SHALL 支持用户上传照片和生成 AI 图像/视频的存储，使用 MinIO（自建）或阿里云 OSS（云端），SHALL 支持 CDN 加速下载。

#### Scenario: 用户照片上传
- **WHEN** 用户上传一张旅行照片用于 AI 换装
- **THEN** 照片存储到对象存储，返回可访问的 URL

### Requirement: API 认证
系统 SHALL 提供 API Key 认证机制，客户端请求 MUST 携带有效的 API Key。后续 SHALL 支持 OAuth 2.0 用户认证。

#### Scenario: 无 API Key 请求被拒绝
- **WHEN** 客户端请求未携带 API Key
- **THEN** 返回 401 Unauthorized

#### Scenario: 有效 API Key 请求通过
- **WHEN** 客户端请求携带有效 API Key
- **THEN** 正常处理请求
