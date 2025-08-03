import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../utils/colors.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/loading_widget.dart';

/// Screen for managing farming calendar and crop-related reminders
/// Displays seasonal activities, crop schedules, and farming tips
class CropCalendarScreen extends StatefulWidget {
  /// Creates a new crop calendar screen
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  List<CalendarEvent> _events = [];
  List<CropSchedule> _cropSchedules = [];
  List<FarmingTip> _farmingTips = [];
  bool _isLoading = true;
  
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = DateTime.now();
    _loadCalendarData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load calendar data from assets and storage
  Future<void> _loadCalendarData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load crop calendar data from assets
      final calendarJson = await rootBundle.loadString('assets/data/crop_calendar.json');
      final calendarData = json.decode(calendarJson) as Map<String, dynamic>;
      
      // Load farming tips
      final tipsJson = await rootBundle.loadString('assets/data/farming_tips.json');
      final tipsData = json.decode(tipsJson) as List<dynamic>;
      
      // Parse crop schedules
      _cropSchedules = (calendarData['crop_schedules'] as List<dynamic>)
          .map<CropSchedule>((schedule) => CropSchedule.fromJson(schedule as Map<String, dynamic>))
          .toList();
      
      // Parse farming tips
      _farmingTips = tipsData
          .map<FarmingTip>((tip) => FarmingTip.fromJson(tip as Map<String, dynamic>))
          .toList();
      
      // Load user's custom events (assuming this method exists or returns empty list)
      try {
        final customEvents = await _storageService.getCalendarEvents();
        _events = customEvents;
      } catch (e) {
        // If method doesn't exist, start with empty list
        _events = [];
      }
      
      // Generate calendar events from crop schedules
      _generateCalendarEvents();
      
    } catch (e) {
      debugPrint('Error loading calendar data: $e');
      _showErrorSnackBar('Failed to load calendar data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Generate calendar events from crop schedules
  void _generateCalendarEvents() {
    final now = DateTime.now();
    final currentYear = now.year;
    
    for (final schedule in _cropSchedules) {
      for (final activity in schedule.activities) {
        final eventDate = DateTime(currentYear, activity.month, activity.day);
        
        // Only add future events or events within the last month
        if (eventDate.isAfter(now.subtract(const Duration(days: 30)))) {
          _events.add(CalendarEvent(
            id: '${schedule.cropName}_${activity.activity}_$currentYear',
            title: '${activity.activity} - ${schedule.cropName}',
            description: activity.description,
            date: eventDate,
            type: EventType.cropActivity,
            isReminder: true,
            cropName: schedule.cropName,
          ));
        }
      }
    }
  }

  /// Get events for a specific day
  List<CalendarEvent> _getEventsForDay(DateTime day) =>
      _events.where((event) => isSameDay(event.date, day)).toList();

  /// Show add event dialog
  void _showAddEventDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AddEventDialog(
        selectedDate: _selectedDay ?? DateTime.now(),
        onEventAdded: _addEvent,
      ),
    );
  }

  /// Add new event
  Future<void> _addEvent(CalendarEvent event) async {
    setState(() {
      _events.add(event);
    });
    
    // Save to storage (handle if method doesn't exist)
    try {
      await _storageService.saveCalendarEvents(_events);
    } catch (e) {
      debugPrint('Failed to save events: $e');
    }
    
    // Schedule notification if reminder is enabled
    if (event.isReminder) {
      await _notificationService.scheduleNotification(
        id: event.id.hashCode,
        title: event.title,
        body: event.description,
        scheduledDate: event.date,
      );
    }
    
    _showSuccessSnackBar('Event added successfully');
  }

  /// Delete event
  Future<void> _deleteEvent(CalendarEvent event) async {
    setState(() {
      _events.removeWhere((e) => e.id == event.id);
    });
    
    try {
      await _storageService.saveCalendarEvents(_events);
    } catch (e) {
      debugPrint('Failed to save events after deletion: $e');
    }
    
    // Cancel notification
    await _notificationService.cancelNotification(event.id.hashCode);
    
    _showSuccessSnackBar('Event deleted');
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBar(
        title: 'Crop Calendar',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCalendarTab(),
                      _buildSchedulesTab(),
                      _buildTipsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );

  /// Build tab bar
  Widget _buildTabBar() => ColoredBox(
      color: Theme.of(context).primaryColor,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Calendar', icon: Icon(Icons.calendar_today)),
          Tab(text: 'Schedules', icon: Icon(Icons.schedule)),
          Tab(text: 'Tips', icon: Icon(Icons.lightbulb)),
        ],
      ),
    );

  /// Build calendar tab
  Widget _buildCalendarTab() => Column(
      children: [
        CustomCard(
          child: TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _buildEventsList(),
        ),
      ],
    );

  /// Build events list for selected day
  Widget _buildEventsList() {
    final events = _selectedDay != null ? _getEventsForDay(_selectedDay!) : <CalendarEvent>[];
    
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No events for selected day',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  /// Build event card
  Widget _buildEventCard(CalendarEvent event) => CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getEventTypeColor(event.type),
          child: Icon(
            _getEventTypeIcon(event.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            if (event.cropName != null)
              Text(
                'Crop: ${event.cropName}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: event.type == EventType.custom
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEvent(event),
              )
            : event.isReminder
                ? const Icon(Icons.notifications, color: Colors.orange)
                : null,
      ),
    );

  /// Build schedules tab
  Widget _buildSchedulesTab() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cropSchedules.length,
      itemBuilder: (context, index) {
        final schedule = _cropSchedules[index];
        return _buildScheduleCard(schedule);
      },
    );

  /// Build schedule card
  Widget _buildScheduleCard(CropSchedule schedule) => CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary ?? Colors.green,
          child: Text(
            schedule.cropName.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          schedule.cropName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${schedule.activities.length} activities'),
        children: schedule.activities.map<Widget>((activity) =>
          ListTile(
            leading: Icon(
              _getActivityIcon(activity.activity),
              color: Theme.of(context).primaryColor,
            ),
            title: Text(activity.activity),
            subtitle: Text(activity.description),
            trailing: Text(
              '${activity.day}/${activity.month}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
      ),
    );

  /// Build tips tab
  Widget _buildTipsTab() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _farmingTips.length,
      itemBuilder: (context, index) {
        final tip = _farmingTips[index];
        return _buildTipCard(tip);
      },
    );

  /// Build tip card
  Widget _buildTipCard(FarmingTip tip) => CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.lightbulb, color: Colors.white),
        ),
        title: Text(
          tip.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(tip.category),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.description,
                  style: const TextStyle(fontSize: 14),
                ),
                if (tip.season != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'Best for: ${tip.season}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

  /// Get color for event type
  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.cropActivity:
        return Colors.green;
      case EventType.custom:
        return Colors.blue;
      case EventType.reminder:
        return Colors.orange;
      case EventType.weather:
        return Colors.cyan;
    }
  }

  /// Get icon for event type
  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.cropActivity:
        return Icons.agriculture;
      case EventType.custom:
        return Icons.event;
      case EventType.reminder:
        return Icons.notifications;
      case EventType.weather:
        return Icons.cloud;
    }
  }

  /// Get icon for activity type
  IconData _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'planting':
      case 'sowing':
        return Icons.eco;
      case 'watering':
      case 'irrigation':
        return Icons.water_drop;
      case 'fertilizing':
        return Icons.scatter_plot;
      case 'harvesting':
        return Icons.agriculture;
      case 'pruning':
        return Icons.content_cut;
      case 'weeding':
        return Icons.grass;
      default:
        return Icons.task_alt;
    }
  }
}

/// Dialog for adding new events
class AddEventDialog extends StatefulWidget {
  /// Creates a new add event dialog
  const AddEventDialog({
    required this.selectedDate,
    required this.onEventAdded,
    super.key,
  });

  /// Selected date for the event
  final DateTime selectedDate;
  /// Callback when event is added
  final void Function(CalendarEvent) onEventAdded;

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  EventType _selectedType = EventType.custom;
  bool _isReminder = false;
  String? _selectedCrop;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: const Text('Add Event'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                items: EventType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Set Reminder'),
                value: _isReminder,
                onChanged: (value) {
                  setState(() {
                    _isReminder = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveEvent,
          child: const Text('Save'),
        ),
      ],
    );

  /// Select date for the event
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  /// Save the event
  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final event = CalendarEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        type: _selectedType,
        isReminder: _isReminder,
        cropName: _selectedCrop,
      );
      
      widget.onEventAdded(event);
      Navigator.of(context).pop();
    }
  }
}

/// Calendar event model
class CalendarEvent {
  /// Creates a calendar event
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.isReminder = false,
    this.cropName,
  });

  /// Creates a calendar event from JSON
  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      type: EventType.values[json['type'] as int],
      isReminder: json['isReminder'] as bool? ?? false,
      cropName: json['cropName'] as String?,
    );

  /// Event ID
  final String id;
  /// Event title
  final String title;
  /// Event description
  final String description;
  /// Event date
  final DateTime date;
  /// Event type
  final EventType type;
  /// Whether reminder is set
  final bool isReminder;
  /// Associated crop name
  final String? cropName;

  /// Converts event to JSON
  Map<String, dynamic> toJson() => {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.index,
      'isReminder': isReminder,
      'cropName': cropName,
    };
}

/// Event types enum
enum EventType {
  /// Crop activity event
  cropActivity,
  /// Custom event
  custom,
  /// Reminder event
  reminder,
  /// Weather event
  weather,
}

/// Extension for EventType display names
extension EventTypeExtension on EventType {
  /// Gets display name for event type
  String get displayName {
    switch (this) {
      case EventType.cropActivity:
        return 'Crop Activity';
      case EventType.custom:
        return 'Custom';
      case EventType.reminder:
        return 'Reminder';
      case EventType.weather:
        return 'Weather';
    }
  }
}

/// Crop schedule model
class CropSchedule {
  /// Creates a crop schedule
  const CropSchedule({
    required this.cropName,
    required this.activities,
  });

  /// Creates crop schedule from JSON
  factory CropSchedule.fromJson(Map<String, dynamic> json) => CropSchedule(
      cropName: json['crop_name'] as String,
      activities: (json['activities'] as List<dynamic>)
          .map<ActivitySchedule>((activity) => ActivitySchedule.fromJson(activity as Map<String, dynamic>))
          .toList(),
    );

  /// Crop name
  final String cropName;
  /// List of activities
  final List<ActivitySchedule> activities;
}

/// Activity schedule model
class ActivitySchedule {
  /// Creates an activity schedule
  const ActivitySchedule({
    required this.activity,
    required this.description,
    required this.month,
    required this.day,
  });

  /// Creates activity schedule from JSON
  factory ActivitySchedule.fromJson(Map<String, dynamic> json) => ActivitySchedule(
      activity: json['activity'] as String,
      description: json['description'] as String,
      month: json['month'] as int,
      day: json['day'] as int,
    );

  /// Activity name
  final String activity;
  /// Activity description
  final String description;
  /// Month of activity
  final int month;
  /// Day of activity
  final int day;
}

/// Farming tip model
class FarmingTip {
  /// Creates a farming tip
  const FarmingTip({
    required this.title,
    required this.description,
    required this.category,
    this.season,
  });

  /// Creates farming tip from JSON
  factory FarmingTip.fromJson(Map<String, dynamic> json) => FarmingTip(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      season: json['season'] as String?,
    );

  /// Tip title
  final String title;
  /// Tip description
  final String description;
  /// Tip category
  final String category;
  /// Best season for tip
  final String? season;
}