# 搜索功能优化说明

## 📋 优化概述

将原本需要跳转页面的搜索功能优化为更流畅的交互体验,并对接了真实的后端API接口。

## ✨ 主要改进

### 1. **首页搜索优化** (`home_page.dart`)

#### 新增功能:
- ✅ **直接搜索** - 在首页搜索框直接输入并搜索,无需跳转
- ✅ **实时筛选** - 支持分类筛选和排序选择
- ✅ **清空搜索** - 一键清空搜索条件和结果
- ✅ **筛选面板** - 可折叠的筛选器,不占用过多空间
- ✅ **API对接** - 完整对接 `PictureApi.getList` 接口

#### 新增状态变量:
```dart
final TextEditingController _searchController = TextEditingController();
final FocusNode _searchFocusNode = FocusNode();

// 动画控制器
late AnimationController _filterAnimationController;
late Animation<double> _filterAnimation;

String _searchKeyword = '';
String _selectedCategory = '全部';
String _selectedSort = '最新';
List<String> _selectedTags = []; // 多选标签
bool _showFilters = false;
```

#### 核心方法:
- `_buildRequestParams(int page)` - 构建API请求参数(包含搜索、分类、排序、标签)
- `_performSearch(String keyword)` - 执行搜索
- `_applyFilters()` - 应用筛选条件
- `_resetFilters()` - 重置筛选条件到默认值
- `_clearSearch()` - 清空搜索和筛选

#### 筛选选项:
- **分类**: 全部、模板、电商、表情包、素材、海报 (与后端定义一致)
- **排序**: 最新(按创建时间)、热门(按点赞数)
- **标签**: 热门、搞笑、生活、高清、艺术、校园、背景、简历、创意 (支持多选)
- **重置按钮**: 一键重置所有筛选条件到默认值

### 2. **搜索页面重构** (`search_page.dart`)

#### 功能调整:
- ✅ **保留为高级搜索入口** - 用户仍可点击导航进入
- ✅ **真实API对接** - 使用 `PictureApi.getList` 获取搜索结果
- ✅ **瀑布流展示** - 搜索结果以瀑布流形式展示
- ✅ **分页加载** - 支持上拉加载更多
- ✅ **自动聚焦** - 打开页面自动聚焦搜索框
- ✅ **搜索建议** - 未搜索时显示热门标签和搜索提示

#### 核心功能:
```dart
// 执行搜索(支持分页)
Future<void> _performSearch({bool loadMore = false})

// 重置筛选条件
void _resetFilters()

// 构建搜索结果展示
Widget _buildSearchResults()

// 显示搜索建议
Widget _buildSearchSuggestions()
```

#### 搜索参数:
```dart
{
  'current': page,
  'pageSize': 20,
  'searchText': keyword,         // 搜索关键词
  'sortField': 'createTime/likeCount',  // 排序字段
  'sortOrder': 'descend',
  'category': category,          // 分类筛选(可选)
}
```

## 🎯 交互流程

### 首页搜索流程:
1. 用户在首页搜索框输入关键词
2. 按回车或搜索按钮执行搜索
3. 页面直接刷新显示搜索结果
4. 可点击筛选按钮调整分类和排序
5. 点击清除按钮恢复默认列表

### 高级搜索流程:
1. 用户从底部导航或其他入口进入搜索页
2. 自动聚焦搜索框,可查看热门标签
3. 输入关键词并搜索
4. 瀑布流展示结果,支持加载更多
5. 可使用筛选器精确搜索

## 📊 API接口说明

### 使用接口:
```dart
PictureApi.getList(Map<String, dynamic> params)
```

### 请求参数:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| current | int | 是 | 当前页码 |
| pageSize | int | 是 | 每页数量 |
| searchText | String | 否 | 搜索关键词 |
| category | String | 否 | 分类筛选 |
| tags | List<String> | 否 | 标签筛选(多选) |
| sortField | String | 否 | 排序字段(createTime/likeCount) |
| sortOrder | String | 否 | 排序方式(descend/ascend) |

### 返回数据:
```dart
Page<PictureVO> {
  records: List<PictureVO>,  // 图片列表
  current: int,              // 当前页
  total: int,                // 总记录数
  pages: int                 // 总页数
}
```

## 🎨 UI/UX改进

### 首页搜索框:
- 可直接输入文字
- 有清除按钮(输入内容时显示)
- 有筛选按钮(切换筛选面板)
- 支持回车搜索

### 筛选面板:
- 可折叠设计,节省空间
- **动画效果**: SizeTransition(高度) + FadeTransition(透明度)
- **动画时长**: 300ms, easeInOut 曲线
- 芯片式选择器,交互友好
- 选中状态有明显视觉反馈
- 标签支持多选,小尺寸圆角芯片样式
- 左侧"重置"按钮,右侧"应用筛选"按钮
- 重置按钮带刷新图标,更直观

### 搜索结果:
- 与首页列表样式一致
- 支持下拉刷新
- 支持滚动加载更多
- 空状态提示友好

## 🔧 技术要点

1. **状态管理** - 使用 `setState` 管理搜索状态
2. **键盘控制** - 使用 `FocusNode` 控制键盘显示/隐藏
3. **滚动监听** - 实现无限滚动加载
4. **参数构建** - 动态构建API请求参数
5. **错误处理** - 搜索失败时显示提示

## 📝 使用示例

### 首页搜索:
```dart
// 用户输入"风景"并回车
_performSearch("风景")

// API调用:
PictureApi.getList({
  "current": 1,
  "pageSize": 10,
  "searchText": "风景",
  "sortField": "createTime",
  "sortOrder": "descend",
})
```

### 筛选搜索:
```dart
// 用户选择"电商"分类 + "热门"排序
_selectedCategory = "电商"
_selectedSort = "热门"
_applyFilters()

// API调用:
PictureApi.getList({
  "current": 1,
  "pageSize": 10,
  "category": "电商",
  "sortField": "likeCount",
  "sortOrder": "descend",
})
```

## 🚀 后续优化建议

1. **搜索历史** - 保存用户搜索记录到本地存储
2. **搜索联想** - 实现输入时的关键词联想
3. **高亮关键词** - 在搜索结果中高亮显示搜索词
4. **语音搜索** - 集成语音输入功能
5. **搜索统计** - 记录热门搜索词
6. **标签搜索** - 支持按标签筛选(tags字段)
7. **高级筛选** - 支持尺寸、格式等更多维度筛选

## ⚠️ 注意事项

1. 确保后端API支持 `searchText` 参数
2. 分类值需与后端定义保持一致
3. 搜索关键词会自动 trim 去除首尾空格
4. 清空搜索会重置所有筛选条件
5. 页面销毁时会自动清理资源(Controller、FocusNode等)

## 📋 更新日志

### v1.2 (最新)
- ✅ 添加标签(tags)筛选功能
- ✅ 支持多标签同时选择
- ✅ 筛选面板展开/收起动画
- ✅ SizeTransition + FadeTransition 组合动画
- ✅ 标签样式更精致(小尺寸芯片)

### v1.1
- ✅ 添加筛选条件重置按钮
- ✅ 优化按钮布局(重置 + 应用筛选)
- ✅ 统一分类数据与后端定义
- ✅ 重置按钮添加刷新图标

### v1.0
- ✅ 首页集成即时搜索功能
- ✅ 实现无跳转式搜索交互
- ✅ 添加分类与排序联合筛选
- ✅ 搜索页面作为高级入口保留
- ✅ 对接后端分页搜索接口

## 🎉 总结

本次优化大幅提升了搜索功能的用户体验:
- ✅ 无需跳转页面,交互更流畅
- ✅ 对接真实API,数据真实可用
- ✅ 支持多维度筛选(分类+排序+标签)
- ✅ 标签支持多选,组合筛选更灵活
- ✅ 筛选面板动画流畅,体验优雅
- ✅ 保留高级搜索入口,功能完整
- ✅ 代码结构清晰,易于维护

### 动画效果详情:
```dart
// 动画控制器初始化
_filterAnimationController = AnimationController(
  duration: const Duration(milliseconds: 300),
  vsync: this,
);
_filterAnimation = CurvedAnimation(
  parent: _filterAnimationController,
  curve: Curves.easeInOut,
);

// 筛选面板带动画
SizeTransition(
  sizeFactor: _filterAnimation,
  axisAlignment: -1.0,
  child: FadeTransition(
    opacity: _filterAnimation,
    child: Container(...),
  ),
)
```

### 筛选示例:
```dart
// 组合筛选: 搜索 + 分类 + 排序 + 标签
PictureApi.getList({
  "searchText": "人像",
  "category": "模板",
  "sortField": "likeCount",
  "tags": ["高清", "艺术"],
})
```
