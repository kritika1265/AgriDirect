import 'package:intl/intl.dart';

/// Data formatting utilities for AgriDirect app
class AppFormatters {
  // Date formatters
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM');

  /// Format date to readable string (DD/MM/YYYY)
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format time to readable string (HH:MM)
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// Format date and time to readable string (DD/MM/YYYY HH:MM)
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Format month and year (MMM YYYY)
  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  /// Format day and month (DD MMM)
  static String formatDayMonth(DateTime date) {
    return _dayMonthFormat.format(date);
  }

  /// Format relative time (e.g., "2 hours ago", "3 days ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Format currency (Indian Rupees)
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: symbol,
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }

  /// Format number with Indian numbering system (lakhs, crores)
  static String formatNumber(num number) {
    if (number >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)} Cr';
    } else if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(2)} L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format temperature
  static String formatTemperature(double temp, {bool celsius = true}) {
    return '${temp.toStringAsFixed(1)}°${celsius ? 'C' : 'F'}';
  }

  /// Format humidity
  static String formatHumidity(double humidity) {
    return '${humidity.toStringAsFixed(0)}%';
  }

  /// Format wind speed
  static String formatWindSpeed(double speed, {String unit = 'km/h'}) {
    return '${speed.toStringAsFixed(1)} $unit';
  }

  /// Format rainfall
  static String formatRainfall(double rainfall, {String unit = 'mm'}) {
    return '${rainfall.toStringAsFixed(1)} $unit';
  }

  /// Format area (hectares, acres)
  static String formatArea(double area, {String unit = 'ha'}) {
    if (unit == 'ha' && area < 1) {
      return '${(area * 10000).toStringAsFixed(0)} m²';
    }
    return '${area.toStringAsFixed(2)} $unit';
  }

  /// Format weight
  static String formatWeight(double weight, {String unit = 'kg'}) {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(2)} t';
    }
    return '${weight.toStringAsFixed(1)} $unit';
  }

  /// Format phone number (Indian format)
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    } else if (phone.length == 13 && phone.startsWith('+91')) {
      return '+91 ${phone.substring(3, 8)} ${phone.substring(8)}';
    }
    return phone;
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Format duration
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Capitalize first letter of each word
  static String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Format crop season
  static String formatCropSeason(String season) {
    switch (season.toLowerCase()) {
      case 'kharif':
        return 'Kharif (Jun-Oct)';
      case 'rabi':
        return 'Rabi (Nov-Apr)';
      case 'zaid':
        return 'Zaid (Mar-Jun)';
      default:
        return toTitleCase(season);
    }
  }

  /// Format soil pH
  static String formatSoilPH(double ph) {
    String category;
    if (ph < 5.5) {
      category = '(Acidic)';
    } else if (ph < 6.5) {
      category = '(Slightly Acidic)';
    } else if (ph < 7.5) {
      category = '(Neutral)';
    } else if (ph < 8.5) {
      category = '(Slightly Alkaline)';
    } else {
      category = '(Alkaline)';
    }
    return '${ph.toStringAsFixed(1)} $category';
  }

  /// Format NPK values
  static String formatNPK(double n, double p, double k) {
    return 'N:${n.toStringAsFixed(1)} P:${p.toStringAsFixed(1)} K:${k.toStringAsFixed(1)}';
  }

  /// Format crop yield
  static String formatYield(double yield, {String unit = 'kg/ha'}) {
    return '${yield.toStringAsFixed(1)} $unit';
  }
}