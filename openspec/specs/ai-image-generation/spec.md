## ADDED Requirements

### Requirement: 用户照片上传与预处理
系统 SHALL 接受用户上传的旅行照片（JPEG/PNG，最大 10MB），进行人脸检测和质量校验后进入 AI 处理队列。

#### Scenario: 上传合格照片
- **WHEN** 用户上传一张清晰正面照（含可识别人脸）
- **THEN** 照片通过校验，进入 AI 处理队列，返回 task_id

#### Scenario: 上传不合格照片
- **WHEN** 用户上传的照片无人脸或模糊
- **THEN** 返回错误提示"照片未检测到清晰人脸，请重新拍摄"

### Requirement: 历史人物角色选择
系统 SHALL 提供历史人物角色列表供用户选择，每个角色包含：朝代、身份、服装样式参考图、场景参考图。用户上传照片后 SHALL 以选定角色的风格进行换装。

#### Scenario: 选择乾隆皇帝角色
- **WHEN** 用户选择"乾隆皇帝"角色并上传照片
- **THEN** AI 将用户面部融合到乾隆皇帝的龙袍服饰中

#### Scenario: 选择汉代宫女角色
- **WHEN** 用户选择"汉代宫女"角色
- **THEN** AI 将用户面部融合到汉代曲裾深衣服饰中

### Requirement: AI 换装生成
系统 SHALL 使用 Stable Diffusion XL + IP-Adapter (FaceID) + ControlNet (OpenPose) 实现 AI 换装。SHALL 保持用户面部一致性、姿势不变，仅替换服装和背景。

#### Scenario: 换装成功
- **WHEN** AI 处理完成
- **THEN** 生成的图像保留用户面部特征、原始姿势，但服装和背景替换为历史场景

#### Scenario: 换装效果不满意
- **WHEN** 用户对生成结果不满意
- **THEN** 可点击"重新生成"（最多 3 次/张），使用不同的随机种子重新生成

### Requirement: 历史场景合成
系统 SHALL 根据用户当前所在的历史地点，将换装后的图像合成到对应的历史场景中。场景 SHALL 包含适当的陪侍人物（太监、宫女、侍卫等，根据角色身份匹配）。

#### Scenario: 在长安生成皇帝场景
- **WHEN** 用户选择"皇帝"角色并在长安
- **THEN** 生成图像包含：用户穿龙袍站在未央宫前，两侧有太监和宫女侍立

#### Scenario: 在洛阳生成文人场景
- **WHEN** 用户选择"东汉文人"角色并在洛阳
- **THEN** 生成图像包含：用户着汉代文人服饰在洛阳太学，有书童陪伴

### Requirement: 异步处理与进度通知
AI 换装 SHALL 为异步处理，单次生成时间约 5-15 秒。系统 SHALL 通过 WebSocket 推送处理进度（排队中→处理中→完成）。

#### Scenario: 处理进度推送
- **WHEN** 用户提交换装请求
- **THEN** WebSocket 推送：{"status": "queued", "position": 3} → {"status": "processing", "progress": 50} → {"status": "completed", "image_url": "..."}

### Requirement: 生成结果管理
系统 SHALL 保存所有生成的图像到对象存储，用户可在"我的历史影像"中查看和下载。每张图 SHALL 记录：生成时间、原始照片、角色、地点、prompt。

#### Scenario: 查看历史生成记录
- **WHEN** 用户打开"我的历史影像"
- **THEN** 按时间倒序展示所有 AI 生成图像，支持按朝代/地点筛选
