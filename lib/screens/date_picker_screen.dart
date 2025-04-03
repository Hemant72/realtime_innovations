import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateDialog extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;

  const DateDialog({super.key, this.initialDate, this.firstDate});

  @override
  State<DateDialog> createState() => _DateDialogState();

  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder:
          (context) =>
              DateDialog(initialDate: initialDate, firstDate: firstDate),
    );
  }
}

class _DateDialogState extends State<DateDialog> {
  late DateTime _selectedDate;
  late PageController _pageController;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickSelectButtons(),
            _buildMonthHeader(),
            _buildCalendar(),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectButtons() {
    final today = DateTime.now();
    final nextTuesday = _getNextWeekday(today, DateTime.tuesday);
    final nextMonday = _getNextWeekday(today, DateTime.monday);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildQuickButton('Today', today),
              const SizedBox(width: 8),
              _buildQuickButton('Next Monday', nextMonday),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQuickButton('Next Tuesday', nextTuesday),
              const SizedBox(width: 8),
              _buildQuickButton(
                'After 1 week',
                today.add(const Duration(days: 7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(String text, DateTime date) {
    final isDisabled =
        widget.firstDate != null && date.isBefore(widget.firstDate!);

    return Expanded(
      child: ElevatedButton(
        onPressed:
            isDisabled
                ? null
                : () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year
                  ? Colors.blue
                  : Colors.blue.shade100,
          foregroundColor:
              date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year
                  ? Colors.white
                  : Colors.blue,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey,
        ),
        child: Text(text),
      ),
    );
  }

  DateTime _getNextWeekday(DateTime date, int weekday) {
    DateTime result = date;
    while (result.weekday != weekday) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month - 1,
                );
              });
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_displayedMonth),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month + 1,
                );
              });
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _displayedMonth = DateTime(
              _displayedMonth.year,
              _displayedMonth.month + (page - _pageController.initialPage),
            );
          });
        },
        itemBuilder: (context, pageIndex) {
          final pageMonth = DateTime(
            _displayedMonth.year,
            _displayedMonth.month + (pageIndex - _pageController.initialPage),
          );

          return _buildMonthCalendar(pageMonth);
        },
      ),
    );
  }

  Widget _buildMonthCalendar(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final dayWidgets = <Widget>[];

    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    for (int i = 0; i < 7; i++) {
      dayWidgets.add(
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            weekdays[i],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      );
    }

    int firstDayIndex = firstWeekday % 7;
    for (int i = 0; i < firstDayIndex; i++) {
      dayWidgets.add(Container());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final isDisabled =
          widget.firstDate != null && date.isBefore(widget.firstDate!);

      dayWidgets.add(
        GestureDetector(
          onTap:
              isDisabled
                  ? null
                  : () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:
                  day == _selectedDate.day &&
                          month.month == _selectedDate.month &&
                          month.year == _selectedDate.year
                      ? Colors.blue
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color:
                      isDisabled
                          ? Colors.grey.shade400
                          : day == _selectedDate.day &&
                              month.month == _selectedDate.month &&
                              month.year == _selectedDate.year
                          ? Colors.white
                          : Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '${_selectedDate.day} ${_getMonth(_selectedDate.month)} ${_selectedDate.year}',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedDate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
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
    return months[month - 1];
  }
}
