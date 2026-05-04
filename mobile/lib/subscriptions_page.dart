import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'api_service.dart';
import 'unified_header.dart';

class SubscriptionsPage extends StatefulWidget {
  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<Map<String, dynamic>> _tiers = [];
  Map<String, dynamic>? _currentSubscription;
  Map<String, dynamic>? _limits;
  List<Map<String, dynamic>> _allSubscriptions = [];
  bool _isLoading = true;
  String? _actionLoading;
  String? _message;
  bool _messageIsError = false;
  bool _showTierModal = false;
  Map<String, dynamic>? _editingTier;

  bool get _isAdmin {
    final role = context.read<AuthProvider>().user?['role']?.toString() ?? '';
    return role == 'Admin';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final tiersRes = await ApiService.getSubscriptionTiers();
      final subRes = await ApiService.getCurrentSubscription();

      if (mounted) {
        setState(() {
          _tiers = List<Map<String, dynamic>>.from(tiersRes);
          _currentSubscription = subRes['data'];
          _limits = subRes['limits'];
        });

        if (_isAdmin) {
          final allSubs = await ApiService.getAllSubscriptions();
          if (mounted) {
            setState(() {
              _allSubscriptions = List<Map<String, dynamic>>.from(allSubs);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to load subscription data', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    setState(() {
      _message = text;
      _messageIsError = isError;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }

  String _formatPrice(double price) {
    return 'SAR ${price.toStringAsFixed(0)}';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  bool _isTrialActive() {
    if (_currentSubscription == null) return false;
    final trialEnds = _currentSubscription!['trial_ends_at'];
    if (trialEnds == null) return false;
    try {
      return DateTime.parse(trialEnds).isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  int _getCurrentTierIndex() {
    if (_currentSubscription?['tier'] == null) return -1;
    final tierId = _currentSubscription!['tier']['id'];
    return _tiers.indexWhere((t) => t['id'] == tierId);
  }

  Future<void> _handleSubscribe(Map<String, dynamic> tier) async {
    final currentIndex = _getCurrentTierIndex();
    final tierIndex = _tiers.indexWhere((t) => t['id'] == tier['id']);
    final isUpgrade = tierIndex < currentIndex;
    final isDowngrade = tierIndex > currentIndex;
    
    String message;
    if (isUpgrade) {
      message = 'Upgrade to ${tier['name']}?';
    } else if (isDowngrade) {
      message = 'Downgrade to ${tier['name']}? You may lose access to some features.';
    } else {
      message = 'Subscribe to ${tier['name']} plan?';
    }
    
    final confirmed = await _showConfirmDialog(message);
    if (!confirmed) return;

    setState(() => _actionLoading = tier['id'].toString());
    try {
      if (isUpgrade) {
        await ApiService.upgradeSubscription(tier['id'].toString());
        _showMessage('Successfully upgraded to ${tier['name']}!');
      } else if (isDowngrade) {
        await ApiService.downgradeSubscription(tier['id'].toString());
        _showMessage('Successfully downgraded to ${tier['name']}');
      } else {
        await ApiService.subscribeToTier(tier['id'].toString());
        _showMessage('Successfully subscribed to ${tier['name']}!');
      }
      _fetchData();
    } catch (e) {
      _showMessage('Failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _actionLoading = null);
    }
  }

  Future<void> _handleCancel() async {
    final confirmed = await _showConfirmDialog('Are you sure you want to cancel your subscription?');
    if (!confirmed) return;

    setState(() => _actionLoading = 'cancel');
    try {
      await ApiService.cancelSubscription();
      _showMessage('Subscription cancelled successfully');
      _fetchData();
    } catch (e) {
      _showMessage('Failed to cancel: $e', isError: true);
    } finally {
      if (mounted) setState(() => _actionLoading = null);
    }
  }

  Future<bool> _showConfirmDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfafaf5),
      appBar: UnifiedAppBar(
        title: 'Subscriptions',
        showBackButton: true,
        onBack: () => Navigator.pop(context),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF06402B)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_message != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _messageIsError
                            ? const Color(0xFFfef2f2)
                            : const Color(0xFFecfdf5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _message!,
                        style: TextStyle(
                          color: _messageIsError
                              ? const Color(0xFFba1a1a)
                              : const Color(0xFF065f46),
                        ),
                      ),
                    ),
                  _buildCurrentUsageSection(),
                  const SizedBox(height: 24),
                  _buildPricingCards(),
                  if (_isAdmin) ...[
                    const SizedBox(height: 24),
                    _buildAdminSection(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentUsageSection() {
    if (_currentSubscription == null || _limits == null) {
      return const SizedBox.shrink();
    }

    final limits = _limits!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Usage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildUsageCard('Animals', limits['animals']['used'], limits['animals']['max'], Icons.pets),
              const SizedBox(width: 12),
              _buildUsageCard('Devices', limits['devices']['used'], limits['devices']['max'], Icons.sensors),
              const SizedBox(width: 12),
              _buildUsageCard('Users', limits['users']['used'], limits['users']['max'], Icons.group),
            ],
          ),
          if (_isTrialActive()) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFfffbeb),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFfcd34d)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 16, color: Color(0xFF92400e)),
                  const SizedBox(width: 8),
                  Text(
                    'Trial ends on ${_formatDate(_currentSubscription!['trial_ends_at'])}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF92400e),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageCard(String label, int used, int max, IconData icon) {
    final isUnlimited = max == 0;
    final percentage = isUnlimited ? 0.0 : (used / max).clamp(0.0, 1.0);
    final isWarning = percentage > 0.7;
    final isDanger = percentage > 0.9;

    Color progressColor;
    if (isDanger) {
      progressColor = const Color(0xFFba1a1a);
    } else if (isWarning) {
      progressColor = const Color(0xFFd97706);
    } else {
      progressColor = const Color(0xFF059669);
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFf4f4ef),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF735c00)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF717973),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$used',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002819),
              ),
            ),
            Text(
              '/ ${isUnlimited ? 'Unlimited' : max}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF717973),
              ),
            ),
            if (!isUnlimited) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: const Color(0xFFe5e7eb),
                  valueColor: AlwaysStoppedAnimation(progressColor),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCards() {
    final currentTierIndex = _getCurrentTierIndex();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: _tiers.length,
      itemBuilder: (context, index) {
        final tier = _tiers[index];
        final isCurrentTier = _currentSubscription?['tier']?['id'] == tier['id'];
        final isLowerTier = currentTierIndex > index;
        final isFree = tier['slug'] == 'free';

        return _buildPricingCard(tier, isCurrentTier, isLowerTier, isFree);
      },
    );
  }

  Widget _buildPricingCard(
    Map<String, dynamic> tier,
    bool isCurrentTier,
    bool isLowerTier,
    bool isFree,
  ) {
    Color borderColor;
    if (isCurrentTier) {
      borderColor = const Color(0xFFD4AF37);
    } else {
      borderColor = const Color(0xFFe5e7eb);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isCurrentTier ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCurrentTier)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Current',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          else if ((tier['trial_days'] ?? 0) > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${tier['trial_days']} Day Trial',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          Text(
            tier['name'] ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002819),
            ),
          ),
          if (tier['description'] != null)
            Text(
              tier['description'],
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF717973),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatPrice((tier['price_monthly'] ?? 0).toDouble()),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002819),
                ),
              ),
              const Text(
                '/mo',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF717973),
                ),
              ),
            ],
          ),
          if ((tier['price_yearly'] ?? 0) > 0)
            Text(
              'Save SAR ${((tier['price_monthly'] ?? 0) * 12 - (tier['price_yearly'] ?? 0)).toStringAsFixed(0)}/year',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF059669),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(
                    '${tier['max_animals'] == 0 ? 'Unlimited' : tier['max_animals']} Animals',
                    Icons.pets,
                  ),
                  _buildFeatureItem(
                    '${tier['max_devices'] == 0 ? 'Unlimited' : tier['max_devices']} Devices',
                    Icons.sensors,
                  ),
                  _buildFeatureItem(
                    '${tier['max_users'] == 0 ? 'Unlimited' : tier['max_users']} Users',
                    Icons.group,
                  ),
                  if (tier['has_geofencing'] == true)
                    _buildFeatureItem('Geofencing', Icons.fence),
                  if (tier['has_auctions'] == true)
                    _buildFeatureItem('Auctions', Icons.gavel),
                  if (tier['has_advanced_reports'] == true)
                    _buildFeatureItem('Reports', Icons.analytics),
                  if (tier['has_api_access'] == true)
                    _buildFeatureItem('API Access', Icons.api),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: isCurrentTier
                ? (isFree
                    ? const SizedBox.shrink()
                    : OutlinedButton(
                        onPressed: _actionLoading == 'cancel'
                            ? null
                            : _handleCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFba1a1a),
                          side: const BorderSide(color: Color(0xFFfecaca)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _actionLoading == 'cancel'
                              ? 'Cancelling...'
                              : 'Cancel',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ))
                : ElevatedButton(
                    onPressed: _actionLoading == tier['id'].toString()
                        ? null
                        : () => _handleSubscribe(tier),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002819),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _actionLoading == tier['id'].toString()
                          ? 'Processing...'
                          : (isFree && _currentSubscription == null)
                              ? 'Subscribe Free'
                              : 'Subscribe',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF059669)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF404943)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTierManagement(),
        const SizedBox(height: 24),
        _buildUserSubscriptions(),
      ],
    );
  }

  Widget _buildTierManagement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage Subscription Tiers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002819),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _editingTier = null;
                    _showTierModal = true;
                  });
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Tier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002819),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFf4f4ef)),
              columns: const [
                DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Limits', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Features', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _tiers.map((tier) {
                return DataRow(
                  cells: [
                    DataCell(Text(tier['name'] ?? '')),
                    DataCell(Text(
                      '${_formatPrice((tier['price_monthly'] ?? 0).toDouble())}/${_formatPrice((tier['price_yearly'] ?? 0).toDouble())}',
                    )),
                    DataCell(Text(
                      '${tier['max_animals'] == 0 ? '∞' : tier['max_animals']}A / ${tier['max_devices'] == 0 ? '∞' : tier['max_devices']}D / ${tier['max_users'] == 0 ? '∞' : tier['max_users']}U',
                    )),
                    DataCell(Wrap(
                      spacing: 4,
                      children: [
                        if (tier['has_geofencing'] == true)
                          _buildFeatureChip('Geo', const Color(0xFFd1fae5), const Color(0xFF065f46)),
                        if (tier['has_auctions'] == true)
                          _buildFeatureChip('Auc', const Color(0xFFdbeafe), const Color(0xFF1d4ed8)),
                        if (tier['has_advanced_reports'] == true)
                          _buildFeatureChip('Rep', const Color(0xFFf3e8ff), const Color(0xFF7c3aed)),
                        if (tier['has_api_access'] == true)
                          _buildFeatureChip('API', const Color(0xFFfef3c7), const Color(0xFFd97706)),
                      ],
                    )),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Color(0xFF1976D2)),
                          onPressed: () {
                            setState(() {
                              _editingTier = tier;
                              _showTierModal = true;
                            });
                          },
                        ),
                        if (tier['slug'] != 'free')
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Color(0xFFba1a1a)),
                            onPressed: () => _handleDeleteTier(tier),
                          ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildUserSubscriptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Subscriptions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 16),
          if (_allSubscriptions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No subscriptions found',
                  style: TextStyle(color: Color(0xFF717973)),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFf4f4ef)),
                columns: const [
                  DataColumn(label: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Tier', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _allSubscriptions.map((sub) {
                  final user = sub['user'] ?? {};
                  final tier = sub['tier'] ?? {};
                  final status = sub['status'] ?? 'unknown';

                  Color statusColor;
                  switch (status) {
                    case 'active':
                      statusColor = const Color(0xFF059669);
                      break;
                    case 'cancelled':
                      statusColor = const Color(0xFFba1a1a);
                      break;
                    default:
                      statusColor = const Color(0xFF717973);
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user['name'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              user['email'] ?? '',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF717973)),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tier['name'] ?? 'No Tier',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF735c00),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
),
              ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteTier(Map<String, dynamic> tier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tier'),
        content: Text('Delete ${tier['name']}? Users on this tier will be moved to Free.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFba1a1a))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteSubscriptionTier(tier['id']);
        _showMessage('Tier deleted successfully');
        _fetchData();
      } catch (e) {
        _showMessage('Failed to delete tier: $e', isError: true);
      }
    }
  }
}