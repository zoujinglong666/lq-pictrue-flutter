import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int maxVisiblePages;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxVisiblePages = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 上一页按钮
          _buildPageButton(
            icon: Icons.chevron_left,
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            isEnabled: currentPage > 1,
          ),
          const SizedBox(width: 8),
          
          // 可滚动的页码按钮区域
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageNumbers(),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          // 下一页按钮
          _buildPageButton(
            icon: Icons.chevron_right,
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            isEnabled: currentPage < totalPages,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];
    
    int startPage = 1;
    int endPage = totalPages;
    
    // 计算显示的页码范围
    if (totalPages > maxVisiblePages) {
      int halfVisible = maxVisiblePages ~/ 2;
      startPage = (currentPage - halfVisible).clamp(1, totalPages - maxVisiblePages + 1);
      endPage = (startPage + maxVisiblePages - 1).clamp(maxVisiblePages, totalPages);
      startPage = endPage - maxVisiblePages + 1;
    }
    
    // 如果起始页不是1，显示第一页和省略号
    if (startPage > 1) {
      pages.add(_buildNumberButton(1));
      if (startPage > 2) {
        pages.add(_buildEllipsis());
      }
    }
    
    // 显示页码范围
    for (int i = startPage; i <= endPage; i++) {
      pages.add(_buildNumberButton(i));
    }
    
    // 如果结束页不是最后一页，显示省略号和最后一页
    if (endPage < totalPages) {
      if (endPage < totalPages - 1) {
        pages.add(_buildEllipsis());
      }
      pages.add(_buildNumberButton(totalPages));
    }
    
    return pages;
  }

  Widget _buildPageButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isEnabled ? Colors.blue[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled ? Colors.blue[200]! : Colors.grey[300]!,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: isEnabled ? Colors.blue[600] : Colors.grey[400],
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildNumberButton(int pageNumber) {
    final isCurrentPage = pageNumber == currentPage;
    
    return GestureDetector(
      onTap: () => onPageChanged(pageNumber),
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isCurrentPage ? Colors.blue[600] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentPage ? Colors.blue[600]! : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            pageNumber.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCurrentPage ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        child: Text(
          '...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// 分页信息显示组件
class PaginationInfo extends StatelessWidget {
  final int currentPage;
  final int pageSize;
  final int totalRecords;
  final int totalPages;

  const PaginationInfo({
    super.key,
    required this.currentPage,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final startRecord = (currentPage - 1) * pageSize + 1;
    final endRecord = (currentPage * pageSize).clamp(0, totalRecords);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '显示 $startRecord-$endRecord 条，共 $totalRecords 条记录',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            '第 $currentPage 页，共 $totalPages 页',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}