## 1. 数据层扩展

- [x] 1.1 创建 HistoricalFigure 实体类（id, dynastyId, name, alias, title, birthYear, deathYear, description, biography）
- [x] 1.2 创建 FigureLocationRelation 实体类（id, figureId, locationId, relationType, description）
- [x] 1.3 创建 TravelRoute 实体类（id, dynastyId, name, description, figureId, coverStory, difficulty, estimatedDays, isCustom, createdAt）
- [x] 1.4 创建 RouteStop 实体类（id, routeId, orderIndex, locationId, modernLocationId, title, description, arrivalStory, stayDuration）
- [x] 1.5 创建 HistoryCard 实体类（id, dynastyId, title, content, figureId, locationId, dateHint, category）
- [x] 1.6 创建 UserFavorite 实体类（id, locationId, dynastyId, createdAt）
- [x] 1.7 创建 BrowseHistory 实体类（id, locationId, dynastyId, visitedAt）
- [x] 1.8 扩展 SQLite schema：新增 historical_figures、figure_location_relations、travel_routes、route_stops、history_cards、user_favorites、browse_history 共 7 张表及索引
- [x] 1.9 创建 HistoricalFigureDao（CRUD + 按朝代查询 + 按地点查询关联）
- [x] 1.10 创建 TravelRouteDao（CRUD + 按朝代查询 + 路线站点级联查询）
- [x] 1.11 创建 HistoryCardDao（CRUD + 按朝代查询 + 按类别查询）
- [x] 1.12 创建 UserFavoriteDao（添加/删除收藏 + 按朝代查询列表 + 是否已收藏判断）
- [x] 1.13 创建 BrowseHistoryDao（upsert + 按时间倒序查询 + 清除全部）
- [x] 1.14 扩展 AncientLocationDao：新增按 modernLocationId 跨朝代查询方法（支持历史变迁对比）

## 2. 种子数据

- [x] 2.1 创建 assets/data/han_historical_figures.json：至少 30 位汉代人物 + 人物-地点关联数据
- [x] 2.2 创建 assets/data/han_travel_routes.json：至少 5 条经典路线（张骞出使西域、丝绸之路、刘邦入关、汉武帝巡游、司马迁游历）+ 路线站点
- [x] 2.3 创建 assets/data/history_cards.json：至少 60 条汉代知识卡片（事件/人物/文化/地理四类）
- [x] 2.4 创建 assets/data/tang_dynasty_locations.json：唐朝朝代信息 + 至少 30 个核心地名数据
- [x] 2.5 创建 assets/data/song_dynasty_locations.json：宋朝朝代信息 + 至少 30 个核心地名数据
- [x] 2.6 重构 DataSeeder：支持多朝代数据文件导入 + 新表种子数据导入 + 按朝代独立版本管理

## 3. 朝代切换框架

- [x] 3.1 修改 currentDynastyIdProvider：从硬编码改为 StateProvider<int>，支持运行时切换
- [x] 3.2 创建 allDynastiesProvider：查询数据库中所有可用朝代列表
- [x] 3.3 验证所有现有 provider（locationsByDynastyProvider、mapStateProvider 等）正确依赖 currentDynastyIdProvider 并自动刷新
- [x] 3.4 创建 DynastySwitcher 首页组件：点击朝代徽章弹出朝代选择面板（底部弹窗）
- [x] 3.5 创建 DynastySelectorSheet 组件：展示所有朝代卡片列表，当前朝代高亮，点击切换并关闭面板
- [x] 3.6 修改首页：朝代徽章改为可点击，接入 DynastySwitcher

## 4. 历史人物功能

- [x] 4.1 创建 HistoricalFigureRepository：封装人物 DAO 查询（按朝代、按地点关联、按类别分组）
- [x] 4.2 创建 Riverpod providers：figuresByDynastyProvider、figuresByLocationProvider、figureDetailProvider
- [x] 4.3 创建 FigureCard 组件（古典风格：头像占位 + 姓名 + 头衔 + 简介）
- [x] 4.4 创建 FiguresListPage：按类别分组展示人物列表（帝王/文臣/武将/学者）
- [x] 4.5 创建 FigureDetailPage：人物详情页（姓名、别名、头衔、生卒年、简介、关联地点列表）
- [x] 4.6 添加路由：/figures（人物列表）、/figures/:id（人物详情）
- [x] 4.7 修改首页：新增"历史名人"功能入口卡片
- [x] 4.8 修改 LocationBottomSheet：新增关联人物板块（显示地点相关人物卡片列表）
- [x] 4.9 创建 LocationDetailPage：完整地点详情页（古今对照 + 人物 + 事件时间线 + 收藏/分享）

## 5. 旅游路线功能

- [x] 5.1 创建 TravelRouteRepository：封装路线和站点 DAO 查询
- [x] 5.2 创建 Riverpod providers：routesByDynastyProvider、routeDetailProvider、routeStopsProvider
- [x] 5.3 创建 RouteCard 组件（路线名称 + 人物标签 + 难度 + 天数 + 起点→终点）
- [x] 5.4 创建 RoutesListPage：路线浏览页面，支持"全部"和"已收藏"标签切换
- [x] 5.5 创建 RouteDetailPage：路线详情页（路线地图 + 站点列表 + 路线故事 + 人物信息）
- [x] 5.6 实现路线地图轨迹渲染：金色虚线连接站点 + 编号圆形标记
- [x] 5.7 实现路线站点点击交互：弹出站点详情（古地名 + 现代地名 + 历史故事）
- [x] 5.8 实现自定义路线创建：从收藏/搜索选择地点 + 拖拽排序 + 保存
- [x] 5.9 添加路由：/routes（路线列表）、/routes/:id（路线详情）、/routes/create（创建路线）
- [x] 5.10 修改首页：新增"古人足迹"功能入口卡片

## 6. 地图交互增强

- [x] 6.1 实现古今地名双标注：扩展 MarkerFactory 支持双行标记（古地名 + 现代地名）
- [x] 6.2 添加双标注开关：地图工具栏"古今对照"Toggle 按钮
- [x] 6.3 优化标记动画：标记出现时添加淡入+缩放过渡效果
- [x] 6.4 扩展 LocationBottomSheet：新增历史变迁入口按钮
- [x] 6.5 实现历史变迁面板：展示同一现代位置在不同朝代的名称变化

## 7. 收藏与浏览历史

- [x] 7.1 创建 FavoriteRepository 和 HistoryRepository：封装 DAO 操作
- [x] 7.2 创建 Riverpod providers：favoritesProvider、browseHistoryProvider、isFavoriteProvider
- [x] 7.3 在地点详情页和 BottomSheet 添加收藏按钮（含缩放旋转微动画）
- [x] 7.4 创建 FavoritesPage：按朝代分组展示收藏列表
- [x] 7.5 创建 BrowseHistoryPage：按时间倒序展示浏览历史 + 清除按钮
- [x] 7.6 记录浏览历史：在查看地点详情时自动 upsert browse_history 记录
- [x] 7.7 添加路由：/favorites、/history
- [x] 7.8 修改首页：添加收藏和历史入口

## 8. 搜索增强与分享

- [x] 8.1 修改 SearchPage：添加行政级别筛选 chips（全部/州/郡/县）
- [x] 8.2 修改 SearchPage：添加排序选项（相关度/名称/行政级别）
- [x] 8.3 创建分享功能：RepaintBoundary 生成地点卡片图片（古地名 + 现代地名 + 朝代 + 古典边框）
- [x] 8.4 集成 share_plus：调用系统分享面板分享生成的图片
- [x] 8.5 在地点详情页添加分享按钮

## 9. 每日一史

- [x] 9.1 添加 flutter_local_notifications 依赖到 pubspec.yaml
- [x] 9.2 创建 DailyHistoryRepository：按日期循环查询知识卡片
- [x] 9.3 创建 Riverpod providers：todayCardProvider、historyCardsProvider
- [x] 9.4 创建 HistoryCardWidget 组件（宣纸色背景 + 类别标签 + 标题 + 简述）
- [x] 9.5 创建 DailyHistoryPage：今日推荐 + 历史卡片列表（已读/未读样式区分）
- [x] 9.6 实现本地通知调度：每日 9:00 推送（需请求权限，拒绝则仅 App 内展示）
- [x] 9.7 添加路由：/daily-history
- [x] 9.8 修改首页：添加"每日一史"入口

## 10. UI 组件与主题

- [x] 10.1 创建 RouteCard 组件（古典路线卡片：金色边框 + 路线信息）
- [x] 10.2 创建 FigureCard 组件（人物卡片：半透明古典风格 + 头像占位）
- [x] 10.3 创建 HistoryTimeline 组件（垂直时间线：轴线 + 圆形节点 + 事件卡片）
- [x] 10.4 创建 DynastySelectorSheet 样式（全屏底部弹窗 + 深色遮罩 + 鎏金高亮）
- [x] 10.5 创建 HistoryCardWidget 样式（宣纸色背景 + 类别色彩标签）
- [x] 10.6 实现收藏动画（ScaleTransition + RotationTransition，300ms）

## 11. 路由与导航

- [x] 11.1 扩展 AppRouter：新增 /figures、/figures/:id、/routes、/routes/:id、/routes/create、/daily-history、/favorites、/history 路由
- [x] 11.2 修改首页布局：从 3 个功能卡片扩展为 6 个（地图探索、层级浏览、搜索地名、历史名人、古人足迹、每日一史）+ 底部收藏/历史入口
- [x] 11.3 验证所有页面导航正确：首页→各功能页→详情页→地图页的完整导航链路

## 12. 集成验证

- [x] 12.1 全量构建验证：flutter analyze 无错误
- [x] 12.2 数据导入验证：首次启动正确导入所有种子数据（汉朝人物+路线+卡片、唐宋朝代数据）
- [x] 12.3 朝代切换验证：切换朝代后所有页面数据正确刷新
- [x] 12.4 核心流程验证：首页→人物列表→人物详情→关联地点→地图 完整流程
- [x] 12.5 路线流程验证：路线列表→路线详情→地图轨迹→站点点击 完整流程
- [x] 12.6 收藏/历史验证：收藏地点→查看收藏列表→浏览历史记录→清除历史
