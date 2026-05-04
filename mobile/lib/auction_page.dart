import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_provider.dart';
import 'auth_provider.dart';
import 'navigation.dart';
import 'unified_header.dart';

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFfafaf5), child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class AuctionPage extends StatefulWidget {
  @override
  State<AuctionPage> createState() => _AuctionPageState();
}

class _AuctionPageState extends State<AuctionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAuctions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userRole = auth.user?['role'] ?? '';
    final canEdit = userRole == 'Admin' || userRole == 'Owner';

    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, _) {
          final auctions = dataProvider.auctions.isNotEmpty
              ? dataProvider.auctions.cast<Map<String, dynamic>>()
              : <Map<String, dynamic>>[];
          final isLoading = dataProvider.isLoading;

          final activeAuctions = auctions
              .where((a) => a['status'] == 'active' || a['status'] == 'live')
              .cast<Map<String, dynamic>>()
              .toList();
          final completedAuctions = auctions
              .where((a) => a['status'] == 'sold' || a['status'] == 'completed')
              .cast<Map<String, dynamic>>()
              .toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              UnifiedAppBar(
                title: 'Auctions',
                showBackButton: true,
                onBack: () => Navigator.pop(context),
              ),
              SliverPersistentHeader(
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF06402B),
                    unselectedLabelColor: const Color(0xFF717973),
                    indicatorColor: const Color(0xFF06402B),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    tabs: [
                      Tab(text: 'Active (${activeAuctions.length})'),
                      Tab(text: 'Sold (${completedAuctions.length})'),
                      Tab(text: 'All (${auctions.length})'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ],
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF06402B)),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAuctionList(activeAuctions),
                      _buildAuctionList(completedAuctions),
                      _buildAuctionList(auctions),
                    ],
                  ),
          );
        },
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateAuctionDialog(context),
              backgroundColor: const Color(0xFF06402B),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New Auction',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildAuctionList(List<Map<String, dynamic>> auctions) {
    if (auctions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.gavel, size: 64, color: Color(0xFF717973)),
            SizedBox(height: 16),
            Text(
              'No auctions',
              style: TextStyle(fontSize: 18, color: Color(0xFF717973)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: auctions.length,
      itemBuilder: (context, index) => _buildAuctionCard(auctions[index]),
    );
  }

  Widget _buildAuctionCard(Map<String, dynamic> auction) {
    final status = auction['status'] ?? 'active';
    final currentPrice =
        auction['current_price'] ?? auction['starting_price'] ?? 0;
    final startingPrice = auction['starting_price'] ?? 0;

    Color statusColor;
    String statusText;

    switch (status) {
      case 'active':
      case 'live':
        statusColor = const Color(0xFF0B5D3B);
        statusText = 'Active';
        break;
      case 'sold':
        statusColor = const Color(0xFF06402B);
        statusText = 'Sold';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFba1a1a);
        statusText = 'Cancelled';
        break;
      default:
        statusColor = const Color(0xFF717973);
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFf4f4ef),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pets, color: Color(0xFF717973)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auction['title'] ?? 'Auction',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF06402B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Animal: ${auction['animal_id'] ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF717973),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Bid',
                    style: TextStyle(fontSize: 10, color: Color(0xFF717973)),
                  ),
                  Text(
                    '\$${_formatPrice(currentPrice)}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF06402B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Starting',
                    style: TextStyle(fontSize: 10, color: Color(0xFF717973)),
                  ),
                  Text(
                    '\$${_formatPrice(startingPrice)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF717973),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (auction['ends_at'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, size: 14, color: Color(0xFF717973)),
                const SizedBox(width: 4),
                Text(
                  'Ends: ${auction['ends_at'].toString().split('T').first}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF717973),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateAuctionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: Text('Create auction functionality')),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    if (price is String) {
      final parsed = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), ''));
      if (parsed == null) return price;
      price = parsed;
    }
    if (price is num) {
      return price.toStringAsFixed(0);
    }
    return price.toString();
  }
}
