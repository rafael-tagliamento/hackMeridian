import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/vaccine.dart';

class VaccinationCalendar extends StatefulWidget {
  final User user;
  final List<Vaccine> vaccinesproximas;
  final List<Vaccine> vaccinesatrasadas;

  const VaccinationCalendar({
    super.key,
    required this.user,
    required this.vaccinesproximas,
    required this.vaccinesatrasadas,
  });

  @override
  State<VaccinationCalendar> createState() => _VaccinationCalendarState();
}

class _VaccinationCalendarState extends State<VaccinationCalendar> {
  late final PageController _pageController;
  final int _monthsToShow = 12; // 1 year: current month + 11
  int _currentPage = 0;        // 0 = current month

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---------- Date utilities ----------
  DateTime _firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _lastDayOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

  DateTime _monthFromOffset(int offset) {
    final now = DateTime.now();
    return DateTime(now.year, now.month + offset, 1);
  }

  DateTime? _parse(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s); // yyyy-MM-dd
    } catch (_) {
      return null;
    }
  }

  // Map of days -> list of vaccines on the day (considers nextDose)
  Map<DateTime, List<Vaccine>> _buildNextDoseIndex(DateTime month) {
    final first = _firstDayOfMonth(month);
    final last  = _lastDayOfMonth(month);

    final map = <DateTime, List<Vaccine>>{};
    for (final v in widget.vaccinesproximas) {
      final nd = _parse(v.nextDose);
      if (nd == null) continue;
      if (nd.isBefore(first) || nd.isAfter(last)) continue;

      final key = DateTime(nd.year, nd.month, nd.day);
      map.putIfAbsent(key, () => []).add(v);
    }
    return map;
  }

  // Upcoming vaccines (up to +N months) — here we use 12
  List<Vaccine> _upcomingWithinMonths(int months) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final limit = DateTime(today.year, today.month + months, today.day);
    final list = <Vaccine>[];
    for (final v in widget.vaccinesproximas) {
      final nd0 = _parse(v.nextDose);
      if (nd0 == null) continue;
      final nd = DateTime(nd0.year, nd0.month, nd0.day);
      if (!nd.isBefore(today) && !nd.isAfter(limit)) list.add(v);
    }
    list.sort((a, b) => _parse(a.nextDose)!.compareTo(_parse(b.nextDose)!));
    return list;
  }

  // Overdue (nextDose < today)
  List<Vaccine> _overdue() {
    final now = DateTime.now();
    final list = <Vaccine>[];
    final today = DateTime(now.year, now.month, now.day);
    for (final v in widget.vaccinesatrasadas) {
      final nd = _parse(v.nextDose);
      if (nd == null) continue;
      final d = DateTime(nd.year, nd.month, nd.day);
      if (d.isBefore(today)) list.add(v);
    }
    list.sort((a, b) => _parse(a.nextDose)!.compareTo(_parse(b.nextDose)!));
    return list;
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final upcoming = _upcomingWithinMonths(12); // next 12 months
    final overdue  = _overdue();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMonthHeader(),
          const SizedBox(height: 8),
          _buildMonthPager(), // Horizontal PageView with 12 months (fixed height)
          const SizedBox(height: 16),

          // List 1 — upcoming vaccines (12 months)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Upcoming vaccines (next 12 months)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          if (upcoming.isEmpty)
            _empty('No upcoming doses in the next 12 months.')
          else
            ListView.builder(
              shrinkWrap: true,
              itemCount: upcoming.length,
              itemBuilder: (_, i) => _vaccineTile(upcoming[i]),
            ),

          const SizedBox(height: 16),

          // List 2 — overdue (light red)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Overdue vaccines',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          if (overdue.isEmpty)
            _empty('No overdue vaccines. 🎉')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: overdue.length,
              itemBuilder: (_, i) => _overdueTile(overdue[i]),
            ),
        ],
      ),
    );
  }

  Widget _empty(String text) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text),
    ),
  );

  Widget _vaccineTile(Vaccine v) {
    final subtitle = [
      if (v.nextDose != null) 'Next dose: ${v.nextDose}',
      'Batch: ${v.batch}',
    ].where((e) => e.isNotEmpty).join(' • ');

    return Card(
      child: ListTile(
        leading: const Icon(Icons.vaccines),
        title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }

  // Overdue version with light red
  Widget _overdueTile(Vaccine v) {
    final subtitle = [
      'Overdue since: ${v.nextDose ?? '—'}',
      'Batch: ${v.batch}',
    ].where((e) => e.isNotEmpty).join(' • ');

    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
        title: Text(
          v.name,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red.shade700),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.red.shade700)),
      ),
    );
  }

  Widget _buildMonthHeader() {
    final selectedMonth = _monthFromOffset(_currentPage);
    final monthName = _monthYearLabel(selectedMonth);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: _currentPage > 0
              ? () => _animateToPage(_currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          monthName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: _currentPage < _monthsToShow - 1
              ? () => _animateToPage(_currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Future<void> _animateToPage(int page) async {
    setState(() => _currentPage = page);
    await _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildMonthPager() {
    return SizedBox(
      height: 370, // fixed height comfortable for 6 rows + day header
      child: PageView.builder(
        controller: _pageController,
        itemCount: _monthsToShow,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (_, i) => _MonthGrid(
          month: _monthFromOffset(i),
          buildIndex: _buildNextDoseIndex,
        ),
      ),
    );
  }

  String _monthYearLabel(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// === Monthly grid ===
class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, List<Vaccine>> Function(DateTime) buildIndex;

  const _MonthGrid({
    required this.month,
    required this.buildIndex,
  });

  DateTime _firstDayOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _lastDayOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

  @override
  Widget build(BuildContext context) {
    final first = _firstDayOfMonth(month);
    final last  = _lastDayOfMonth(month);

    final startWeekday = first.weekday % 7; // Sun=0, Mon=1, ... Sat=6
    final daysInMonth = last.day;
    final totalCells  = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final index = buildIndex(month);

    return Column(
      children: [
        const SizedBox(height: 8),
        _weekdayHeader(),
        const SizedBox(height: 8),

        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // fixed grid inside height
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: rows * 7,
            itemBuilder: (_, cell) {
              final dayNum = cell - startWeekday + 1;
              if (dayNum <= 0 || dayNum > daysInMonth) {
                return const _DayCell.empty();
              }

              final date = DateTime(month.year, month.month, dayNum);
              final key  = DateTime(date.year, date.month, date.day);
              final hasVax = index.containsKey(key);
              return _DayCell(
                day: dayNum,
                marked: hasVax, // pink when there is a vaccine
                vaccines: index[key] ?? const [],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _weekdayHeader() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S']; // Sun..Sat
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map((l) => Expanded(
        child: Center(
          child: Text(
            l,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ),
      ))
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int? day;
  final bool marked;
  final List<Vaccine> vaccines;

  const _DayCell.empty()
      : day = null,
        marked = false,
        vaccines = const [];

  const _DayCell({
    required this.day,
    required this.marked,
    required this.vaccines,
  });

  @override
  Widget build(BuildContext context) {
    if (day == null) return const SizedBox();

    final pink = Colors.pink.shade300;

    return InkWell(
      onTap: vaccines.isEmpty
          ? null
          : () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Vaccines on day $day'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: vaccines
                  .map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• ${v.name}  (next: ${v.nextDose})'),
              ))
                  .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              )
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: marked ? pink.withOpacity(0.25) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: marked ? pink : Colors.grey.shade300,
            width: marked ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            '$day',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: marked ? _darken(pink) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Color _darken(Color c, [double amount = .2]) {
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }
}
