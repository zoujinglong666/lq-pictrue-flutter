String formatFileSize(int bytes) {
  if (bytes < 0) return '0 B';
  const List<String> units = ['B', 'KB', 'MB', 'GB', 'TB'];
  double size = bytes.toDouble();
  int unitIndex = 0;

  while (size >= 1024 && unitIndex < units.length - 1) {
    size /= 1024;
    unitIndex++;
  }

  // 对于字节单位显示整数，其他单位保留1位小数
  if (unitIndex == 0) {
    return '${size.toInt()} ${units[unitIndex]}';
  } else {
    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}