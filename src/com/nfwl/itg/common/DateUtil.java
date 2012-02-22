package com.nfwl.itg.common;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class DateUtil {

	private static final String DEFAULT_TIME_FORMAT = "yyyy-MM-dd";

	private static final String DEFAULT_DATE_SEPARATOR = "-";

	private static final String DEFAULT_OPERATE_TIME_FORMAT = "yyyy-MM-dd hh:mm";

	/**
	 * Get current date
	 * 
	 * @return java.util.Date
	 */
	public static java.util.Date getCurrentDate() {
		Calendar c = Calendar.getInstance();
		return c.getTime();
	}

	/**
	 * Get current year
	 * 
	 * @return int
	 */
	public static int getCurrentYear() {
		Calendar c = Calendar.getInstance();
		return getYear(c.getTime());
	}

	/**
	 * Get current month
	 * 
	 * @return int
	 */
	public static int getCurrentMonth() {
		Calendar c = Calendar.getInstance();
		return getMonth(c.getTime());
	}

	public static int getMonth(Date time) {
		Calendar c = Calendar.getInstance();
		c.setTime(time);
		return c.get(Calendar.MONTH);
	}

	/**
	 * Get current minute
	 * 
	 * @return int
	 */
	public static int getCurrentMinute() {
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.MINUTE);
	}

	/**
	 * Get current second
	 * 
	 * @return int
	 */
	public static int getCurrentSecond() {
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.SECOND);
	}

	/**
	 * Get current second
	 * 
	 * @return int
	 */
	public static int getCurrentMillSecond() {
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.MILLISECOND);
	}

	/**
	 * Get current day in the month
	 * 
	 * @return int
	 */
	public static int getCurrentDay() {
		Calendar c = Calendar.getInstance();
		return getDay(c.getTime());
	}

	public static int getDay(Date time) {
		Calendar c = Calendar.getInstance();
		c.setTime(time);
		return c.get(Calendar.DAY_OF_MONTH);
	}

	/**
	 * Get current hour
	 * 
	 * @return int
	 */
	public static int getCurrentHour() {
		Calendar c = Calendar.getInstance();
		return c.get(Calendar.HOUR_OF_DAY);
	}

	/**
	 * Construct the Date object according to the string and the specifed
	 * format.
	 * 
	 * @param dateValue
	 * @param dateFormat
	 * @return Date
	 */
	public static java.util.Date string2Date(String dateValue, String dateFormat) {
		return string2Date(dateValue, dateFormat, null);
	}

	/**
	 * Parse string to date according to the specified format,if exception
	 * occurs,return the specified default value
	 * 
	 * @param dateValue
	 * @param dateFormat
	 * @param defaultValue
	 * @return date
	 */
	public static java.util.Date string2Date(String dateValue,
			String dateFormat, Date defaultValue) {
		java.util.Date date = null;
		try {
			SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
			date = sdf.parse(dateValue);
		} catch (Exception eDate) {
			return defaultValue;
		}
		return date;
	}

	/**
	 * Parse the given string into date.
	 * 
	 * @param dateValue
	 * @return Date
	 */
	public static Date string2Date(String dateValue) {
		return string2Date(dateValue, DEFAULT_TIME_FORMAT);
	}

	/**
	 * Parse string to date according to the specified format,if exception
	 * occurs,return null
	 * 
	 * @param dateValue
	 * @param defaultValue
	 * @return
	 */
	public static Date string2Date(String dateValue, Date defaultValue) {
		return string2Date(dateValue, DEFAULT_TIME_FORMAT, defaultValue);
	}

	/**
	 * Parse string to date according to year and month ,if exception
	 * occurs,return null
	 * 
	 * @param dateValue
	 * @return
	 */
	public static Date stringYearMonth2Date(String dateValue) {
		if (dateValue == null || dateValue.trim().length() < 1)
			return null;
		return string2Date(dateValue + DEFAULT_DATE_SEPARATOR + "01");
	}

	/**
	 * Adds the specified (signed) amount of time to the date time field.
	 * 
	 * @param date
	 * @param days
	 * @return date
	 */
	public static Date addDate(Date date, int days) {
		if (date == null)
			return date;
		Calendar c = Calendar.getInstance();
		c.setTime(date);
		c.add(Calendar.DATE, days);
		return c.getTime();
	}

	/**
	 * Adds the specified (signed) amount of time to the date time field.
	 * 
	 * @param date
	 * @param months
	 * @return date
	 */
	public static Date addMonth(Date date, int months) {
		if (date == null)
			return date;
		Calendar c = Calendar.getInstance();
		c.setTime(date);
		c.add(Calendar.MONTH, months);
		return c.getTime();
	}

	/**
	 * Adds the specified (signed) amount of time to the date time field.
	 * 
	 * @param date
	 * @param months
	 * @return date
	 */
	public static Date addYear(Date date, int years) {
		if (date == null)
			return date;
		Calendar c = Calendar.getInstance();
		c.setTime(date);
		c.add(Calendar.YEAR, years);
		return c.getTime();
	}

	/**
	 * Parse the give date time to string format with the default time format
	 * 
	 * @param dateValue
	 * @return string
	 */
	public static String date2String(Date dateValue) {
		return date2String(dateValue, DEFAULT_TIME_FORMAT);
	}

	/**
	 * Parse the give date time to string format with the default time format
	 * for operate
	 * 
	 * @param dateValue
	 * @return string
	 */
	public static String date2StringOperate(Date dateValue) {
		return date2String(dateValue, DEFAULT_OPERATE_TIME_FORMAT);
	}

	/**
	 * Parse the given time to string format
	 * 
	 * @param dateValue
	 * @param dateFormat
	 * @return string
	 */
	public static String date2String(java.util.Date dateValue, String dateFormat) {
		if (dateValue == null)
			return "";
		String sDate = null;
		try {
			SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
			sDate = sdf.format(dateValue);
		} catch (Exception ex) {
			ex.printStackTrace();
			throw new IllegalArgumentException(ex.getMessage());
		}
		return sDate;
	}

	/**
	 * Returns the time when is the fist monday from now on. Hours,minutes,and
	 * seconds are all set to be zero.
	 * 
	 * @return time
	 */
	public static Calendar getFirstMondayFrom() {
		Calendar c = Calendar.getInstance();
		c.set(Calendar.HOUR, 0);
		c.set(Calendar.MINUTE, 0);
		c.set(Calendar.SECOND, 0);
		c.set(Calendar.MILLISECOND, 0);
		return getFirstMondayFrom(c);
	}

	/**
	 * Returns the time when is the fist month day from now on.
	 * Hours,minutes,and seconds are all set to be zero.
	 * 
	 * @return time
	 */
	public static Date getNextMonthStartFrom(Date date) {
		Calendar c = Calendar.getInstance();
		date = DateUtil.addMonth(date, 1);
		c.setTime(date);
		c.set(Calendar.DAY_OF_MONTH, 0);
		c.set(Calendar.HOUR, 0);
		c.set(Calendar.MINUTE, 0);
		c.set(Calendar.SECOND, 0);
		c.set(Calendar.MILLISECOND, 0);
		return c.getTime();
	}

	/**
	 * Returns the time when is the fist monday from now on. Hours,minutes,and
	 * seconds are all set to be zero.
	 * 
	 * @return time
	 */
	public static Calendar getFirstMondayFrom(Date date) {
		Calendar c = Calendar.getInstance();
		c.setTime(date);
		return getFirstMondayFrom(c);
	}

	/**
	 * Returns the time when is the fist monday from the given time.
	 * Hours,minutes,and seconds are all set to be zero.
	 * 
	 * @return time
	 */
	public static Calendar getFirstMondayFrom(Calendar c) {
		for (int dow = c.get(Calendar.DAY_OF_WEEK); dow != Calendar.MONDAY; dow = c
				.get(Calendar.DAY_OF_WEEK)) {
			c.add(Calendar.DATE, 1);
		}
		return c;
	}

	/**
	 * Format time by the default time.
	 * 
	 * @param time
	 * @return string
	 */
	public static String format(Date time) {
		return format(time, DEFAULT_TIME_FORMAT);
	}

	/**
	 * Format time by the specified time.
	 * 
	 * @param time
	 * @param format
	 * @return
	 */
	public static String format(Date time, String format) {
		if (time == null)
			return null;
		try {
			SimpleDateFormat sdf = new SimpleDateFormat(format);
			return sdf.format(time);
		} catch (Exception eDate) {
			return time.toString();
		}
	}

	/**
	 * Returns year of the specified time.
	 * 
	 * @param time
	 * @return year
	 */
	public static int getYear(Date time) {
		Calendar c = Calendar.getInstance();
		c.setTime(time);
		return c.get(Calendar.YEAR);
	}

	/**
	 * Returns true iff the specified time is <code>Sunday</code>
	 * 
	 * @param time
	 * @return
	 */
	public static boolean isSunday(Date time) {
		Calendar c = Calendar.getInstance();
		c.setTime(time);
		return c.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY;
	}

	public static Date getMonday4Sunday2Saturday(Date date) {
		if (date == null)
			throw new NullPointerException(" specified date is null");

		Calendar c = Calendar.getInstance();
		c.setTime(date);
		c.set(Calendar.HOUR, 0);
		c.set(Calendar.MINUTE, 0);
		c.set(Calendar.SECOND, 0);
		c.set(Calendar.MILLISECOND, 0);
		if (c.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY)
			c.add(Calendar.DATE, 1);
		else
			while (c.get(Calendar.DAY_OF_WEEK) != Calendar.MONDAY)
				c.add(Calendar.DATE, -1);

		return c.getTime();
	}

	/**
	 * Returns the time when is the monday of the current week.
	 * 
	 * @return Date
	 */
	public static Date getMondayOfWeek() {
		return getMondayOfWeek(getCurrentDate());
	}

	/**
	 * Returns the time when is the monday of the current week.
	 * 
	 * @param thisWeek
	 * @return Date
	 */
	public static Date getMondayOfWeek(Date thisWeek) {
		Calendar c = Calendar.getInstance();
		c.setTime(thisWeek);
		c.set(Calendar.HOUR, 0);
		c.set(Calendar.MINUTE, 0);
		c.set(Calendar.SECOND, 0);
		c.set(Calendar.MILLISECOND, 0);
		while (c.get(Calendar.DAY_OF_WEEK) != Calendar.MONDAY)
			c.add(Calendar.DATE, -1);
		return c.getTime();
	}
	
	
	
	
}
