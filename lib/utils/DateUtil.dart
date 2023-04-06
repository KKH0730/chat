import 'package:chat/utils/RegionUtil.dart';
import 'package:easy_localization/easy_localization.dart';

class DateUtil {
  static String getChatLastDate(int timeinmillis) {
    // 현재 시각을 기준으로 한 로컬 시간을 얻습니다.
    DateTime currentDateTime = DateTime.now();

// timeinmillis에 해당하는 로컬 시간을 구합니다.
    DateTime targetDateTime = DateTime.fromMillisecondsSinceEpoch(timeinmillis);

// 날짜 차이를 계산합니다.
    Duration difference = currentDateTime.difference(targetDateTime).abs();
    int daysDifference = difference.inDays;

    if (daysDifference == 0) {
      // 오늘이라면 시간과 분을 추출하여 12시간 형식으로 출력합니다.
      int hour = targetDateTime.hour;
      String amOrPm = hour >= 12 ? "오후" : "오전";
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour;
      int minute = targetDateTime.minute;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else if (daysDifference == 1) {
      // 어제라면 "어제"를 출력합니다.
      return '어제';
    } else {
      // 그 외의 경우에는 날짜와 시간을 출력합니다.
      if (currentDateTime.year == targetDateTime.year) {
        // 년도가 같은 경우에는 월과 일만 출력합니다.
        return '${targetDateTime.month}월 ${targetDateTime.day}일';
      } else {
        // 년도가 다른 경우에는 년, 월, 일을 출력합니다.
        return '${targetDateTime.year}. ${targetDateTime.month}. ${targetDateTime.day}.';
      }
    }
  }

  static String transMillisecondToDate(int millisecond) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecond);

    var values = [];
    if (RegionUtil.getLanguageCode() == "ko") {
      values = [
        date.year.toString(),
        DateFormat('M').format(date).replaceAll('월', ''),
        DateFormat('dd').format(date),
        DateFormat('EEE').format(date)
      ];
    } else {
      values = [
        DateFormat('MMM').format(date),
        DateFormat('dd').format(date),
        date.year.toString(),
        DateFormat('EEE').format(date)
      ];
    }

    String format = 'date_format_yyyy_mm_dd_date'.tr();

    var i = 0;
    String str = format.replaceAllMapped(RegExp(r'\d+\$s'), (match) => values[i++]);
    return str;
  }

  static String transMillisecondToDate2(int millisecond) {
    DateTime todayDate = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecond);

    var values = [];
    String format = '';
    if (todayDate.year == date.year) {
      format = 'date_format_yyyy_mm_dd_date2'.tr();

      // ko -> 3월 2일, en -> Mar 2
      if (RegionUtil.getLanguageCode() == "ko") {
        values = [
          DateFormat('M').format(date).replaceAll('월', ''),
          DateFormat('dd').format(date)
        ];
      } else {
        values = [
          DateFormat('MMM').format(date),
          DateFormat('dd').format(date),
        ];
      }
    } else {
      format = 'date_format_yyyy_mm_dd_date3'.tr();

      // ko -> 2022년 3월 2일, en -> Mar 2, 2022
      if (RegionUtil.getLanguageCode() == "ko") {
        values = [
          date.year.toString(),
          DateFormat('M').format(date).replaceAll('월', ''),
          DateFormat('dd').format(date)
        ];
      } else {
        values = [
          DateFormat('MMM').format(date),
          DateFormat('dd').format(date),
          date.year.toString(),
        ];
      }
    }

    var i = 0;
    String str = format.replaceAllMapped(RegExp(r'\d+\$s'), (match) => values[i++]);
    return str;
  }

  static bool isSameDate(int date1, int date2) {
    DateTime date1Time = DateTime.fromMillisecondsSinceEpoch(date1);
    int year1 = date1Time.year;
    int month1 = date1Time.month;
    int day1 = date1Time.day;

    DateTime date2Time = DateTime.fromMillisecondsSinceEpoch(date2);
    int year2 = date2Time.year;
    int month2 = date2Time.month;
    int day2 = date2Time.day;

    if (year1 == year2 && month1 == month2 && day1 == day2) {
      return true;
    }

    return false;
  }
}
