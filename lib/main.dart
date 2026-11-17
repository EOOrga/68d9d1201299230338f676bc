import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const bool kScreenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');
const String kAppName = 'MINIER BERNARD MARCEL';
const String kCompanyName = 'MINIER BERNARD MARCEL';
const String kSupportEmail = 'support@minierbernardmarcel.com';

const Color kNavy = Color(0xFF061327);
const Color kBlue = Color(0xFF0E52A0);
const Color kCyan = Color(0xFF159BE4);
const Color kGreen = Color(0xFF0C6024);
const Color kAmber = Color(0xFFD46800);
const Color kInk = Color(0xFF152033);
const Color kPaper = Color(0xFFF6F8FB);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  runApp(const MinierOperationsApp());
}

class MinierOperationsApp extends StatelessWidget {
  const MinierOperationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: kBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: kBlue,
          onPrimary: Colors.white,
          secondary: kGreen,
          onSecondary: Colors.white,
          tertiary: kAmber,
          onTertiary: Colors.white,
          surface: Colors.white,
          onSurface: kInk,
          surfaceContainerHighest: const Color(0xFFE7EDF5),
          outlineVariant: const Color(0xFFD5DDE9),
        );

    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: kPaper,
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: kBlue.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kPaper,
          foregroundColor: kInk,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: kInk,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE0E6EF)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kBlue,
            side: const BorderSide(color: Color(0xFFB7C5D8)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const OperationsShell(),
    );
  }
}

enum OperationType { container, task, reservation, revenue }

enum OperationStatus { planned, active, waiting, completed }

extension OperationTypeInfo on OperationType {
  String get label {
    return switch (this) {
      OperationType.container => 'Container',
      OperationType.task => 'Task',
      OperationType.reservation => 'Reservation',
      OperationType.revenue => 'Revenue',
    };
  }

  String get pluralLabel {
    return switch (this) {
      OperationType.container => 'Containers',
      OperationType.task => 'Tasks',
      OperationType.reservation => 'Reservations',
      OperationType.revenue => 'Revenue',
    };
  }

  IconData get icon {
    return switch (this) {
      OperationType.container => Icons.inventory_2_outlined,
      OperationType.task => Icons.task_alt_outlined,
      OperationType.reservation => Icons.event_available_outlined,
      OperationType.revenue => Icons.query_stats_outlined,
    };
  }

  Color get accent {
    return switch (this) {
      OperationType.container => kBlue,
      OperationType.task => kCyan,
      OperationType.reservation => kGreen,
      OperationType.revenue => kAmber,
    };
  }
}

extension OperationStatusInfo on OperationStatus {
  String get label {
    return switch (this) {
      OperationStatus.planned => 'Planned',
      OperationStatus.active => 'Active',
      OperationStatus.waiting => 'Waiting',
      OperationStatus.completed => 'Completed',
    };
  }

  Color get color {
    return switch (this) {
      OperationStatus.planned => const Color(0xFF607087),
      OperationStatus.active => kBlue,
      OperationStatus.waiting => kAmber,
      OperationStatus.completed => kGreen,
    };
  }
}

class OperationRecord {
  const OperationRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.reference,
    required this.client,
    required this.status,
    required this.dueDate,
    required this.amount,
    required this.notes,
  });

  final String id;
  final OperationType type;
  final String title;
  final String reference;
  final String client;
  final OperationStatus status;
  final DateTime dueDate;
  final double amount;
  final String notes;

  OperationRecord copyWith({
    OperationType? type,
    String? title,
    String? reference,
    String? client,
    OperationStatus? status,
    DateTime? dueDate,
    double? amount,
    String? notes,
  }) {
    return OperationRecord(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      reference: reference ?? this.reference,
      client: client ?? this.client,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'reference': reference,
      'client': client,
      'status': status.name,
      'dueDate': dueDate.toIso8601String(),
      'amount': amount,
      'notes': notes,
    };
  }

  factory OperationRecord.fromJson(Map<String, dynamic> json) {
    return OperationRecord(
      id: json['id'] as String,
      type: OperationType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => OperationType.task,
      ),
      title: json['title'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      client: json['client'] as String? ?? '',
      status: OperationStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => OperationStatus.planned,
      ),
      dueDate:
          DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }
}

class OperationsRepository {
  static const String _recordsKey = 'operation_records';
  static const String _compactRowsKey = 'compact_rows';
  static const String _androidPackage = 'com.taziggg100.minierbernardmarcel';
  static const String _storeFileName = 'operations_store.json';

  Future<List<OperationRecord>> loadRecords() async {
    final store = await _readStore();
    final savedRecords = store[_recordsKey];
    if (savedRecords is! List) {
      return [];
    }

    return savedRecords
        .whereType<Map<String, dynamic>>()
        .map(OperationRecord.fromJson)
        .toList();
  }

  Future<void> saveRecords(List<OperationRecord> records) async {
    if (kScreenshotMode) {
      return;
    }
    final store = await _readStore();
    store[_recordsKey] = records.map((item) => item.toJson()).toList();
    await _writeStore(store);
  }

  Future<bool> loadCompactRows() async {
    final store = await _readStore();
    return store[_compactRowsKey] as bool? ?? false;
  }

  Future<void> saveCompactRows(bool compactRows) async {
    if (kScreenshotMode) {
      return;
    }
    final store = await _readStore();
    store[_compactRowsKey] = compactRows;
    await _writeStore(store);
  }

  Future<void> clear() async {
    if (kScreenshotMode) {
      return;
    }
    final store = await _readStore();
    store.remove(_recordsKey);
    await _writeStore(store);
  }

  Future<Map<String, dynamic>> _readStore() async {
    try {
      final file = _storeFile();
      if (!file.existsSync()) {
        return <String, dynamic>{};
      }
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return <String, dynamic>{};
    }
    return <String, dynamic>{};
  }

  Future<void> _writeStore(Map<String, dynamic> store) async {
    final file = _storeFile();
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(store), flush: true);
  }

  File _storeFile() {
    final directory = _storeDirectory();
    return File('${directory.path}/$_storeFileName');
  }

  Directory _storeDirectory() {
    if (Platform.isAndroid) {
      final androidDirectory = Directory('/data/user/0/$_androidPackage/files');
      try {
        androidDirectory.createSync(recursive: true);
        return androidDirectory;
      } catch (_) {
        final legacyDirectory = Directory('/data/data/$_androidPackage/files');
        legacyDirectory.createSync(recursive: true);
        return legacyDirectory;
      }
    }

    final testDirectory = Directory(
      '${Directory.systemTemp.path}/minier_bernard_marcel',
    );
    testDirectory.createSync(recursive: true);
    return testDirectory;
  }
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({super.key});

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  final OperationsRepository _repository = OperationsRepository();
  final PageController _pageController = PageController();

  List<OperationRecord> _records = [];
  bool _ready = false;
  bool _compactRows = false;
  int _index = 0;
  OperationType _plannerType = OperationType.task;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (kScreenshotMode) {
      setState(() {
        _records = _sampleRecords();
        _compactRows = false;
        _ready = true;
      });
      return;
    }

    final records = await _repository.loadRecords();
    final compactRows = await _repository.loadCompactRows();
    if (!mounted) {
      return;
    }
    setState(() {
      _records = records;
      _compactRows = compactRows;
      _ready = true;
    });
  }

  List<OperationRecord> get _sortedRecords {
    final copy = [..._records];
    copy.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return copy;
  }

  OperationType get _fabType {
    return switch (_index) {
      1 => OperationType.container,
      2 => _plannerType,
      3 => OperationType.revenue,
      _ => OperationType.task,
    };
  }

  String get _title {
    return switch (_index) {
      0 => 'Operations',
      1 => 'Container tracking',
      2 => 'Planning board',
      3 => 'Revenue analytics',
      _ => 'Settings',
    };
  }

  Future<void> _saveRecords(List<OperationRecord> records) async {
    setState(() {
      _records = records;
    });
    await _repository.saveRecords(records);
  }

  Future<void> _upsertRecord(OperationRecord record) async {
    final existingIndex = _records.indexWhere((item) => item.id == record.id);
    final next = [..._records];
    if (existingIndex == -1) {
      next.add(record);
    } else {
      next[existingIndex] = record;
    }
    await _saveRecords(next);
  }

  Future<void> _deleteRecord(OperationRecord record) async {
    final next = _records.where((item) => item.id != record.id).toList();
    await _saveRecords(next);
  }

  Future<void> _clearRecords() async {
    setState(() {
      _records = [];
    });
    await _repository.clear();
  }

  Future<void> _setCompactRows(bool value) async {
    setState(() {
      _compactRows = value;
    });
    await _repository.saveCompactRows(value);
  }

  Future<void> _openRecordForm({
    OperationType? type,
    OperationRecord? record,
  }) async {
    final result = await showModalBottomSheet<OperationRecord>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return RecordFormSheet(
          initialType: type ?? record?.type ?? OperationType.task,
          record: record,
        );
      },
    );

    if (result != null) {
      await _upsertRecord(result);
    }
  }

  Future<void> _openRecordDetail(OperationRecord record) async {
    final result = await Navigator.of(context).push<RecordDetailAction>(
      MaterialPageRoute(builder: (context) => RecordDetailPage(record: record)),
    );

    if (result == null) {
      return;
    }
    if (result.deleteRecord) {
      await _deleteRecord(record);
      return;
    }
    if (result.editRecord) {
      await _openRecordForm(record: record);
    }
  }

  void _goToTab(int index) {
    setState(() {
      _index = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            tooltip: 'Add record',
            onPressed: () => _openRecordForm(type: _fabType),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          DashboardTab(
            records: _sortedRecords,
            onAdd: () => _openRecordForm(type: OperationType.task),
            onOpenRecord: _openRecordDetail,
            onOpenTab: _goToTab,
          ),
          RecordsTab(
            title: 'MINIER BERNARD MARCEL',
            emptyTitle: 'No containers yet',
            emptySubtitle:
                'Add a container to follow reference, status, value, and next date.',
            records: _sortedRecords
                .where((item) => item.type == OperationType.container)
                .toList(),
            compactRows: _compactRows,
            onAdd: () => _openRecordForm(type: OperationType.container),
            onOpenRecord: _openRecordDetail,
          ),
          PlannerTab(
            records: _sortedRecords,
            selectedType: _plannerType,
            compactRows: _compactRows,
            onSelectedTypeChanged: (type) {
              setState(() {
                _plannerType = type;
              });
            },
            onAdd: () => _openRecordForm(type: _plannerType),
            onOpenRecord: _openRecordDetail,
          ),
          RevenueTab(
            records: _sortedRecords,
            compactRows: _compactRows,
            onAdd: () => _openRecordForm(type: OperationType.revenue),
            onOpenRecord: _openRecordDetail,
          ),
          SettingsTab(
            recordCount: _records.length,
            compactRows: _compactRows,
            onCompactRowsChanged: _setCompactRows,
            onClearRecords: _clearRecords,
          ),
        ],
      ),
      floatingActionButton: _index == 4
          ? null
          : FloatingActionButton.extended(
              key: const Key('add_record_fab'),
              onPressed: () => _openRecordForm(type: _fabType),
              icon: const Icon(Icons.add),
              label: Text('Add ${_fabType.label}'),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            key: Key('nav_home'),
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            key: Key('nav_containers'),
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Containers',
          ),
          NavigationDestination(
            key: Key('nav_planner'),
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Planner',
          ),
          NavigationDestination(
            key: Key('nav_revenue'),
            icon: Icon(Icons.query_stats_outlined),
            selectedIcon: Icon(Icons.query_stats),
            label: 'Revenue',
          ),
          NavigationDestination(
            key: Key('nav_settings'),
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({
    required this.records,
    required this.onAdd,
    required this.onOpenRecord,
    required this.onOpenTab,
    super.key,
  });

  final List<OperationRecord> records;
  final VoidCallback onAdd;
  final ValueChanged<OperationRecord> onOpenRecord;
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final activeCount = records
        .where((item) => item.status != OperationStatus.completed)
        .length;
    final waitingCount = records
        .where((item) => item.status == OperationStatus.waiting)
        .length;
    final revenueTotal = records
        .where((item) => item.type == OperationType.revenue)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final nextRecords = records
        .where((item) => item.status != OperationStatus.completed)
        .take(4)
        .toList();

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
        children: [
          const BrandHeader(),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 380;
              return GridView.count(
                crossAxisCount: isNarrow ? 2 : 4,
                childAspectRatio: isNarrow ? 1.48 : 1.25,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  MetricCard(
                    label: 'Active work',
                    value: '$activeCount',
                    icon: Icons.route_outlined,
                    color: kBlue,
                  ),
                  MetricCard(
                    label: 'Waiting',
                    value: '$waitingCount',
                    icon: Icons.hourglass_top_outlined,
                    color: kAmber,
                  ),
                  MetricCard(
                    label: 'Revenue',
                    value: formatMoney(revenueTotal),
                    icon: Icons.payments_outlined,
                    color: kGreen,
                  ),
                  MetricCard(
                    label: 'Reservations',
                    value:
                        '${records.where((item) => item.type == OperationType.reservation).length}',
                    icon: Icons.event_available_outlined,
                    color: kCyan,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Today focus',
            actionLabel: 'Add task',
            onAction: onAdd,
          ),
          if (nextRecords.isEmpty)
            EmptyStateCard(
              title: 'No active records',
              subtitle:
                  'Add your first task, container, reservation, or revenue entry.',
              onAdd: onAdd,
            )
          else
            ...nextRecords.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecordTile(
                  record: record,
                  compact: false,
                  onTap: () => onOpenRecord(record),
                ),
              ),
            ),
          const SizedBox(height: 8),
          QuickLinks(onOpenTab: onOpenTab),
        ],
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 2.05,
            child: Image.asset(
              'docs/featured.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: kNavy);
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    kNavy.withValues(alpha: 0.92),
                    kNavy.withValues(alpha: 0.60),
                    kNavy.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Text(
                      'Offline operations desk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'MINIER BERNARD\nMARCEL',
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Containers, tasks, reservations, and revenue in one local workspace.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFEAF1FA),
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
            FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  color: kInk,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickLinks extends StatelessWidget {
  const QuickLinks({required this.onOpenTab, super.key});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jump to workflow',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.inventory_2_outlined, size: 18),
                  label: const Text('Containers'),
                  onPressed: () => onOpenTab(1),
                ),
                ActionChip(
                  avatar: const Icon(Icons.event_note_outlined, size: 18),
                  label: const Text('Planner'),
                  onPressed: () => onOpenTab(2),
                ),
                ActionChip(
                  avatar: const Icon(Icons.query_stats_outlined, size: 18),
                  label: const Text('Revenue'),
                  onPressed: () => onOpenTab(3),
                ),
                ActionChip(
                  avatar: const Icon(Icons.settings_outlined, size: 18),
                  label: const Text('Settings'),
                  onPressed: () => onOpenTab(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RecordsTab extends StatelessWidget {
  const RecordsTab({
    required this.title,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.records,
    required this.compactRows,
    required this.onAdd,
    required this.onOpenRecord,
    super.key,
  });

  final String title;
  final String emptyTitle;
  final String emptySubtitle;
  final List<OperationRecord> records;
  final bool compactRows;
  final VoidCallback onAdd;
  final ValueChanged<OperationRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
        children: [
          SectionHeader(title: title, actionLabel: 'Add', onAction: onAdd),
          if (records.isEmpty)
            EmptyStateCard(
              title: emptyTitle,
              subtitle: emptySubtitle,
              onAdd: onAdd,
            )
          else
            ...records.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecordTile(
                  record: record,
                  compact: compactRows,
                  onTap: () => onOpenRecord(record),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PlannerTab extends StatelessWidget {
  const PlannerTab({
    required this.records,
    required this.selectedType,
    required this.compactRows,
    required this.onSelectedTypeChanged,
    required this.onAdd,
    required this.onOpenRecord,
    super.key,
  });

  final List<OperationRecord> records;
  final OperationType selectedType;
  final bool compactRows;
  final ValueChanged<OperationType> onSelectedTypeChanged;
  final VoidCallback onAdd;
  final ValueChanged<OperationRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final visibleRecords = records
        .where((item) => item.type == selectedType)
        .toList();

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
        children: [
          SegmentedButton<OperationType>(
            segments: const [
              ButtonSegment(
                value: OperationType.task,
                label: Text('Tasks'),
                icon: Icon(Icons.task_alt_outlined),
              ),
              ButtonSegment(
                value: OperationType.reservation,
                label: Text('Reservations'),
                icon: Icon(Icons.event_available_outlined),
              ),
            ],
            selected: {selectedType},
            onSelectionChanged: (selection) {
              onSelectedTypeChanged(selection.first);
            },
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: selectedType.pluralLabel,
            actionLabel: 'Add',
            onAction: onAdd,
          ),
          if (visibleRecords.isEmpty)
            EmptyStateCard(
              title: 'Nothing planned',
              subtitle:
                  'Create the next ${selectedType.label.toLowerCase()} and keep the day organized.',
              onAdd: onAdd,
            )
          else
            ...visibleRecords.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecordTile(
                  record: record,
                  compact: compactRows,
                  onTap: () => onOpenRecord(record),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RevenueTab extends StatelessWidget {
  const RevenueTab({
    required this.records,
    required this.compactRows,
    required this.onAdd,
    required this.onOpenRecord,
    super.key,
  });

  final List<OperationRecord> records;
  final bool compactRows;
  final VoidCallback onAdd;
  final ValueChanged<OperationRecord> onOpenRecord;

  @override
  Widget build(BuildContext context) {
    final revenueRecords = records
        .where((item) => item.type == OperationType.revenue)
        .toList();
    final completedTotal = revenueRecords
        .where((item) => item.status == OperationStatus.completed)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final pendingTotal = revenueRecords
        .where((item) => item.status != OperationStatus.completed)
        .fold<double>(0, (sum, item) => sum + item.amount);

    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: isNarrow ? 1.42 : 1.75,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  MetricCard(
                    label: 'Recognized',
                    value: formatMoney(completedTotal),
                    icon: Icons.verified_outlined,
                    color: kGreen,
                  ),
                  MetricCard(
                    label: 'Open value',
                    value: formatMoney(pendingTotal),
                    icon: Icons.pending_actions_outlined,
                    color: kAmber,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          RevenueChart(records: revenueRecords),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'Revenue entries',
            actionLabel: 'Add',
            onAction: onAdd,
          ),
          if (revenueRecords.isEmpty)
            EmptyStateCard(
              title: 'No revenue entries',
              subtitle:
                  'Add expected or completed revenue to monitor the daily pipeline.',
              onAdd: onAdd,
            )
          else
            ...revenueRecords.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RecordTile(
                  record: record,
                  compact: compactRows,
                  onTap: () => onOpenRecord(record),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RevenueChart extends StatelessWidget {
  const RevenueChart({required this.records, super.key});

  final List<OperationRecord> records;

  @override
  Widget build(BuildContext context) {
    final values = [
      _statusTotal(OperationStatus.planned),
      _statusTotal(OperationStatus.active),
      _statusTotal(OperationStatus.waiting),
      _statusTotal(OperationStatus.completed),
    ];
    final maxValue = math.max(1, values.fold<double>(0, math.max));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue by status',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            for (final status in OperationStatus.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RevenueBar(
                  status: status,
                  value: _statusTotal(status),
                  maxValue: maxValue.toDouble(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _statusTotal(OperationStatus status) {
    return records
        .where((item) => item.status == status)
        .fold<double>(0, (sum, item) => sum + item.amount);
  }
}

class _RevenueBar extends StatelessWidget {
  const _RevenueBar({
    required this.status,
    required this.value,
    required this.maxValue,
  });

  final OperationStatus status;
  final double value;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final fraction = value <= 0 ? 0.02 : (value / maxValue).clamp(0.04, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                status.label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              formatMoney(value),
              style: const TextStyle(color: Color(0xFF526176)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 10,
            backgroundColor: const Color(0xFFE6ECF4),
            color: status.color,
          ),
        ),
      ],
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({
    required this.recordCount,
    required this.compactRows,
    required this.onCompactRowsChanged,
    required this.onClearRecords,
    super.key,
  });

  final int recordCount;
  final bool compactRows;
  final ValueChanged<bool> onCompactRowsChanged;
  final Future<void> Function() onClearRecords;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    kCompanyName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'All operational records are stored only on this device.',
                    style: TextStyle(color: Color(0xFF526176), height: 1.35),
                  ),
                  const SizedBox(height: 14),
                  InfoRow(
                    icon: Icons.storage_outlined,
                    label: 'Local records',
                    value: '$recordCount saved',
                  ),
                  const SizedBox(height: 10),
                  const InfoRow(
                    icon: Icons.mail_outline,
                    label: 'Support',
                    value: kSupportEmail,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              value: compactRows,
              onChanged: onCompactRowsChanged,
              title: const Text('Compact record rows'),
              subtitle: const Text(
                'Show denser lists for repeated daily review.',
              ),
              secondary: const Icon(Icons.view_agenda_outlined),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The app does not create accounts, upload records, collect analytics, or call external services.',
                    style: TextStyle(color: Color(0xFF526176), height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _confirmClear(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear local records'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear local records?'),
          content: const Text(
            'This removes saved containers, tasks, reservations, and revenue entries from this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await onClearRecords();
    }
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({
    required this.record,
    required this.compact,
    required this.onTap,
    super.key,
  });

  final OperationRecord record;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: record.type.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(record.type.icon, color: record.type.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            record.title,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusPill(status: record.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${record.reference} - ${record.client}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF526176),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          SmallLabel(
                            icon: Icons.calendar_today_outlined,
                            label: formatDate(record.dueDate),
                          ),
                          SmallLabel(
                            icon: Icons.payments_outlined,
                            label: formatMoney(record.amount),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({required this.status, super.key});

  final OperationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class SmallLabel extends StatelessWidget {
  const SmallLabel({required this.icon, required this.label, super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF526176)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF526176),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.onAdd,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.playlist_add_circle_outlined, color: kBlue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF526176), height: 1.35),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add record'),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}

class RecordFormSheet extends StatefulWidget {
  const RecordFormSheet({required this.initialType, this.record, super.key});

  final OperationType initialType;
  final OperationRecord? record;

  @override
  State<RecordFormSheet> createState() => _RecordFormSheetState();
}

class _RecordFormSheetState extends State<RecordFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _referenceController;
  late final TextEditingController _clientController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late OperationType _type;
  late OperationStatus _status;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    _type = record?.type ?? widget.initialType;
    _status = record?.status ?? OperationStatus.planned;
    _dueDate = record?.dueDate ?? DateTime.now().add(const Duration(days: 2));
    _titleController = TextEditingController(text: record?.title ?? '');
    _referenceController = TextEditingController(text: record?.reference ?? '');
    _clientController = TextEditingController(text: record?.client ?? '');
    _amountController = TextEditingController(
      text: record == null || record.amount == 0
          ? ''
          : record.amount.toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: record?.notes ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _referenceController.dispose();
    _clientController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.record == null ? 'Add record' : 'Edit record',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<OperationType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Workflow'),
                items: OperationType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (type) {
                  if (type != null) {
                    setState(() => _type = type);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('record_title_field'),
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: '${_type.label} name',
                  prefixIcon: Icon(_type.icon),
                ),
                textInputAction: TextInputAction.next,
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('record_reference_field'),
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  prefixIcon: Icon(Icons.tag_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('record_client_field'),
                controller: _clientController,
                decoration: const InputDecoration(
                  labelText: 'Client or owner',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: _required,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<OperationStatus>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: OperationStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (status) {
                        if (status != null) {
                          setState(() => _status = status);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('record_amount_field'),
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Value EUR',
                        prefixIcon: Icon(Icons.euro_outlined),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text('Next date: ${formatDate(_dueDate)}'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('record_save_button'),
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save record'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final record = OperationRecord(
      id: widget.record?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: _type,
      title: _titleController.text.trim(),
      reference: _referenceController.text.trim(),
      client: _clientController.text.trim(),
      status: _status,
      dueDate: _dueDate,
      amount: double.tryParse(_amountController.text.trim()) ?? 0,
      notes: _notesController.text.trim(),
    );
    Navigator.of(context).pop(record);
  }
}

class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({required this.record, super.key});

  final OperationRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(record.type.label),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed: () {
              Navigator.of(context).pop(const RecordDetailAction.edit());
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: record.type.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            record.type.icon,
                            color: record.type.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record.reference,
                                style: const TextStyle(
                                  color: Color(0xFF526176),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    StatusPill(status: record.status),
                    const SizedBox(height: 18),
                    InfoRow(
                      icon: Icons.business_outlined,
                      label: 'Client or owner',
                      value: record.client,
                    ),
                    const SizedBox(height: 12),
                    InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Next date',
                      value: formatDate(record.dueDate),
                    ),
                    const SizedBox(height: 12),
                    InfoRow(
                      icon: Icons.payments_outlined,
                      label: 'Value',
                      value: formatMoney(record.amount),
                    ),
                    if (record.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        record.notes,
                        style: const TextStyle(
                          color: Color(0xFF526176),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(const RecordDetailAction.delete());
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete record'),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordDetailAction {
  const RecordDetailAction._({
    required this.editRecord,
    required this.deleteRecord,
  });

  const RecordDetailAction.edit()
    : this._(editRecord: true, deleteRecord: false);

  const RecordDetailAction.delete()
    : this._(editRecord: false, deleteRecord: true);

  final bool editRecord;
  final bool deleteRecord;
}

String formatMoney(double value) {
  if (value.abs() >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M EUR';
  }
  if (value.abs() >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}k EUR';
  }
  return '${value.toStringAsFixed(0)} EUR';
}

String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

List<OperationRecord> _sampleRecords() {
  final now = DateTime(2026, 5, 11, 9);
  return [
    OperationRecord(
      id: 'sample-container-1',
      type: OperationType.container,
      title: 'Reefer container arrival',
      reference: 'MBM-CN-4821',
      client: 'Port operations',
      status: OperationStatus.active,
      dueDate: now.add(const Duration(days: 1)),
      amount: 18600,
      notes:
          'Check dock slot, customs file, and loading window before dispatch.',
    ),
    OperationRecord(
      id: 'sample-container-2',
      type: OperationType.container,
      title: 'Export container staging',
      reference: 'MBM-CN-5017',
      client: 'North freight desk',
      status: OperationStatus.waiting,
      dueDate: now.add(const Duration(days: 3)),
      amount: 12450,
      notes: 'Awaiting final truck assignment and seal confirmation.',
    ),
    OperationRecord(
      id: 'sample-task-1',
      type: OperationType.task,
      title: 'Validate morning operations list',
      reference: 'TASK-104',
      client: 'Internal team',
      status: OperationStatus.planned,
      dueDate: now,
      amount: 0,
      notes:
          'Review late containers, priority clients, and revenue follow-ups.',
    ),
    OperationRecord(
      id: 'sample-task-2',
      type: OperationType.task,
      title: 'Confirm driver availability',
      reference: 'TASK-108',
      client: 'Transport desk',
      status: OperationStatus.active,
      dueDate: now.add(const Duration(days: 1)),
      amount: 0,
      notes: 'Line up two fallback drivers for the evening handover.',
    ),
    OperationRecord(
      id: 'sample-reservation-1',
      type: OperationType.reservation,
      title: 'Warehouse slot reservation',
      reference: 'RES-219',
      client: 'Storage partner',
      status: OperationStatus.active,
      dueDate: now.add(const Duration(days: 2)),
      amount: 4200,
      notes: 'Reserve bay B3 and confirm handling equipment availability.',
    ),
    OperationRecord(
      id: 'sample-reservation-2',
      type: OperationType.reservation,
      title: 'Client loading appointment',
      reference: 'RES-226',
      client: 'Retail distribution',
      status: OperationStatus.planned,
      dueDate: now.add(const Duration(days: 4)),
      amount: 3100,
      notes: 'Appointment requires signed release before arrival.',
    ),
    OperationRecord(
      id: 'sample-revenue-1',
      type: OperationType.revenue,
      title: 'Completed transport invoice',
      reference: 'REV-778',
      client: 'Atlantic logistics',
      status: OperationStatus.completed,
      dueDate: now.subtract(const Duration(days: 1)),
      amount: 26800,
      notes: 'Invoice approved and marked as completed locally.',
    ),
    OperationRecord(
      id: 'sample-revenue-2',
      type: OperationType.revenue,
      title: 'Reserved handling revenue',
      reference: 'REV-785',
      client: 'Warehouse desk',
      status: OperationStatus.active,
      dueDate: now.add(const Duration(days: 2)),
      amount: 9600,
      notes: 'Expected after reservation and container handover are confirmed.',
    ),
  ];
}
