import 'package:common_utils/common_utils.dart';

class AgoraTimeTool {
  static String timeStrByMs(int ms, {bool showTime = false}) {
    String ret = '';
    // 是否当天
    // HH:mm
    if (DateUtil.isToday(ms)) {
      ret = DateUtil.formatDateMs(ms, format: 'HH:mm');
    }
    // // 是否本周
    // // 周一、周二、周三...
    // else if (DateUtil.isWeek(ms)) {
    //   ret = DateUtil.getWeekdayByMs(ms);
    // }

    // 是否本年
    // MM/dd
    else if (DateUtil.yearIsEqualByMs(ms, DateUtil.getNowDateMs())) {
      if (showTime) {
        ret = DateUtil.formatDateMs(ms, format: 'MM月dd日 HH:mm');
      } else {
        ret = DateUtil.formatDateMs(ms, format: 'MM月dd日');
      }
    }
    // yyyy/MM/dd
    else {
      if (showTime) {
        ret = DateUtil.formatDateMs(ms, format: 'yyyy年MM月dd日 HH:mm');
      } else {
        ret = DateUtil.formatDateMs(ms, format: 'yyyy年MM月dd日');
      }
    }

    return ret;
  }

  static String durationStr(int duration) {
    if (duration <= 60) {
      return "${duration.toInt()}\"";
    } else if (duration > 60 && duration < 3600) {
      return "${(duration / 60).truncate().toInt()}'${(duration % 60).toInt()}\"";
    } else {
      return "${(duration / 3600).truncate().toInt()}h${(duration % 3600 / 60).truncate().toInt()}'${(duration % 3600 % 60).truncate().toInt()}\"";
    }
  }
}

class AgoraSizeTool {
  static String fileSize(int fileSize) {
    if (fileSize < 1024) {
      return "${fileSize}B";
    } else if (fileSize < 1024 * 1024) {
      return "${(fileSize / 1024).toStringAsFixed(2)}KB";
    } else if (fileSize < 1024 * 1024 * 1024) {
      return "${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB";
    } else {
      return "${(fileSize / 1024 / 1024 / 1024).toStringAsFixed(2)}GB";
    }
  }
}
