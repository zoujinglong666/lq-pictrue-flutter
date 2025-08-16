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

class _SimpleWebViewState extends State<SimpleWebView> {
  late InAppWebViewController _controller;
  bool _isLoading = true;

  bool _isFullscreen = false;

  // 初始化
  String _innerTitle = ''; // 先空着，不显示 URL
// 内存缓存：{url: title}
  static final Map<String, String> _titleCache = {};
  @override
  void initState() {
    super.initState();
    // 可选：先显示 widget.title，避免空白
    @override
    void initState() {
      super.initState();
      // 1. 先尝试缓存
      _innerTitle = _titleCache[widget.url] ?? widget.title;
    }
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
        appBar:
            _isFullscreen
                ? null
                : AppBar(
                  title: Text(
                    _innerTitle,
                    style: const TextStyle(color: Colors.black),
                  ),
                  centerTitle: true,
                  // 标题居中
                  backgroundColor: Colors.white,
                  iconTheme: const IconThemeData(color: Colors.black),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () async {
                      if (await _controller.canGoBack()) {
                        await _controller.goBack();
                      } else {
                        if (mounted) Navigator.of(context).pop();
                      }
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.black),
                      onPressed: () => _controller.reload(),
                    ),
                  ],
                ),
        body: Stack(
          children: [
            _buildWebView(),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
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

  // Widget _buildWebView() {
  //   final webView = InAppWebView(
  //     initialUrlRequest: URLRequest(url: WebUri(widget.url)),
  //     initialSettings: InAppWebViewSettings(
  //       sharedCookiesEnabled: true,
  //       cacheEnabled: widget.enableCache,
  //       domStorageEnabled: true,
  //       databaseEnabled: true,
  //       cacheMode: CacheMode.LOAD_DEFAULT,
  //
  //       // cacheMode: widget.enableCache
  //       //     ? CacheMode.LOAD_CACHE_ELSE_NETWORK
  //       //     : CacheMode.LOAD_DEFAULT,
  //       allowsInlineMediaPlayback: !widget.allowFullscreenVideo,
  //     ),
  //     initialUserScripts:
  //         widget.initialCookies == null
  //             ? UnmodifiableListView([])
  //             : UnmodifiableListView(
  //               widget.initialCookies!.map(
  //                 (cookie) => UserScript(
  //                   source:
  //                       'document.cookie="${cookie.name}=${cookie.value}; path=${cookie.path ?? "/"}; domain=${cookie.domain}";',
  //                   injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
  //                 ),
  //               ),
  //             ),
  //     onWebViewCreated: (controller) {
  //       _controller = controller;
  //       widget.jsHandlers?.forEach(
  //         (handlerName, callback) => controller.addJavaScriptHandler(
  //           handlerName: handlerName,
  //           callback: (args) => callback(args),
  //         ),
  //       );
  //     },
  //     onLoadStart: (_, __) => setState(() => _isLoading = true),
  //     onLoadStop: (_, __) => setState(() => _isLoading = false),
  //     onReceivedError: (_, __, error) {
  //       setState(() => _isLoading = false);
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('加载失败：${error.description}')));
  //     },
  //     /* 全屏监听（仅一个参数） */
  //     onEnterFullscreen: (_) => setState(() => _isFullscreen = true),
  //     onExitFullscreen: (_) => setState(() => _isFullscreen = false),
  //     onPermissionRequest:
  //         (controller, request) async => PermissionResponse(
  //           resources: request.resources,
  //           action: PermissionResponseAction.GRANT,
  //         ),
  //   );
  //
  //   return widget.enablePullToRefresh
  //       ? RefreshIndicator(onRefresh: _onRefresh, child: webView)
  //       : webView;
  // }

  Widget _buildWebView() {
    final webView = InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
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
        // 只负责 loading，不改标题
        if (mounted) setState(() => _isLoading = true);
      },
      onLoadError: (_, __, ___, ____) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('加载失败')));
          });
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
              _isLoading = false;
            });
          }
        },
      onReceivedError: (_, __, ___) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
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
