class Utils {
  String getTimeDifference(String time) {
    DateTime creationTime = DateTime.parse(time);

    Duration difference = DateTime.now().difference(creationTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return "${difference.inDays}d";
      } else if (difference.inDays > 365) {
        return "${difference.inDays ~/ 365}Y";
      } else if (difference.inDays > 30) {
        return "${difference.inDays ~/ 30}M";
      } else {
        return "${difference.inDays}d";
      }
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m";
    } else {
      return "${difference.inSeconds}s";
    }
  }

  String truncate(String text, int length) {
    if (text.length > length) {
      return "${text.substring(0, length)}...";
    } else {
      return text;
    }
  }
}
