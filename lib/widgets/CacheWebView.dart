import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

class CacheWebView extends StatefulWidget {
  final String url;
  final String title;
  final bool enablePullToRefresh;

  const CacheWebView({
    super.key,
    required this.url,
    required this.title,
    this.enablePullToRefresh = false,
  });

  @override
  State<CacheWebView> createState() => _CacheWebViewState();
}

class _CacheWebViewState extends State<CacheWebView> {
  late InAppWebViewController _controller;
  bool _isLoading = true;
  bool _isFullscreen = false;
  String _innerTitle = '';
  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, WeakReference<String>> _titleCache = {};
  static final Map<String, String> _mimeTypeMap = {
    'html': 'text/html; charset=utf-8',
    'htm': 'text/html; charset=utf-8',
    'css': 'text/css; charset=utf-8',
    'js': 'application/javascript; charset=utf-8',
    'json': 'application/json; charset=utf-8',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'woff': 'font/woff',
    'woff2': 'font/woff2',
    'ttf': 'font/ttf',
    'otf': 'font/otf',
  };

  @override
  void initState() {
    super.initState();
    _innerTitle = _getTitleFromCache(widget.url) ?? widget.title;
  }

  String? _getTitleFromCache(String url) {
    final ref = _titleCache[url];
    return ref?.target;
  }

  Future<String> _getCacheDir() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/web_cache');
      if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
      return cacheDir.path;
    } catch (e) {
      print('获取缓存目录失败: $e');
      rethrow;
    }
  }

  String _getCacheFilename(String url) {
    final hash = url.hashCode.toRadixString(16); // 避免特殊字符
    return '$hash.cache';
  }

  Future<String> _getCacheFilePath(String url) async {
    final dir = await _getCacheDir();
    final filename = _getCacheFilename(url);
    return '$dir/$filename';
  }

  Future<void> _writeCache(String url, Uint8List bytes) async {
    try {
      final filePath = await _getCacheFilePath(url);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      _memoryCache[url] = bytes;
    } catch (e) {
      print('写入缓存失败: $e');
    }
  }

  Future<Uint8List?> _readCache(String url) async {
    try {
      final filePath = await _getCacheFilePath(url);
      final file = File(filePath);
      if (await file.exists()) return await file.readAsBytes();
      return null;
    } catch (e) {
      print('读取缓存失败: $e');
      return null;
    }
  }

  String _getMimeType(String url) {
    final ext = url.split('.').last.toLowerCase();
    return _mimeTypeMap[ext] ?? 'application/octet-stream';
  }

  Future<void> _clearCache() async {
    try {
      final dir = await _getCacheDir();
      final dirList = await Directory(dir).list().toList();
      for (final file in dirList) {
        if (file is File) await file.delete();
      }
      _memoryCache.clear(); // 清除内存缓存
      print('缓存清除成功');
    } catch (e) {
      print('缓存清除失败: $e');
    }
  }

  Future<bool> _onWillPop() async {
    final canGoBack = await _controller.canGoBack();
    if (canGoBack) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _isFullscreen
            ? null
            : AppBar(
          title: Text(
            _innerTitle,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
              color: Theme.of(context).iconTheme.color,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearCache,
              color: Theme.of(context).iconTheme.color,
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

  Widget _buildWebView() {
    final webView = InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      initialSettings: InAppWebViewSettings(
        cacheEnabled: false, // 自定义缓存
        javaScriptEnabled: true,
        useHybridComposition: true,
      ),
      onWebViewCreated: (controller) {
        _controller = controller;
      },
      onLoadStart: (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _isLoading = true);
        });
      },
      onLoadStop: (controller, url) async {
        if (url != null) {
          final html = await controller.getHtml();
          if (html != null) {
            await _writeCache(url.toString(), Uint8List.fromList(utf8.encode(html)));
          }
          String? rawTitle = await controller.getTitle();
          final validTitle = (rawTitle?.trim().isEmpty ?? true) ? widget.title : rawTitle!;
          _titleCache[url.toString()] = WeakReference(validTitle);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _innerTitle = validTitle;
              _isLoading = false;
            });
          });
        }
      },
      shouldInterceptRequest: (controller, request) async {
        if (request.method != 'GET') return null;
        return await _handleRequest(request.url.toString());
      },
    );

    return widget.enablePullToRefresh
        ? RefreshIndicator(
      onRefresh: () => _controller.reload(),
      child: webView,
    )
        : webView;
  }

  Future<WebResourceResponse?> _handleRequest(String url) async {
    if (_memoryCache.containsKey(url)) {
      return WebResourceResponse(
        data: _memoryCache[url]!,
        contentType: _getMimeType(url),
      );
    }

    final cachedBytes = await _readCache(url);
    if (cachedBytes != null) {
      _memoryCache[url] = cachedBytes;
      return WebResourceResponse(
        data: cachedBytes,
        contentType: _getMimeType(url),
      );
    }

    return null;
  }
}