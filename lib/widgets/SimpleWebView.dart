import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SimpleWebView extends StatefulWidget {
  final String url;
  final String title;
  final bool enablePullToRefresh;
  final Map<String, Function(dynamic)>? jsHandlers;
  final List<Cookie>? initialCookies;
  final bool enableCache;
  final bool allowFullscreenVideo;

  const SimpleWebView({
    super.key,
    required this.url,
    required this.title,
    this.enablePullToRefresh = false,
    this.jsHandlers,
    this.initialCookies,
    this.enableCache = false,
    this.allowFullscreenVideo = false,
  });

  @override
  State<SimpleWebView> createState() => _SimpleWebViewState();
}

class _SimpleWebViewState extends State<SimpleWebView>
    with TickerProviderStateMixin {
  late InAppWebViewController _controller;
  double _loadingProgress = 0.0;
  bool _isLoading = true;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  bool _isFullscreen = false;

  // 初始化
  String _innerTitle = ''; // 先空着，不显示 URL
  // 内存缓存：{url: title}
  static final Map<String, String> _titleCache = {};
  
  @override
  void initState() {
    super.initState();
    // 先尝试缓存，如果没有则使用传入的title
    _innerTitle = _titleCache[widget.url] ?? widget.title;
    
    // 初始化进度条动画控制器
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() => _controller.reload();

  /// 判断字符串是否以 http/https/ftp/file 等协议开头
  /// 判断字符串是不是「看起来」像网址（域名/IP + 可选端口）
  // bool _isUrl(String? text) {
  //   if (text == null || text.trim().isEmpty) return true;
  //   final str = text.trim();
  //   // 1. 以 http/https 开头
  //   if (str.startsWith(RegExp(r'^https?://', caseSensitive: false))) return true;
  //   // 2. 形如 10.9.17.62:3000 或 10.9.17.62:3000/#/about
  //   if (RegExp(r'^\d{1,3}(?:\.\d{1,3}){3}(?::\d+)?(?:/.*)?$', caseSensitive: false)
  //       .hasMatch(str)) {
  //     return true;
  //   }
  //   // 3. 形如 localhost:3000
  //   if (RegExp(r'^localhost(?::\d+)?(?:/.*)?$', caseSensitive: false)
  //       .hasMatch(str)) {
  //     return true;
  //   }
  //   return false;
  // }

  bool _isUrl(String? text) {
    if (text == null || text.trim().isEmpty) return false;
    final str = text.trim();

    // 1. 以 http/https 开头
    if (_httpPrefix.hasMatch(str)) return true;

    // 2. IPv4 地址（宽松匹配，但避免明显非法）
    if (_ipv4Pattern.hasMatch(str)) return true;

    // 3. localhost + 可选端口和路径
    if (_localhostPattern.hasMatch(str)) return true;

    // 4. 普通域名（包含点号，可选端口）
    if (_domainPattern.hasMatch(str)) return true;

    return false;
  }

// 缓存正则表达式，提升性能
  final _httpPrefix = RegExp(r'^https?://', caseSensitive: false);

  final _ipv4Pattern = RegExp(
      r'^\d{1,3}(?:\.\d{1,3}){3}(?::\d+)?(?:/.*)?$',
      caseSensitive: false
  );

  final _localhostPattern = RegExp(
      r'^localhost(?::\d+)?(?:/.*)?$',
      caseSensitive: false
  );

  final _domainPattern = RegExp(
      r'^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*(:\d+)?(?:/.*)?$',
      caseSensitive: false
  );

  /* ⬇ 新增：是否可以后退 */
  Future<bool> _onWillPop() async {
    final canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      await _controller.goBack();
      return false; // 拦截系统返回
    }
    return true; // 退出本页面
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _isFullscreen
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey[800],
                  ),
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      await _controller.goBack();
                    } else {
                      if (mounted) Navigator.of(context).pop();
                    }
                  },
                ),
                title: Text(
                  _innerTitle,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.grey[800],
                    ),
                    onPressed: () => _controller.reload(),
                  ),
                ],
              ),
        body: Column(
          children: [
            // 进度条
            if (_isLoading)
              Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[100]!,
                      Colors.grey[200]!,
                    ],
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // 背景
                        Container(
                          width: double.infinity,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                        // 进度条
                        FractionallySizedBox(
                          widthFactor: _loadingProgress,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4FC3F7),
                                  Color(0xFF29B6F6),
                                  Color(0xFF03A9F4),
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4FC3F7).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(1.5),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            // WebView
            Expanded(
              child: _buildWebView(),
            ),
          ],
        ),
      ),
    );
  }

  // 在 onWebViewCreated 里把 controller 存下来
  late InAppWebViewController controller;

  // 需要刷新时调用
  Future<void> _forceRefresh() async {
    // 1. 清掉 WebView 的内存+磁盘缓存
    await InAppWebViewController.clearAllCache();
    // 2. 清 Cookie（可选，如果你的页面受 Cookie 影响）
    await CookieManager.instance().deleteAllCookies();
    // 3. 重新加载
    await _controller.reload();

    await _controller.clearCache(); // 清内存缓存
    await _controller.clearSslPreferences(); // 清证书缓存
  }



  Widget _buildWebView() {
    final webView = InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url;
        if (uri != null) {
          final scheme = uri.scheme.toLowerCase();
          
          // 百度系 scheme
          if (scheme == 'bdapp' || 
              scheme == 'baiduboxapp' || 
              scheme == 'baidumap' ||
              scheme == 'bdnetdisk' ||
              scheme == 'baiduyun' ||
              scheme == 'baidutieba' ||
              scheme == 'baidupan' ||
              scheme.startsWith('baidu')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 腾讯系 scheme
          if (scheme == 'weixin' ||
              scheme == 'wechat' ||
              scheme == 'mqq' ||
              scheme == 'mqqapi' ||
              scheme == 'tim' ||
              scheme == 'qqmusic' ||
              scheme == 'tencentvideo' ||
              scheme == 'qqlive' ||
              scheme == 'tencent' ||
              scheme.startsWith('tencent')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 阿里系 scheme
          if (scheme == 'alipay' ||
              scheme == 'alipays' ||
              scheme == 'taobao' ||
              scheme == 'tmall' ||
              scheme == 'dingtalk' ||
              scheme == 'alipayhk' ||
              scheme == 'alipayqr' ||
              scheme == 'youku' ||
              scheme == 'uc' ||
              scheme == 'ucbrowser' ||
              scheme.startsWith('ali')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 字节跳动系 scheme
          if (scheme == 'snssdk1128' ||  // 抖音
              scheme == 'snssdk1233' ||  // 今日头条
              scheme == 'awemesso' ||    // 抖音
              scheme == 'toutiao' ||
              scheme == 'douyin' ||
              scheme == 'xigua' ||       // 西瓜视频
              scheme == 'feishu' ||      // 飞书
              scheme.startsWith('bytedance')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 美团系 scheme
          if (scheme == 'imeituan' ||
              scheme == 'dianping' ||
              scheme == 'meituan' ||
              scheme == 'meituanwaimai' ||
              scheme.startsWith('meituan')) {
            return NavigationActionPolicy.ALLOW;
          }
          // 滴滴系 scheme
          if (scheme == 'diditaxi' ||
              scheme == 'didi' ||
              scheme == 'didichuxing' ||
              scheme.startsWith('didi')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 京东系 scheme
          if (scheme == 'openapp.jdmobile' ||
              scheme == 'jdmobile' ||
              scheme == 'jd' ||
              scheme == 'jingdong' ||
              scheme.startsWith('jd')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 网易系 scheme
          if (scheme == 'newsapp' ||     // 网易新闻
              scheme == 'cloudmusic' ||  // 网易云音乐
              scheme == 'netease' ||
              scheme == 'yanxuan' ||     // 网易严选
              scheme.startsWith('netease')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 新浪系 scheme
          if (scheme == 'sinaweibo' ||
              scheme == 'weibo' ||
              scheme == 'sina' ||
              scheme.startsWith('sina')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 小米系 scheme
          if (scheme == 'mimarket' ||
              scheme == 'xiaomi' ||
              scheme == 'miui' ||
              scheme.startsWith('xiaomi')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 华为系 scheme
          if (scheme == 'hwbrowser' ||
              scheme == 'huawei' ||
              scheme == 'hicloud' ||
              scheme.startsWith('huawei')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // OPPO/VIVO 系 scheme
          if (scheme == 'oppo' ||
              scheme == 'vivo' ||
              scheme.startsWith('oppo') ||
              scheme.startsWith('vivo')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 快手系 scheme
          if (scheme == 'kwai' ||
              scheme == 'kuaishou' ||
              scheme.startsWith('kwai')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // B站系 scheme
          if (scheme == 'bilibili' ||
              scheme == 'bili' ||
              scheme.startsWith('bilibili')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 拼多多系 scheme
          if (scheme == 'pinduoduo' ||
              scheme == 'pdd' ||
              scheme.startsWith('pinduoduo')) {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 系统级 scheme
          if (scheme == 'tel' || 
              scheme == 'mailto' || 
              scheme == 'sms' ||
              scheme == 'http' ||
              scheme == 'https' ||
              scheme == 'ftp' ||
              scheme == 'file') {
            return NavigationActionPolicy.ALLOW;
          }
          
          // 其他常见 scheme
          if (scheme == 'market' ||      // 应用商店
              scheme == 'intent' ||      // Android Intent
              scheme == 'itms-apps' ||   // iOS App Store
              scheme == 'itms-services') { // iOS 企业应用
            return NavigationActionPolicy.ALLOW;
          }
        }
        return NavigationActionPolicy.ALLOW;
      },
      initialSettings: InAppWebViewSettings(
        /* ---------- 核心性能开关 ---------- */
        // 1. GPU 加速：保持默认 true，除非调试
        hardwareAcceleration: true,
        // 2. 关闭默认的过度滚动（减少 GPU 负荷）
        disallowOverScroll: true,
        // 3. 关闭弹性回弹（iOS）
        alwaysBounceVertical: false,
        alwaysBounceHorizontal: false,
        // 4. 禁止缩放控制条出现（减少重绘）
        builtInZoomControls: false,
        displayZoomControls: false,
        supportZoom: false,
        // 5. 滚动条淡入淡出时长缩短
        scrollBarFadeDuration: 0,
        scrollbarFadingEnabled: true,
        // 6. 图片自动加载（按需开启）
        loadsImagesAutomatically: true,
        // 如果页面必须图片，请注释掉
        // 7. 关闭/减少 JS 注入事件监听（没用到就关）
        useShouldInterceptRequest: false,
        useShouldInterceptAjaxRequest: false,
        useShouldInterceptFetchRequest: false,
        useOnLoadResource: false,
        useOnNavigationResponse: false,
        // 8. 关闭 WebView 调试端口（Release 包）
        isInspectable: false,
        // 9. 关闭长链接预览、链接长按菜单
        allowsLinkPreview: false,
        disableLongPressContextMenuOnLinks: true,
        // 10. 关闭键盘顶部附件视图（减少一次布局）
        disableInputAccessoryView: true,
        // 11. 关闭键盘滚动到顶部手势（减少计算）
        scrollsToTop: false,
        // 12. 关闭 Apple Pay 等额外能力
        applePayAPIEnabled: false,
        // 13. 关闭 PIP、AirPlay 等额外媒体能力
        allowsPictureInPictureMediaPlayback: false,
        allowsAirPlayForMediaPlayback: false,
        // 14. 关闭 Fraud 检测（国内不需要）
        isFraudulentWebsiteWarningEnabled: false,
        // 15. 关闭 DOM 存储 / 数据库（如果页面不依赖）
        domStorageEnabled: true,
        databaseEnabled: true,
        /* ---------- 缓存/离线 ---------- */
        cacheEnabled: widget.enableCache,
        cacheMode:
            widget.enableCache
                ? CacheMode.LOAD_NO_CACHE
                : CacheMode.LOAD_NO_CACHE,
        // 16. Android 10+ 推荐：使用混合合成（性能更好）
        useHybridComposition: true,
        /* ---------- 其余保持你的原配置 ---------- */
        sharedCookiesEnabled: true,
        allowsInlineMediaPlayback: !widget.allowFullscreenVideo,
        javaScriptEnabled: true,
        geolocationEnabled: false,
      ),
      /* 其余 callbacks 不变 */
      onWebViewCreated: (c) => _controller = c,
      onLoadStart: (_, __) {
        if (mounted) {
          setState(() {
            _isLoading = true;
            _loadingProgress = 0.1; // 开始时显示一点进度
          });
          _progressController.forward();
        }
      },
      onProgressChanged: (controller, progress) {
        if (mounted) {
          setState(() {
            _loadingProgress = progress / 100.0;
          });
        }
      },
      onLoadError: (_, __, ___, ____) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadingProgress = 0.0;
          });
          _progressController.reset();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('加载失败')),
          );
        }
      },
      onLoadStop: (controller, url) async {
        String? raw = await controller.getTitle();

        // 智能过滤：空 / 纯 URL / 纯域名
        String validTitle = _isUrl(raw) || (raw?.trim().isEmpty ?? true)
            ? widget.title
            : raw!.trim();

        // 缓存
        if (url != null) {
          _titleCache[url.toString()] = validTitle;
        }

        if (mounted) {
          setState(() {
            _innerTitle = validTitle;
            _loadingProgress = 1.0; // 完成时设为100%
          });
          
          // 延迟隐藏进度条，让用户看到100%的效果
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              _progressController.reset();
            }
          });
        }
      },
      onReceivedError: (_, __, ___) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadingProgress = 0.0;
          });
          _progressController.reset();
        }
      },

      onEnterFullscreen: (_) => setState(() => _isFullscreen = true),
      onExitFullscreen: (_) => setState(() => _isFullscreen = false),
      onPermissionRequest:
          (c, r) async => PermissionResponse(
            resources: r.resources,
            action: PermissionResponseAction.GRANT,
          ),
    );

    return widget.enablePullToRefresh
        ? RefreshIndicator(onRefresh: _onRefresh, child: webView)
        : webView;
  }
}
