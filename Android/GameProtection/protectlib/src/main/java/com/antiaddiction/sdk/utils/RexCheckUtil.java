package com.antiaddiction.sdk.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class RexCheckUtil {

    public static boolean checkPhone(String phone) {
//        String regex = "^((13[0-9])|(14[5,7])|(15[0-3,5-9])|(17[0-3,5-8])|(18[0-9])|166|198|199|(147))\\d{8}$";
//        Pattern p = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
//        Matcher m = p.matcher(phone);
//        return m.matches();
        return phone != null && phone.length() == 11;
    }

    public static boolean checkPassport(String passport){
        return null != passport && passport.length() == 9;
    }

    public static boolean checkShareCode(String code){
        if( null == code || code.length() < 6){
            return false;
        }
        try{
            Hashids hashids = new Hashids("AntiAddictionKit",6);
            long time = hashids.decode(code)[0];
            long current = new Date().getTime() / 1000;
            return current >= time && ((current - time) <= 6 * 3600);
        }catch (Exception e){
            return  false;
        }
    }

    public static boolean checkIdentify(String identify) {
        if (identify == null || "".equals(identify) || identify.length() != 18) {
            return false;
        }
        // 定义判别用户身份证号的正则表达式（15位或者18位，最后一位可以为字母）
        String regularExpression = "(^[1-9]\\d{5}(18|19|20)\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$)|" +
                "(^[1-9]\\d{5}\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}$)";

        boolean matches = identify.matches(regularExpression);
        //判断第18位校验值
        if (matches) {
            try {
                char[] charArray = identify.toCharArray();
                //前十七位加权因子
                int[] idCardWi = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2};
                //这是除以11后，可能产生的11位余数对应的验证码
                String[] idCardY = {"1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"};
                int sum = 0;
                for (int i = 0; i < idCardWi.length; i++) {
                    int current = Integer.parseInt(String.valueOf(charArray[i]));
                    int count = current * idCardWi[i];
                    sum += count;
                }
                char idCardLast = charArray[17];
                int idCardMod = sum % 11;
                return idCardY[idCardMod].toUpperCase().equals(String.valueOf(idCardLast).toUpperCase());
            } catch (Exception e) {
                e.printStackTrace();
                return false;
            }
        }
        return matches;
    }

    public static int getAgeFromIdentify(String identify) {
        String dateStr;
        if (identify.length() == 15) {
            dateStr = "19" + identify.substring(6, 12);
        } else{
            dateStr = identify.substring(6, 14);
        }
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd");
        try {
            Date birthday = simpleDateFormat.parse(dateStr);
            if( null != birthday) {
                return getAgeByDate(birthday);
            }
        } catch (ParseException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static String getBirthdayFromIdentify(String identify) {
        if(identify != null) {
            String dateStr;
            if (identify.length() == 15) {
                dateStr = "19" + identify.substring(6, 12);
            } else {
                dateStr = identify.substring(6, 14);
            }
            return dateStr;
        }
        return "";
    }


    public static int getAgeByDate(Date birthday) {
        Calendar calendar = Calendar.getInstance();
        if (calendar.getTimeInMillis() - birthday.getTime() < 0L) {
            return 0;
        }
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH);
        int day = calendar.get(Calendar.DAY_OF_MONTH);

        calendar.setTime(birthday);
        int yearBirthday = calendar.get(Calendar.YEAR);
        int monthBirthday = calendar.get(Calendar.MONTH);
        int dayOfMonthBirthday = calendar.get(Calendar.DAY_OF_MONTH);
        int age = year - yearBirthday;
        if (month == monthBirthday && day < dayOfMonthBirthday || month < monthBirthday) {
            age--;
        }
        return age;
    }


}
