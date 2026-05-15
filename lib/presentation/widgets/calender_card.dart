import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:kegiatin/domain/entities/event.dart';

/// Shared calendar card widget for event activity display.
/// Shows a calendar month with date selection and event highlight capability.
class CalendarCard extends StatefulWidget {
  /// Callback when a date is selected. Returns selected DateTime.
  final Function(DateTime selectedDate)? onDateSelected;

  /// Map of dates with their associated events for highlighting.
  final Map<DateTime, List<Event>>? eventsByDate;

  /// Currently selected date.
  final DateTime? selectedDate;

  const CalendarCard({super.key, this.onDateSelected, this.eventsByDate, this.selectedDate});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    // Initialize Indonesian locale for date formatting
    initializeDateFormatting('id_ID');
  }

  @override
  void didUpdateWidget(CalendarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null && widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate!;
      _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  List<Event>? _getEventsForDate(DateTime date) {
    if (widget.eventsByDate == null) return null;
    return widget.eventsByDate![date];
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected?.call(date);

    // Show events for this date if it has any
    final events = _getEventsForDate(date);
    if (events != null && events.isNotEmpty) {
      _showEventBottomSheet(context, date, events);
    }
  }

  void _showEventBottomSheet(BuildContext context, DateTime date, List<Event> events) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date),
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '📍 ${event.location}',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (event.sessions.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '🕐 ${DateFormat('HH:mm').format(event.sessions.first.startTime)}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventColor(int eventCount, int colorIndex) {
    // Define a palette of vibrant colors for event highlights
    const colors = [
      Color(0xFF405f91), // Primary blue
      Color(0xFF2E7D32), // Green
      Color(0xFFFF6B6B), // Red
      Color(0xFFFFD700), // Gold
      Color(0xFF9C27B0), // Purple
      Color(0xFF00BCD4), // Cyan
      Color(0xFFFF9800), // Orange
      Color(0xFFE91E63), // Pink
    ];
    return colors[colorIndex % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get first day of month and days in month
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday
    final daysInMonth = lastDay.day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Month/Year + Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: Icon(Icons.chevron_left, color: colorScheme.primary),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: Icon(Icons.chevron_right, color: colorScheme.primary),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday labels
          Row(
            children: ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB']
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 weeks
            itemBuilder: (context, index) {
              late DateTime date;
              late bool isCurrentMonth;
              late bool isToday;
              late bool isSelected;
              final events = _getEventsForDate(
                DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  index < firstWeekday - 1 || index >= firstWeekday - 1 + daysInMonth
                      ? (index < firstWeekday - 1 ? 1 : daysInMonth)
                      : index - (firstWeekday - 2),
                ),
              );

              if (index < firstWeekday - 1) {
                // Previous month days
                date = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  -(firstWeekday - 2 - index),
                );
                isCurrentMonth = false;
              } else if (index >= firstWeekday - 1 + daysInMonth) {
                // Next month days
                date = DateTime(
                  _currentMonth.year,
                  _currentMonth.month + 1,
                  index - (firstWeekday - 1) - daysInMonth + 1,
                );
                isCurrentMonth = false;
              } else {
                // Current month days
                date = DateTime(
                  _currentMonth.year,
                  _currentMonth.month,
                  index - (firstWeekday - 2),
                );
                isCurrentMonth = true;
              }

              final now = DateTime.now();
              isToday = _isSameDay(date, DateTime(now.year, now.month, now.day));
              isSelected = _isSameDay(date, _selectedDate);
              final hasEvent = events != null && events.isNotEmpty;

              // Get color for event highlight
              final eventColor = hasEvent ? _getEventColor(events.length, date.day) : null;

              return GestureDetector(
                onTap: isCurrentMonth ? () => _selectDate(date) : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circular background for event highlights
                    if (hasEvent && isCurrentMonth)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: eventColor?.withValues(alpha: 0.15),
                          border: Border.all(color: eventColor ?? colorScheme.primary, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    // Selected date highlight (larger circle)
                    if (isSelected)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    // Today highlight
                    if (isToday && !isSelected)
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                    // Date text
                    Text(
                      date.day.toString(),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : hasEvent && isCurrentMonth
                            ? eventColor
                            : isToday
                            ? colorScheme.onPrimaryContainer
                            : isCurrentMonth
                            ? colorScheme.onSurface
                            : colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
