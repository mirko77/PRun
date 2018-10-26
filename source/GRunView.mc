using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.UserProfile;

const CONVERSION_KM_TO_MILE = 0.62137119;
const CONVERSION_METER_TO_FEET = 3.28084;
const LENGTH_GPS_ICON = 28;
const LENGTH_BATTERY_ICON = 50;


class GRunView extends WatchUi.DataField
{
  // Array of the current heart rate zone threshold values in beats per minute (bpm)
  private var hrZones;
  // Integer indicating the current km or mile. For example, if the distance currently traveled is 3.25 km, the variable will be equal to 3.
  private var currentKM;
  // Time taken on current km/mile
  private var timerCurrentKM;
  // Time taken on previous km or mile
  private var timerLastKM;
  // Exact time when "currentKM" was last changed
  private var startTimerCurrentKM;
  // ETA
  private var eta5k;
  private var eta10k;
  private var etaHalfMarathon;
  private var etaMarathon;
  
  // Header Position change the layout. Possible values are 1, 2 and 3
  private var headerPosition;
  // By default, the layout has 3 columns with the same width. middleColumnPercentageSize is used to reduce or enlarge the middle column.
  // middleColumnPercentageSize value must be between 0 and 100. It's a percentage value. If the value = 150, the width will be 150% larger.
  // If the value = 50, the width wil be 50% smaller. This can be useful to set value with format like 00:00 and the left/right and
  // keep decimal values (Example: Cadence) in the middle
  private var middleColumnPercentageSize;
  // If pace is lower than minPace, it will be displayed in blue
  // If pace is between minPace and maxPace, it will be displayed in green
  // If pace is greater than maxPace, it will be displayed in red
  private var minPace;
  private var maxPace;
  
  // vX variables are used to stored the type of data each area will display (Exemple: Current Pace, Distance, etc.)
  private var v1, v2, v3, v4, v5, v6, v7, v8, v9, v10;
  // vXdata variables contains the actuel value to display. For example, if v1 is configure to display current pace, v1data will display MM:SS
  private var v1data, v2data, v3data, v4data, v5data, v6data, v7data, v8data, v9data, v10data;
  // hXarea indicates the x/y coordonate of the Header area while vXarea indicates the x/y coordonate of the Value area
  private var v1area, h2area, v2area, h3area, v3area, h4area, v4area, h5area, v5area, h6area, v6area, h7area, v7area, v8area, v9area, v10area;
  
  // Device Model
  private var deviceModel;
  // Width of the device screen in pixels
  private var deviceWidth;
  // Height of the device screen in pixels
  private var deviceHeight;
  
  // Fonts used by the DataField.
  // Note: "NUMBER" fonts are larger, but only contain numeric values to save memory
  // The following fonts are used on vivoactive3:
  //  - FONT_XTINY:  FNT_NOTO_SANS_BOLD_16PX
  //  - FONT_TINY:   FNT_NOTO_SANS_BOLD_22PX
  //  - FONT_SMALL:  FNT_NOTO_SANS_BOLD_22PX
  //  - FONT_MEDIUM: FNT_NOTO_SANS_BOLD_25PX
  //  - FONT_LARGE:  FNT_NOTO_SANS_BOLD_25PX
  //  - 
  //  - FONT_NUMBER_MILD:     FNT_NOTO_SANS_BOLD_29PX
  //  - FONT_NUMBER_MEDIUM:   FNT_NOTO_SANS_BOLD_NMBR_48PX
  //  - FONT_NUMBER_HOT:      FNT_NOTO_SANS_BOLD_NMBR_76PX
  //  - FONT_NUMBER_THAI_HOT: FNT_NOTO_SANS_BOLD_NMBR_94PX 
  private var fontIcons;
  private var fontTiny;
  private var fontTinyHeader;
  private var fontSmallHeader;
  private var fontMediumHeader;
  private var fontSmallNumericValue;
  private var fontMediumNumericValue;
  
  enum {
    OPTION_EMPTY = 0,
    OPTION_CURRENT_TIME = 1,
    OPTION_TIMER_TIME = 2,
    OPTION_TIMER_TIME_ON_CURRENT_KM_OR_MILE = 3,
    OPTION_PREVIOUS_KM_OR_MILE = 4,
    OPTION_ELAPSED_DISTANCE = 5,
    OPTION_CURRENT_HEART_RATE = 6,
    OPTION_CURRENT_PACE = 7,
    OPTION_CURRENT_SPEED = 8,
    OPTION_AVERAGE_HEART_RATE = 9,
    OPTION_AVERAGE_PACE = 10,
    OPTION_AVERAGE_PACE_MANUAL_CALC = 11,
    OPTION_AVERAGE_SPEED = 12,
    OPTION_CALORIES = 13,
    OPTION_CURRENT_CADENCE = 14,
    OPTION_ALTITUDE = 15,
    OPTION_TOTAL_ASCENT = 16,
    OPTION_TOTAL_DESCENT = 17,
    OPTION_CURRENT_BATTERY = 18,
    OPTION_CURRENT_LOCATION_ACCURACY = 19,
    OPTION_CURRENT_LOCATION_ACCURACY_AND_BATTERY = 20,
    OPTION_ETA_5K = 21,
    OPTION_ETA_10K = 22,
    OPTION_ETA_HALF_MARATHON = 23,
    OPTION_ETA_MARATHON = 24
    /*
    OPTION_AMBIENT_PRESSURE = 25,
    OPTION_AVERAGE_CADENCE = 26,
    OPTION_AVERAGE_DISTANCE = 27,
    OPTION_AVERAGE_POWER = 28,
    OPTION_BEARING = 29,
    OPTION_BEARING_FROM_START = 30,
    OPTION_CURRENT_HEADING = 31,
    OPTION_CURRENT_LOCATION = 32,
    OPTION_CURRENT_POWER = 33,
    OPTION_DISTANCE_TO_DESTINATION = 34,
    OPTION_DISTANCE_TO_NEXT_POINT = 35,
    OPTION_ELAPSED_TIME = 36,
    OPTION_ELEVATION_AT_DESTINATION = 37,
    OPTION_ELEVATION_AT_NEXT_POINT = 38,
    OPTION_ENERGY_EXPENDITURE = 39,
    OPTION_FRONT_DERAILLEUR_INDEX = 40,
    OPTION_FRONT_DERAILLEUR_MAX = 41,
    OPTION_FRONT_DERAILLEUR_SIZE = 42,
    OPTION_MAX_CADENCE = 43,
    OPTION_MAX_HEART_RATE = 44,
    OPTION_MAX_POWER = 45,
    OPTION_MAX_SPEED = 46,
    OPTION_MEAN_SEA_LEVEL_PRESSURE = 47,
    OPTION_NAME_OF_DESTINATION = 48,
    OPTION_NAME_OF_NEXT_POINT = 49,
    OPTION_OFF_COURSE_DISTANCE = 50,
    OPTION_RAW_AMBIENT_PRESSURE = 51,
    OPTION_REAR_DERAILLEUR_INDEX = 52,
    OPTION_REAR_DERAILLEUR_MAX = 53,
    OPTION_REAR_DERAILLEUR_SIZE = 54,
    OPTION_START_LOCATION = 55,
    OPTION_START_TIME = 56,
    OPTION_SWIM_STROKE_TYPE = 57,
    OPTION_SWIM_SWOLF = 58,
    OPTION_TIMER_STATE = 59,
    OPTION_TRACK = 60,
    OPTION_TRAINING_EFFECT = 61
    */
  }
  
  /* Uncomment for debug purpose only. This part of code is commented to optimize memory usage
  function log(text)
  {
    var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var formattedDate = date.year + "-" + date.month.format("%02d") + "-" + date.day.format("%02d") + " " + date.hour.format("%02d") + ":" + date.min.format("%02d") + ":" + date.sec.format("%02d");
    System.println(formattedDate + " " + text);
  }
  
  function getOptionName(type)
  {
    switch (type)
    {
      case OPTION_ALTITUDE:
        return "OPTION_ALTITUDE";
      
      case OPTION_AMBIENT_PRESSURE:
        return "OPTION_AMBIENT_PRESSURE";
      
      case OPTION_AVERAGE_CADENCE:
        return "OPTION_AVERAGE_CADENCE";
      
      case OPTION_AVERAGE_DISTANCE:
        return "OPTION_AVERAGE_DISTANCE";
      
      case OPTION_AVERAGE_HEART_RATE:
        return "OPTION_AVERAGE_HEART_RATE";
      
      case OPTION_AVERAGE_PACE:
        return "OPTION_AVERAGE_PACE";
      
      case OPTION_AVERAGE_PACE_MANUAL_CALC:
        return "OPTION_AVERAGE_PACE_MANUAL_CALC";
      
      case OPTION_AVERAGE_POWER:
        return "OPTION_AVERAGE_POWER";
      
      case OPTION_AVERAGE_SPEED:
        return "OPTION_AVERAGE_SPEED";
      
      case OPTION_BEARING:
        return "OPTION_BEARING";
      
      case OPTION_BEARING_FROM_START:
        return "OPTION_BEARING_FROM_START";
      
      case OPTION_CALORIES:
        return "OPTION_CALORIES";
      
      case OPTION_CURRENT_BATTERY:
        return "OPTION_CURRENT_BATTERY";
      
      case OPTION_CURRENT_CADENCE:
        return "OPTION_CURRENT_CADENCE";
      
      case OPTION_CURRENT_HEADING:
        return "OPTION_CURRENT_HEADING";
      
      case OPTION_CURRENT_HEART_RATE:
        return "OPTION_CURRENT_HEART_RATE";
      
      case OPTION_CURRENT_LOCATION:
        return "OPTION_CURRENT_LOCATION";
      
      case OPTION_CURRENT_LOCATION_ACCURACY:
        return "OPTION_CURRENT_LOCATION_ACCURACY";
      
      case OPTION_CURRENT_LOCATION_ACCURACY_AND_BATTERY:
        return "OPTION_CURRENT_LOCATION_ACCURACY_AND_BATTERY";
      
      case OPTION_CURRENT_PACE:
        return "OPTION_CURRENT_PACE";
      
      case OPTION_CURRENT_POWER:
        return "OPTION_CURRENT_POWER";
      
      case OPTION_CURRENT_SPEED:
        return "OPTION_CURRENT_SPEED";
      
      case OPTION_CURRENT_TIME:
        return "OPTION_CURRENT_TIME";
      
      case OPTION_DISTANCE_TO_DESTINATION:
        return "OPTION_DISTANCE_TO_DESTINATION";
      
      case OPTION_DISTANCE_TO_NEXT_POINT:
        return "OPTION_DISTANCE_TO_NEXT_POINT";
      
      case OPTION_ELAPSED_DISTANCE:
        return "OPTION_ELAPSED_DISTANCE";
      
      case OPTION_ELAPSED_TIME:
        return "OPTION_ELAPSED_TIME";
      
      case OPTION_ELEVATION_AT_DESTINATION:
        return "OPTION_ELEVATION_AT_DESTINATION";
      
      case OPTION_ELEVATION_AT_NEXT_POINT:
        return "OPTION_ELEVATION_AT_NEXT_POINT";
      
      case OPTION_ENERGY_EXPENDITURE:
        return "OPTION_ENERGY_EXPENDITURE";
      
      case OPTION_FRONT_DERAILLEUR_INDEX:
        return "OPTION_FRONT_DERAILLEUR_INDEX";
      
      case OPTION_FRONT_DERAILLEUR_MAX:
        return "OPTION_FRONT_DERAILLEUR_MAX";
      
      case OPTION_FRONT_DERAILLEUR_SIZE:
        return "OPTION_FRONT_DERAILLEUR_SIZE";
      
      case OPTION_MAX_CADENCE:
        return "OPTION_MAX_CADENCE";
      
      case OPTION_MAX_HEART_RATE:
        return "OPTION_MAX_HEART_RATE";
      
      case OPTION_MAX_POWER:
        return "OPTION_MAX_POWER";
      
      case OPTION_MAX_SPEED:
        return "OPTION_MAX_SPEED";
      
      case OPTION_MEAN_SEA_LEVEL_PRESSURE:
        return "OPTION_MEAN_SEA_LEVEL_PRESSURE";
      
      case OPTION_NAME_OF_DESTINATION:
        return "OPTION_NAME_OF_DESTINATION";
      
      case OPTION_NAME_OF_NEXT_POINT:
        return "OPTION_NAME_OF_NEXT_POINT";
      
      case OPTION_OFF_COURSE_DISTANCE:
        return "OPTION_OFF_COURSE_DISTANCE";
      
      case OPTION_PREVIOUS_KM_OR_MILE:
        return "OPTION_PREVIOUS_KM_OR_MILE";
      
      case OPTION_RAW_AMBIENT_PRESSURE:
        return "OPTION_RAW_AMBIENT_PRESSURE";
      
      case OPTION_REAR_DERAILLEUR_INDEX:
        return "OPTION_REAR_DERAILLEUR_INDEX";
      
      case OPTION_REAR_DERAILLEUR_MAX:
        return "OPTION_REAR_DERAILLEUR_MAX";
      
      case OPTION_REAR_DERAILLEUR_SIZE:
        return "OPTION_REAR_DERAILLEUR_SIZE";
      
      case OPTION_START_LOCATION:
        return "OPTION_START_LOCATION";
      
      case OPTION_START_TIME:
        return "OPTION_START_TIME";
      
      case OPTION_SWIM_STROKE_TYPE:
        return "OPTION_SWIM_STROKE_TYPE";
      
      case OPTION_SWIM_SWOLF:
        return "OPTION_SWIM_SWOLF";
      
      case OPTION_TIMER_STATE:
        return "OPTION_TIMER_STATE";
      
      case OPTION_TIMER_TIME:
        return "OPTION_TIMER_TIME";
      
      case OPTION_TIMER_TIME_ON_CURRENT_KM_OR_MILE:
        return "OPTION_TIMER_TIME_ON_CURRENT_KM_OR_MILE";
      
      case OPTION_TOTAL_ASCENT:
        return "OPTION_TOTAL_ASCENT";
      
      case OPTION_TOTAL_DESCENT:
        return "OPTION_TOTAL_DESCENT";
      
      case OPTION_TRACK:
        return "OPTION_TRACK";
      
      case OPTION_TRAINING_EFFECT:
        return "OPTION_TRAINING_EFFECT";
      
      case OPTION_ETA_5K:
        return "OPTION_ETA_5K";
      
      case OPTION_ETA_10K:
        return "OPTION_ETA_10K";
      
      case OPTION_ETA_HALF_MARATHON:
        return "OPTION_ETA_HALF_MARATHON";
      
      case OPTION_ETA_MARATHON:
        return "OPTION_ETA_MARATHON";
    }
  }
  */
  
  function getParameter(paramName, defaultValue)
  {
    var paramValue = Application.Properties.getValue(paramName);
    if (paramValue == null) { 
      paramValue = defaultValue;
      Application.Properties.setValue(paramName, defaultValue);
    }
    
    if (paramValue == OPTION_EMPTY) { return null; }
    return paramValue;
  }
  

  function initializeUserData()
  {
    headerPosition = getParameter("HeaderPosition", 1);
    middleColumnPercentageSize = getParameter("MiddleColumnPercentageSize", 75);
    
    if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
      minPace = getParameter("MinPace", 510);
      maxPace = getParameter("MaxPace", 555);
    }
    
    else {
      minPace = getParameter("MinPace", 315);
      maxPace = getParameter("MaxPace", 345);
    }
        
    // Select which values are displayed in each area
    // Value must be selected according to the enum
    // The following options are currently supported:
    //  - OPTION_EMPTY = 0
    //  - OPTION_CURRENT_TIME = 1
    //  - OPTION_TIMER_TIME = 2
    //  - OPTION_TIMER_TIME_ON_CURRENT_KM_OR_MILE = 3
    //  - OPTION_PREVIOUS_KM_OR_MILE = 4
    //  - OPTION_ELAPSED_DISTANCE = 5
    //  - OPTION_CURRENT_HEART_RATE = 6
    //  - OPTION_CURRENT_PACE = 7
    //  - OPTION_CURRENT_SPEED = 8
    //  - OPTION_AVERAGE_HEART_RATE = 9
    //  - OPTION_AVERAGE_PACE = 10
    //  - OPTION_AVERAGE_PACE_MANUAL_CALC = 11
    //  - OPTION_AVERAGE_SPEED = 12
    //  - OPTION_CALORIES = 13
    //  - OPTION_CURRENT_CADENCE = 14
    //  - OPTION_ALTITUDE = 15
    //  - OPTION_TOTAL_ASCENT = 16
    //  - OPTION_TOTAL_DESCENT = 17
    //  - OPTION_CURRENT_BATTERY = 18
    //  - OPTION_CURRENT_LOCATION_ACCURACY = 19
    //  - OPTION_CURRENT_LOCATION_ACCURACY_AND_BATTERY = 20
    //  - OPTION_ETA_5K = 21
    //  - OPTION_ETA_10K = 22
    //  - OPTION_ETA_HALF_MARATHON = 23
    //  - OPTION_ETA_MARATHON = 24
    v1 = getParameter("Area1", OPTION_CURRENT_HEART_RATE);
    v2 = getParameter("Area2", OPTION_PREVIOUS_KM_OR_MILE);
    v3 = getParameter("Area3", OPTION_CURRENT_CADENCE);
    v4 = getParameter("Area4", OPTION_CURRENT_PACE);
    v5 = getParameter("Area5", OPTION_ELAPSED_DISTANCE);
    v6 = getParameter("Area6", OPTION_ALTITUDE);
    v7 = getParameter("Area7", OPTION_AVERAGE_PACE);
    v8 = getParameter("Area8", OPTION_TIMER_TIME);
    v9 = getParameter("Area9", OPTION_CURRENT_TIME);
    v10 = getParameter("Area10", OPTION_CURRENT_LOCATION_ACCURACY_AND_BATTERY);
    
    hrZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
    
    deviceModel = WatchUi.loadResource(Rez.Strings.DeviceModel);
    deviceWidth = System.getDeviceSettings().screenWidth;
    deviceHeight = System.getDeviceSettings().screenHeight;
    
    /*
    log("HeaderPosition: " + headerPosition);
    log("Area 1: " + getOptionName(v1));
    log("Area 2: " + getOptionName(v2));
    log("Area 3: " + getOptionName(v3));
    log("Area 4: " + getOptionName(v4));
    log("Area 5: " + getOptionName(v5));
    log("Area 6: " + getOptionName(v6));
    log("Area 7: " + getOptionName(v7));
    log("Area 8: " + getOptionName(v8));
    log("Area 9: " + getOptionName(v9));
    log("HR Zones: " + hrZones);
    */
  }
  
  
  function initDataVariables(v)
  {
    //if ( (v == OPTION_CURRENT_HEART_RATE) || (v == OPTION_AVERAGE_HEART_RATE) || (v == OPTION_MAX_HEART_RATE) )
    if ( (v == OPTION_CURRENT_HEART_RATE) || (v == OPTION_AVERAGE_HEART_RATE) )
    {
      return "--";
    }
    
    if (v == OPTION_CURRENT_LOCATION_ACCURACY)
    {
      return -1;
    }
    
    if (v == OPTION_CURRENT_TIME)
    {
      return System.getClockTime();
    }
    
    if (v == OPTION_CURRENT_LOCATION_ACCURACY_AND_BATTERY)
    {
      return -1;
    }
    
    return 0;
  }
  
 
  function initialize()
  {
    DataField.initialize();
    initializeUserData();
    
    v1data = initDataVariables(v1);
    v2data = initDataVariables(v2);
    v3data = initDataVariables(v3);
    v4data = initDataVariables(v4);
    v5data = initDataVariables(v5);
    v6data = initDataVariables(v6);
    v7data = initDataVariables(v7);
    v8data = initDataVariables(v8);
    v9data = initDataVariables(v9);
    v10data = initDataVariables(v10);
    
    currentKM = 0;
    timerLastKM = 0;
    startTimerCurrentKM = 0;
    timerCurrentKM = 0;
   
    fontIcons = WatchUi.loadResource(Rez.Fonts.Icons);
    fontTiny = WatchUi.loadResource(Rez.Fonts.Roboto_20_Bold);
    fontTinyHeader = Graphics.FONT_XTINY;
    fontSmallHeader = Graphics.FONT_SMALL;
    fontMediumHeader = Graphics.FONT_MEDIUM;
    fontSmallNumericValue = Graphics.FONT_NUMBER_MILD;
    fontMediumNumericValue = Graphics.FONT_NUMBER_MEDIUM;
    
    var columnWidth = deviceWidth / 3;
    var x1 = 0;
    var x2 = columnWidth;
    var x3 = columnWidth * 2;
    
    var headerHeight = deviceHeight * 25/240;
    var valueHeight = deviceHeight * 45/240;
    
    var y1 = deviceHeight / 6;      // 40 px  | 40 px
    var y2 = deviceHeight * 11/24;  // 110 px | 70 px
    var y3 = deviceHeight * 3/4;    // 180 px | 70 px
    var y4 = deviceHeight * 7/8;    // 210 px | 30 px
    
    var shrinkValue = (1 - (middleColumnPercentageSize.toFloat() / 100)) * columnWidth / 2;
    
    v1area = [ x1, 0, deviceWidth, y1 ];
    
    h2area = [ x1, y1, columnWidth + shrinkValue, headerHeight ];
    v2area = [ x1, y1 + headerHeight, columnWidth + shrinkValue, valueHeight ];
    
    h3area = [ x2 + shrinkValue, y1, columnWidth - (2 * shrinkValue), headerHeight ];
    v3area = [ x2 + shrinkValue, y1 + headerHeight, columnWidth - (2 * shrinkValue), valueHeight ];
    
    h4area = [ x3 - shrinkValue, y1, columnWidth + shrinkValue, headerHeight ];
    v4area = [ x3 - shrinkValue, y1 + headerHeight, columnWidth + shrinkValue, valueHeight ];
    
    h5area = [ x1, y2, columnWidth + shrinkValue, headerHeight ];
    v5area = [ x1, y2 + headerHeight, columnWidth + shrinkValue, valueHeight ];
    
    h6area = [ x2 + shrinkValue, y2, columnWidth - (2 * shrinkValue), headerHeight ];
    v6area = [ x2 + shrinkValue, y2 + headerHeight, columnWidth - (2 * shrinkValue), valueHeight ];
    
    h7area = [ x3 - shrinkValue, y2, columnWidth + shrinkValue, headerHeight ];
    v7area = [ x3 - shrinkValue, y2 + headerHeight, columnWidth + shrinkValue, valueHeight ];
    
    v8area = [ x1, y3, deviceWidth / 2, y4 - y3 ];
    v9area = [ x1 + (deviceWidth / 2), y3, deviceWidth / 2, y4 - y3 ];
    
    v10area = [ x1, y4, deviceWidth, deviceHeight - y4 ];

    if (headerPosition == 2)
    {
      h5area = [ x1, y2 + valueHeight, columnWidth + shrinkValue, headerHeight ];
      v5area = [ x1, y2, columnWidth + shrinkValue, valueHeight ];
      
      h6area = [ x2 + shrinkValue, y2 + valueHeight, columnWidth - (2 * shrinkValue), headerHeight ];
      v6area = [ x2 + shrinkValue, y2, columnWidth - (2 * shrinkValue), valueHeight ];
      
      h7area = [ x3 - shrinkValue, y2 + valueHeight, columnWidth + shrinkValue, headerHeight ];
      v7area = [ x3 - shrinkValue, y2, columnWidth + shrinkValue, valueHeight ];
    }
    
    else if (headerPosition == 3)
    {
      h2area = [ x1, y1 + valueHeight, columnWidth + shrinkValue, headerHeight ];
      v2area = [ x1, y1, columnWidth + shrinkValue, valueHeight ];
      
      h3area = [ x2 + shrinkValue, y1 + valueHeight, columnWidth - (2 * shrinkValue), headerHeight ];
      v3area = [ x2 + shrinkValue, y1, columnWidth - (2 * shrinkValue), valueHeight ];
      
      h4area = [ x3 - shrinkValue, y1 + valueHeight, columnWidth + shrinkValue, headerHeight ];
      v4area = [ x3 - shrinkValue, y1, columnWidth + shrinkValue, valueHeight ];
    }
    
    // Merge area if not defined
    var mergeArray = mergeArea(v2, v3, v4, h2area, v2area, h3area, v3area, h4area, v4area);
    v2 = mergeArray[0];
    v3 = mergeArray[1];
    v4 = mergeArray[2];
    
    mergeArray = mergeArea(v5, v6, v7, h5area, v5area, h6area, v6area, h7area, v7area);
    v5 = mergeArray[0];
    v6 = mergeArray[1];
    v7 = mergeArray[2];
    
    mergeArray = mergeArea(v8, v9, null, null, v8area, null, v9area, null, null);
    v8 = mergeArray[0];
    v9 = mergeArray[1];
    
    if (v1 == null) { v1 = OPTION_EMPTY; }
    if (v10 == null) { v10 = OPTION_EMPTY; }
  }
  
  
  function mergeArea(v1, v2, v3, h1area, v1area, h2area, v2area, h3area, v3area)
  {
    if ( (v1 == null) && (v2 == null) && (v3 == null) )
    {
      return [ OPTION_EMPTY, OPTION_EMPTY, OPTION_EMPTY ];
    }
    
    // Move empty area (null) to the left
    if (v1 == null)
    {
      if (v2 != null)
      {
        v1 = v2;
        v2 = null;
      }
      
      else if (v3 != null)
      {
        v1 = v3;
        v3 = null;
      }
    }
    
    if ( (v2 == null) && (v3 != null) )
    {
      v2 = v3;
      v3 = null;
    }
    
    if ( (v2 == null) && (v3 == null) )
    {
      if (h1area != null) { h1area[2] = deviceWidth; } // if mergeArea() is called for Area 8 and 9 (only 2 fields without Headers)
      v1area[2] = deviceWidth;
    }
    
    else if (v3 == null)
    {
      if (h1area != null) { // if mergeArea() is called for Area 8 and 9 (only 2 fields without Headers)
        h2area[0] = deviceWidth / 2;
        v2area[0] = deviceWidth / 2;
        
        h1area[2] = deviceWidth / 2;
        v1area[2] = deviceWidth / 2;
        h2area[2] = deviceWidth / 2;
        v2area[2] = deviceWidth / 2;
      }
    }
    
    return [v1, v2, v3];
  }
  
  // Set your layout here. Anytime the size of obscurity of
  // the draw context is changed this will be called.
  function onLayout(dc)
  {
  }

  
  function computeValue(info, value, valueData)
  {
    // Current altitude in meters (m)
    if ( (value == OPTION_ALTITUDE) && (info has :altitude ) && (info.altitude  != null) )
    {
      if (System.getDeviceSettings().elevationUnits == System.UNIT_STATUTE) {
        // Convert in feet
        return (info.altitude * CONVERSION_METER_TO_FEET).toNumber(); 
      }
      
      return info.altitude.toNumber();
    }
    
    // Average heart rate during the current activity in beats per minute (bpm)
    if ( (value == OPTION_AVERAGE_HEART_RATE) && (info has :averageHeartRate) && (info.averageHeartRate != null) ) 
    {
      return info.averageHeartRate;
    }
    
    // Average pace in second per kilometer
    if ( (value == OPTION_AVERAGE_PACE) && (info has :averageSpeed) && (info.averageSpeed != null) )
    {
      if (info.averageSpeed <= 0) { return 0; }
      
      if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
        // Convert in second per mile
        return (1000 / info.averageSpeed * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      return (1000 / info.averageSpeed).toNumber();
    }
    
    /* Not required to manual calculate Pace. Use OPTION_AVERAGE_PACE instead
    if ( (value == OPTION_AVERAGE_PACE_MANUAL_CALC) && (info has :elapsedDistance) && (info.elapsedDistance != null) && (info has :timerTime) && (info.timerTime != null) )
    {
      // Convert to kilometers (km)
      if (info.elapsedDistance <= 0) { return 0; }
      
      if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
        // Convert in seconds per mile (mi)
        return (info.timerTime.toFloat() / info.elapsedDistance * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      // Convert in seconds per km
      return (info.timerTime.toFloat() / info.elapsedDistance).toNumber();
    }
    */
    
    // Average speed during the current activity in meters per second (mps)
    if ( (value == OPTION_AVERAGE_SPEED) && (info has :averageSpeed) && (info.averageSpeed != null) )
    {
      if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
        // Convert in miles/h
        return info.averageSpeed * 3.6 * CONVERSION_KM_TO_MILE;
      }
      
      // Convert in km/h
      return info.averageSpeed * 3.6;
    }
    
    // Calories burned throughout the current activity in kilocalories (kcal)
    if ( (value == OPTION_CALORIES) && (info has :calories) && (info.calories != null) ) 
    {
      return info.calories;
    }
    
    // Current cadence in revolutions per minute (rpm)
    if ( (value == OPTION_CURRENT_CADENCE) && (info has :currentCadence) && (info.currentCadence != null) )
    {
      return info.currentCadence;
    }
    
    // Current heart rate in beats per minute (bpm)
    if ( (value == OPTION_CURRENT_HEART_RATE) && (info has :currentHeartRate) && (info.currentHeartRate != null) ) 
    {
      return info.currentHeartRate;
    }
    
    // Current GPS accuracy
    if ( (value == OPTION_CURRENT_LOCATION_ACCURACY) && (info has :currentLocationAccuracy) && (info.currentLocationAccuracy != null) )
    {
      return info.currentLocationAccuracy;
    }
    
    // Current GPS accuracy & Battery Usage
    if ( (value == OPTION_CURRENT_LOCATION_ACCURACY_AND_BATTERY) && (info has :currentLocationAccuracy) && (info.currentLocationAccuracy != null) )
    {
      return info.currentLocationAccuracy;
    }
    
    // Current pace in second per kilometer
    if ( (value == OPTION_CURRENT_PACE) && (info has :currentSpeed) && (info.currentSpeed != null) )
    {
      if (info.currentSpeed <= 0) { return 0; }
      
      if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
        // Convert in second per mile
        return (1000 / info.currentSpeed * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      // Convert in second per kilometer
      return (1000 / info.currentSpeed).toNumber();
    }
    
    // Current speed in meters per second (mps)
    if ( (value == OPTION_CURRENT_SPEED) && (info has :currentSpeed) && (info.currentSpeed != null) )
    {
      if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
        // Convert in miles/h
        return info.currentSpeed * 3.6 * CONVERSION_KM_TO_MILE;
      }
      
      // Convert in km/h
      return info.currentSpeed * 3.6;
    }
    
    // Current Clock Time
    if (value == OPTION_CURRENT_TIME)
    {
      return System.getClockTime();
    }
    
    // Elapsed distance of the current activity in meters (m)
    if ( (value == OPTION_ELAPSED_DISTANCE) && (info has :elapsedDistance) && (info.elapsedDistance != null) )
    {
      if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
        // Convert in miles
        return info.elapsedDistance / 1000 * CONVERSION_KM_TO_MILE;
      }
      
      // Convert to kilometers (km)
      return info.elapsedDistance / 1000;
    }
    
    //OPTION_ETA_5K = 21,
    //OPTION_ETA_10K = 22,
    //OPTION_ETA_HALF_MARATHON = 23,
    //OPTION_ETA_MARATHON = 24
    if ( (value == OPTION_ETA_5K) && (info has :averageSpeed) && (info.averageSpeed != null) && (info has :elapsedDistance) && (info.elapsedDistance != null)  && (info has :timerTime) && (info.timerTime != null))
    {
      var remainingDistance = 5000 - (info.elapsedDistance / 1000);
      return (info.timerTime / 1000) + (remainingDistance / info.averageSpeed);
    }
    
    if ( (value == OPTION_ETA_10K) && (info has :averageSpeed) && (info.averageSpeed != null) && (info has :elapsedDistance) && (info.elapsedDistance != null)  && (info has :timerTime) && (info.timerTime != null))
    {
      var remainingDistance = 10000 - (info.elapsedDistance / 1000);
      return (info.timerTime / 1000) + (remainingDistance / info.averageSpeed);
    }
    
    if ( (value == OPTION_ETA_HALF_MARATHON) && (info has :averageSpeed) && (info.averageSpeed != null) && (info has :elapsedDistance) && (info.elapsedDistance != null)  && (info has :timerTime) && (info.timerTime != null))
    {
      var remainingDistance = 21097.5 - (info.elapsedDistance / 1000);
      return (info.timerTime / 1000) + (remainingDistance / info.averageSpeed);
    }
    
    if ( (value == OPTION_ETA_MARATHON) && (info has :averageSpeed) && (info.averageSpeed != null) && (info has :elapsedDistance) && (info.elapsedDistance != null)  && (info has :timerTime) && (info.timerTime != null))
    {
      var remainingDistance = 42195 - (info.elapsedDistance / 1000);
      return (info.timerTime / 1000) + (remainingDistance / info.averageSpeed);
    }
    
    
    if ( ((value == OPTION_PREVIOUS_KM_OR_MILE) || (value == OPTION_TIMER_TIME_ON_CURRENT_KM_OR_MILE)) && (info has :elapsedDistance) && (info.elapsedDistance != null) && (info has :timerTime) && (info.timerTime != null) ) 
    {
      // Convert to second
      var timer = info.timerTime / 1000;
      
      // Convert to kilometers (km)
      var distance = info.elapsedDistance / 1000;
      if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
        // Convert in miles (mi)
        distance = distance * CONVERSION_KM_TO_MILE; 
      } 
       
      if (currentKM != Math.floor(distance))
      {
        timerLastKM = timer - startTimerCurrentKM;  // Time taken on last km or mile
        currentKM = Math.floor(distance);
        startTimerCurrentKM = timer;
      }
      
      timerCurrentKM = timer - startTimerCurrentKM;
    }
    
    if (value == OPTION_PREVIOUS_KM_OR_MILE) 
    {
      return timerLastKM;
    }
    
    if (value == OPTION_TIMER_TIME_ON_CURRENT_KM_OR_MILE)
    {
      return timerCurrentKM;
    }
    
    // The current Timer value in milliseconds (ms)
    if ( (value == OPTION_TIMER_TIME) && (info has :timerTime) && (info.timerTime != null) )
    {
      // Convert in second
      return info.timerTime / 1000;
    }
    
    // The total ascent during the current activity in meters (m)
    if ( (value == OPTION_TOTAL_ASCENT) && (info has :totalAscent) && (info.totalAscent != null) )
    {
      if (System.getDeviceSettings().heightUnits == System.UNIT_STATUTE) {
        // Convert in miles (mi)
        return (info.totalAscent / 1000 * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      return (info.totalAscent / 1000).toNumber();
    }

    // The total descent during the current activity in meters (m)
    if ( (value == OPTION_TOTAL_DESCENT) && (info has :totalDescent) && (info.totalDescent != null) )
    {
      if (System.getDeviceSettings().heightUnits == System.UNIT_STATUTE) {
        // Convert in miles (mi)
        return (info.totalDescent / 1000 * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      return (info.totalDescent / 1000).toNumber();
    }

    //return computeExtraValue(info, value, valueData);
    return valueData;
  }
  
  
  // Extra values, which might be used on device with more memory
  // Keep commented to save memory
  /*
  function computeExtraValue(info, value, valueData)
  {
    // Ambient pressure in Pascals (Pa).
    if ( (value == OPTION_AMBIENT_PRESSURE) && (info has :ambientPressure ) && (info.ambientPressure  != null) )
    {
      return info.ambientPressure;
    }
    
    // Average cadence during the current activity in revolutions per minute (rpm)
    if ( (value == OPTION_AVERAGE_CADENCE) && (info has :averageCadence) && (info.averageCadence != null) )
    {
      return info.averageCadence;
    }
    
    // Average swim stroke distance from the previous interval in meters (m)
    if ( (value == OPTION_AVERAGE_DISTANCE) && (info has :averageDistance) && (info.averageDistance != null) )
    {
      if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
        // Convert in miles (mi)
        return (info.averageDistance / 1000 * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      // Convert to kilometers (km)
      return (info.averageDistance / 1000).toNumber();
    }

    // Average power during the current activity in Watts (W)
    if ( (value == OPTION_AVERAGE_POWER) && (info has :averagePower) && (info.averagePower != null) ) 
    {
      return info.averagePower;
    }
    
    // Current bearing in radians
    if ( (value == OPTION_BEARING) && (info has :bearing) && (info.bearing != null) ) 
    {
      return info.bearing;
    }
    
    // Bearing from the starting location to the destination in radians
    if ( (value == OPTION_BEARING_FROM_START) && (info has :bearingFromStart) && (info.bearingFromStart != null) ) 
    {
      return info.bearingFromStart;
    }
    
    // True north referenced heading in radians
    if ( (value == OPTION_CURRENT_HEADING) && (info has :currentHeading) && (info.currentHeading != null) )
    {
      return info.currentHeading;
    }
    
    // Current location
    if ( (value == OPTION_CURRENT_LOCATION) && (info has :currentLocation) && (info.currentLocation != null) ) 
    {
      // return [ latitude, longitude ]
      return info.currentLocation.toDegrees();
    }
    
    // Current power in Watts (W)
    if ( (value == OPTION_CURRENT_POWER) && (info has :currentPower) && (info.currentPower != null) )
    {
      return info.currentPower;
    }
    
    // Distance to the destination in meters (m)
    if ( (value == OPTION_DISTANCE_TO_DESTINATION) && (info has :distanceToDestination) && (info.distanceToDestination != null) )   
    {
      if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
        // Convert in miles (mi)
        return (info.distanceToDestination / 1000 * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      // Convert to kilometers (km)
      return (info.distanceToDestination / 1000).toNumber();
    }
    
    // Distance to the next point in meters (m)
    if ( (value == OPTION_DISTANCE_TO_NEXT_POINT) && (info has :distanceToNextPoint) && (info.distanceToNextPoint != null) )
    {
      if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
        // Convert in miles (mi)
        return (info.distanceToNextPoint / 1000 * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      // Convert to kilometers (km)
      return (info.distanceToNextPoint / 1000).toNumber();
    }
    
    // Elapsed time of the current activity in milliseconds (ms)
    // Time since the recording starts. Elapsed Time Continue to increment when activity is paused. 
    if ( (value == OPTION_ELAPSED_TIME) && (info has :elapsedTime) && (info.elapsedTime != null) )
    {
      // Convert to second
      return info.elapsedTime / 1000;
    }
    
    // Elevation at the destination in meters (m)
    if ( (value == OPTION_ELEVATION_AT_DESTINATION) && (info has :elevationAtDestination) && (info.elevationAtDestination != null) )
    {
      if (System.getDeviceSettings().heightUnits == System.UNIT_STATUTE) {
        // Convert in miles (mi)
        return (info.elevationAtDestination / 1000 * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      return (info.elevationAtDestination / 1000).toNumber();
    }
    
    // Elevation at the next point in meters (m)
    if ( (value == OPTION_ELEVATION_AT_NEXT_POINT) && (info has :elevationAtNextPoint) && (info.elevationAtNextPoint != null) )
    {
      if (System.getDeviceSettings().heightUnits == System.UNIT_STATUTE) {
        // Convert in miles (mi)
        return (info.elevationAtNextPoint / 1000 * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      return (info.elevationAtNextPoint / 1000).toNumber();
    }
    
    // Current energy expenditure in kilocalories per minute (kcals/min)
    if ( (value == OPTION_ENERGY_EXPENDITURE) && (info has :energyExpenditure) && (info.energyExpenditure != null) )
    {
      return info.energyExpenditure;
    }
    
    // Current front bicycle derailleur index
    if ( (value == OPTION_FRONT_DERAILLEUR_INDEX) && (info has :frontDerailleurIndex) && (info.frontDerailleurIndex != null) )
    {
      return info.frontDerailleurIndex;
    }
    
    // Front bicycle derailleur maximum index
    if ( (value == OPTION_FRONT_DERAILLEUR_MAX) && (info has :frontDerailleurMax) && (info.frontDerailleurMax != null) )
    {
      return info.frontDerailleurMax;
    }
    
    // Front bicycle derailleur gear size in number of teeth
    if ( (value == OPTION_FRONT_DERAILLEUR_SIZE) && (info has :frontDerailleurSize) && (info.frontDerailleurSize != null) )
    {
      return info.frontDerailleurSize;
    }
    
    // Maximum cadence recorded during the current activity in revolutions per minute (rpm)
    if ( (value == OPTION_MAX_CADENCE) && (info has :maxCadence) && (info.maxCadence != null) )
    {
      return info.maxCadence;
    }

    // Maximum heart rate recorded during the current activity in beats per minute (bpm)
    if ( (value == OPTION_MAX_HEART_RATE) && (info has :maxHeartRate) && (info.maxHeartRate != null) ) 
    {
      return info.maxHeartRate;
    }

    // Maximum power recorded during the current activity in Watts (W)
    if ( (value == OPTION_MAX_POWER) && (info has :maxPower) && (info.maxPower != null) )
    {
      return info.maxPower;
    }
    
    // Maximum speed recorded during the current activity in meters per second (mps)
    if ( (value == OPTION_MAX_SPEED) && (info has :maxSpeed) && (info.maxSpeed != null) )
    {
      if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
        // Convert in miles/h
        return info.maxSpeed * 3.6 * CONVERSION_KM_TO_MILE;
      }
      
      // Convert in km/h
      return info.maxSpeed * 3.6;
    }
    
    // The mean sea level barometric pressure in Pascals (Pa)
    if ( (value == OPTION_MEAN_SEA_LEVEL_PRESSURE) && (info has :meanSeaLevelPressure) && (info.meanSeaLevelPressure != null) )
    {
      return info.meanSeaLevelPressure;
    }

    // Name of the destination
    if ( (value == OPTION_NAME_OF_DESTINATION) && (info has :nameOfDestination) && (info.nameOfDestination != null) )
    {
      return info.nameOfDestination;
    }

    // Name of the next point
    if ( (value == OPTION_NAME_OF_NEXT_POINT) && (info has :nameOfNextPoint) && (info.nameOfNextPoint != null) )
    {
      return info.nameOfNextPoint;
    }

    // Distance to the nearest point on the current course in meters (m)
    if ( (value == OPTION_OFF_COURSE_DISTANCE) && (info has :offCourseDistance) && (info.offCourseDistance != null) )
    {
      if (System.getDeviceSettings().paceUnits == System.UNIT_STATUTE) {
        // Convert in miles (mi)
        return (info.offCourseDistance / 1000 * CONVERSION_KM_TO_MILE).toNumber(); 
      }
      
      return (info.offCourseDistance / 1000).toNumber();
    }
    
    // The raw ambient pressure in Pascals (Pa)
    if ( (value == OPTION_RAW_AMBIENT_PRESSURE) && (info has :rawAmbientPressure) && (info.rawAmbientPressure != null) )
    {
      return info.rawAmbientPressure;
    }

    // The current front bicycle derailleur index
    if ( (value == OPTION_REAR_DERAILLEUR_INDEX) && (info has :rearDerailleurIndex) && (info.rearDerailleurIndex != null) )
    {
      return info.rearDerailleurIndex;
    }

    // The rear bicycle derailleur maximum index
    if ( (value == OPTION_REAR_DERAILLEUR_MAX) && (info has :rearDerailleurMax) && (info.rearDerailleurMax != null) )
    {
      return info.rearDerailleurMax;
    }

    // The rear bicycle derailleur gear size in number of teeth
    if ( (value == OPTION_REAR_DERAILLEUR_SIZE) && (info has :rearDerailleurSize) && (info.rearDerailleurSize != null) )
    {
      return info.rearDerailleurSize;
    }

    // The starting location of the current activity
    if ( (value == OPTION_START_LOCATION) && (info has :startLocation) && (info.startLocation != null) )
    {
      // return [ latitude, longitude ]
      return info.startLocation.toDegrees();
    }

    // The starting time of the current activity
    if ( (value == OPTION_START_TIME) && (info has :startTime) && (info.startTime != null) )
    {
      return info.startTime;
    }

    // The swim stroke type from the previous length
    if ( (value == OPTION_SWIM_STROKE_TYPE) && (info has :swimStrokeType) && (info.swimStrokeType != null) )
    {
      return info.swimStrokeType;
    }

    // The SWOLF score from the previous length
    if ( (value == OPTION_SWIM_SWOLF) && (info has :swimSwolf) && (info.swimSwolf != null) )
    {
      return info.swimSwolf;
    }

    // The recording timer state. One off:
    //  - Activity.TIMER_STATE_OFF
    //  - Activity.TIMER_STATE_ON
    //  - Activity.TIMER_STATE_PAUSED
    //  - Activity.TIMER_STATE_STOPPED
    if ( (value == OPTION_TIMER_STATE) && (info has :timerState) && (info.timerState != null) )
    {
      return info.timerState;
    }
    
    // The current track in radians
    if ( (value == OPTION_TRACK) && (info has :track) && (info.track != null) )
    {
      return info.track;
    }

    // The Training Effect score of the current activity
    if ( (value == OPTION_TRAINING_EFFECT) && (info has :trainingEffect) && (info.trainingEffect != null) )
    {
      return info.trainingEffect;
    }
    
    return valueData;
  }
  */
  
  // The given info object contains all the current workout information.
  // Calculate a value and save it locally in this method.
  // Note that compute() and onUpdate() are asynchronous, and there is no
  // guarantee that compute() will be called before onUpdate().
  function compute(info)
  {
    v1data = computeValue(info, v1, v1data);
    v2data = computeValue(info, v2, v2data);
    v3data = computeValue(info, v3, v3data);
    v4data = computeValue(info, v4, v4data);
    v5data = computeValue(info, v5, v5data);
    v6data = computeValue(info, v6, v6data);
    v7data = computeValue(info, v7, v7data);
    v8data = computeValue(info, v8, v8data);
    v9data = computeValue(info, v9, v9data);
    v10data = computeValue(info, v10, v10data);
  }
  
  
  // Display the value you computed here. This will be called
  // once a second when the data field is visible.
  function onUpdate(dc)
  {
    // Display Area
    displayArea(dc, 1, v1, v1data, null, v1area);
    displayArea(dc, 2, v2, v2data, h2area, v2area);
    displayArea(dc, 3, v3, v3data, h3area, v3area);
    displayArea(dc, 4, v4, v4data, h4area, v4area);
    displayArea(dc, 5, v5, v5data, h5area, v5area);
    displayArea(dc, 6, v6, v6data, h6area, v6area);
    displayArea(dc, 7, v7, v7data, h7area, v7area);
    displayArea(dc, 8, v8, v8data, null, v8area);
    displayArea(dc, 9, v9, v9data, null, v9area);
    displayArea(dc, 10, v10, v10data, null, v10area);
    
    if ( (v8 != null) && (v9 != null) && (v8 != OPTION_EMPTY) && (v9 != OPTION_EMPTY) )
    {
      dc.setPenWidth(3);
      dc.setColor(getForegroundColor(8,v8, v8data), Graphics.COLOR_TRANSPARENT);
      dc.drawLine(v8area[2], v8area[1] + 5, v8area[2], v8area[1] + v8area[3] - 5);
      dc.setPenWidth(1);
    }
    
    // Display horizontal lines
    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(0, h2area[1], deviceWidth, h2area[1]);
    dc.drawLine(0, h5area[1], deviceWidth, h5area[1]);
    dc.drawLine(0, v8area[1], deviceWidth, v8area[1]);
    dc.drawLine(0, v2area[1], deviceWidth, v2area[1]);
    dc.drawLine(0, v5area[1], deviceWidth, v5area[1]);
  }
  
  
  function displayArea(dc, id, type, value, headerArea, valueArea)
  {
    if (type == null) { return; }
    var leftOffsetX = 0;
    var rightOffsetX = 0;
  
    // Set Header values, except for Area 1, 8 and 9
    if ( (id >= 2) && (id <= 7) )
    {
      // Get coordinate of Header elements
      var headerX = headerArea[0] + (headerArea[2] / 2);
      var headerY = headerArea[1] + (headerArea[3] / 2);
      
      // Set Header background color
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
      dc.fillRectangle(headerArea[0], headerArea[1], headerArea[2], headerArea[3]);
      if (headerArea[0] > 0)
      {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(headerArea[0], headerArea[1], headerArea[0], headerArea[1] + headerArea[3]);
      }
      
      // Set Header foreground color + text
      if (headerArea[0] == 0) { leftOffsetX = (deviceWidth - getWidth(headerY)) / 2; }
      if (headerArea[0] + headerArea[2] == deviceWidth) { rightOffsetX = (deviceWidth - getWidth(headerY)) / 2; }
      if ( (id == 2) || (id == 3) || (id == 5) || (id == 6) ) { rightOffsetX += 1; }
      if ( (id == 3) || (id == 4) || (id == 6) || (id == 7) ) { leftOffsetX += 2; }
      dc.setClip(headerArea[0] + leftOffsetX, headerArea[1], headerArea[2] - leftOffsetX - rightOffsetX, headerArea[3]);
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      dc.drawText(headerX + (leftOffsetX / 2) - (rightOffsetX / 2), headerY, fontTinyHeader, getHeaderName(type), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      dc.clearClip();
    }
    
    // Get coordinate of Data elements
    var valueX = valueArea[0] + (valueArea[2] / 2);
    var valueY = valueArea[1] + (valueArea[3] / 2);
    if (deviceModel.equals("fenixFixFont")) {
      if (id > 7) { valueY -= 1; }
      else if (id > 1) { valueY -= 3; }
    }
    
    // Set Data background color
    dc.setColor(getBackgroundColor(id), Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(valueArea[0], valueArea[1], valueArea[2], valueArea[3]);
    if ( (valueArea[0] > 0) && (id >= 2) && (id <= 7) )
    {
      dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
      dc.drawLine(valueArea[0], valueArea[1], valueArea[0], valueArea[1] + valueArea[3]);
    }
    
    // Set Data values
    if (valueArea[0] == 0) { leftOffsetX = (deviceWidth - getWidth(valueY)) / 2; }
    if (valueArea[0] + valueArea[2] == deviceWidth) { rightOffsetX = (deviceWidth - getWidth(valueY)) / 2; }
    dc.setClip(valueArea[0] + leftOffsetX, valueArea[1], valueArea[2] - leftOffsetX - rightOffsetX, valueArea[3]);
    dc.setColor(getForegroundColor(id, type, value), Graphics.COLOR_TRANSPARENT);
    
    // Display HR icon if in Area 1, 8 or 9
    if ( (type == OPTION_CURRENT_HEART_RATE) && ((id == 1) || (id == 8) || (id == 9) || (id == 10)) )
    {
      var x = valueX + (leftOffsetX / 2) - (rightOffsetX / 2);
      var iconLength = dc.getTextWidthInPixels("0", fontIcons);
      var textLength = dc.getTextWidthInPixels(" " + value, fontMediumHeader);
      dc.drawText(x - (textLength / 2), valueY, fontIcons, 0, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      dc.drawText(x + (iconLength / 2), valueY, fontMediumHeader, " " + getValue(type, value), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    else if (type == OPTION_CURRENT_LOCATION_ACCURACY_AND_BATTERY)
    {
      var x = valueX + (leftOffsetX / 2) - (rightOffsetX / 2);
      var gpsLength = LENGTH_GPS_ICON + 6;
      var batteryLength = LENGTH_BATTERY_ICON + 6;
      drawGPS(dc, x - (batteryLength / 2), valueY - 2, LENGTH_GPS_ICON, value);
      drawBattery(dc, x + (gpsLength / 2), valueY - 2, LENGTH_BATTERY_ICON, System.getSystemStats().battery, true);
    }
    
    else if (type == OPTION_CURRENT_LOCATION_ACCURACY)
    {
      drawGPS(dc, valueX + (leftOffsetX / 2) - (rightOffsetX / 2), valueY - 2, LENGTH_GPS_ICON, value);
    }
    
    else if (type == OPTION_CURRENT_BATTERY)
    {
      drawGPS(dc, valueX + (leftOffsetX / 2) - (rightOffsetX / 2), valueY - 2, LENGTH_GPS_ICON, value);
    }
      
    else
    {
      dc.drawText(valueX + (leftOffsetX / 2) - (rightOffsetX / 2), valueY, getFont(dc, type, value, valueArea[2] - leftOffsetX - rightOffsetX), getValue(type, value), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    dc.clearClip();
  }
  
  // Uncompute values are keep commented to save memory usage.
  function getHeaderName(type)
  {
    if (type == null) { return ""; }
    
    switch (type)
    {
      case OPTION_ALTITUDE:
        return "ALT";

      //case OPTION_AMBIENT_PRESSURE:
      //  return "PRES";

      //case OPTION_AVERAGE_CADENCE:
      //  return "AVG CAD";

      //case OPTION_AVERAGE_DISTANCE:
      //  return "AVG DIST";

      case OPTION_AVERAGE_HEART_RATE:
        return "AVG HR";

      case OPTION_AVERAGE_PACE:
      case OPTION_AVERAGE_PACE_MANUAL_CALC:
        return "AVG PACE";

      //case OPTION_AVERAGE_POWER:
      //  return "AVG POW";

      case OPTION_AVERAGE_SPEED:
        return "AVG SPD";

      //case OPTION_BEARING:
      //  return "BEAR";

      //case OPTION_BEARING_FROM_START:
      //  return "BEARS";

      case OPTION_CALORIES:
        return "CAL";

      case OPTION_CURRENT_BATTERY:
        return "BAT";

      case OPTION_CURRENT_CADENCE:
        return "CAD";

      //case OPTION_CURRENT_HEADING:
      //  return "COMP";

      case OPTION_CURRENT_HEART_RATE:
        return "HR";

      //case OPTION_CURRENT_LOCATION:
      //  return "LOC";

      case OPTION_CURRENT_LOCATION_ACCURACY:
        return "GPS";

      case OPTION_CURRENT_LOCATION_ACCURACY_AND_BATTERY:
        return "GPS/BAT";

      case OPTION_CURRENT_PACE:
        return "PACE";

      //case OPTION_CURRENT_POWER:
      //  return "POW";

      case OPTION_CURRENT_SPEED:
        return "SPD";

      case OPTION_CURRENT_TIME:
        return "TIME";

      //case OPTION_DISTANCE_TO_DESTINATION:
      //  return "DISTD";

      //case OPTION_DISTANCE_TO_NEXT_POINT:
      //  return "DISTN";

      case OPTION_ELAPSED_DISTANCE:
        return "DIST";

      //case OPTION_ELAPSED_TIME:
      //  return "TIME";

      //case OPTION_ELEVATION_AT_DESTINATION:
      //  return "ELVD";

      //case OPTION_ELEVATION_AT_NEXT_POINT:
      //  return "DELNP";

      //case OPTION_ENERGY_EXPENDITURE:
      //  return "NRG";

      //case OPTION_FRONT_DERAILLEUR_INDEX:
      //  return "DERI";

      //case OPTION_FRONT_DERAILLEUR_MAX:
      //  return "DERM";

      //case OPTION_FRONT_DERAILLEUR_SIZE:
      //  return "DERS";

      //case OPTION_MAX_CADENCE:
      //  return "MAX CAD";

      //case OPTION_MAX_HEART_RATE:
      //  return "MAX HR";

      //case OPTION_MAX_POWER:
      //  return "MAX POW";

      //case OPTION_MAX_SPEED:
      //  return "MAX SPD";

      //case OPTION_MEAN_SEA_LEVEL_PRESSURE:
      //  return "SEA PRES";

      //case OPTION_NAME_OF_DESTINATION:
      //  return "DEST";

      //case OPTION_NAME_OF_NEXT_POINT:
      //  return "NEXT P";

      //case OPTION_OFF_COURSE_DISTANCE:
      //  return "DIST NP";

      case OPTION_PREVIOUS_KM_OR_MILE:
        if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
          return "LAST MI";
        }
        return "LAST KM";

      //case OPTION_RAW_AMBIENT_PRESSURE:
      //  return "PRESS";

      //case OPTION_REAR_DERAILLEUR_INDEX:
      //  return "RDERI";

      //case OPTION_REAR_DERAILLEUR_MAX:
      //  return "RDERM";

      //case OPTION_REAR_DERAILLEUR_SIZE:
      //  return "RDERS";

      //case OPTION_START_LOCATION:
      //  return "S LOC";

      //case OPTION_START_TIME:
      //  return "S TIME";

      //case OPTION_SWIM_STROKE_TYPE:
      //  return "STK TYPE";

      //case OPTION_SWIM_SWOLF:
      //  return "SWOLF";

      //case OPTION_TIMER_STATE:
      //  return "TMR ST";

      case OPTION_TIMER_TIME:
        return "TIMER";

      case OPTION_TIMER_TIME_ON_CURRENT_KM_OR_MILE:
        if (System.getDeviceSettings().distanceUnits == System.UNIT_STATUTE) {
          return "CUR MI";
        }
        return "CUR KM";

      case OPTION_TOTAL_ASCENT:
        return "ASCENT";

      case OPTION_TOTAL_DESCENT:
        return "DESCENT";

      //case OPTION_TRACK:
      //  return "TRACK";

      //case OPTION_TRAINING_EFFECT:
      //  return "TRAIN EFF";
      
      case OPTION_ETA_5K:
        return "ETA 5K";
      
      case OPTION_ETA_10K:
        return "ETA 10K";
      
      case OPTION_ETA_HALF_MARATHON:
        return "ETA 21K";
      
      case OPTION_ETA_MARATHON:
        return "ETA 42K";
    }
    
    return "";
  }
  
  
  function getHour(h)
  {
    if (System.getDeviceSettings().is24Hour) { return h; }
    if (h > 12) { return h - 12; }
    return h;
  }
  
  
  function getValue(type, value)
  {
    if (type == null) { return ""; }
    
    switch (type)
    {
      case OPTION_EMPTY:
        return "";
      
      case OPTION_CURRENT_PACE:
      case OPTION_AVERAGE_PACE:
      case OPTION_AVERAGE_PACE_MANUAL_CALC:
      case OPTION_PREVIOUS_KM_OR_MILE:
      case OPTION_TIMER_TIME_ON_CURRENT_KM_OR_MILE:
        return formatDuration(value, false);
      
      case OPTION_TIMER_TIME:
      case OPTION_ETA_5K:
      case OPTION_ETA_10K:
      case OPTION_ETA_HALF_MARATHON:
      case OPTION_ETA_MARATHON:
        return formatDuration(value, true);
      
      case OPTION_CURRENT_TIME:
        if ( (type == v1) || (type == v8) || (type == v9) || (type == v10) ) { return getHour(value.hour) + "h" + value.min.format("%02d"); }
        return getHour(value.hour) + ":" + value.min.format("%02d");
    }

    // Calling format("%.1f") will round the value. To truncate the value instead of rounding, we simply multiply by 10, convert to Integer and divide by 10.0 (Float).
    // Example: 4.48 --> (4.48 * 10).toNumber() = 44 / 10.0 = 4.4
    if (value instanceof Float) { return ((value * 10).toNumber() / 10.0).format("%.1f"); }
    return value.toString();
  }
  
  
  function getFont(dc, type, value, maxWidth)
  {
    var fontID = 5;
    var textWidth = 0;
    
    if ( (type == v1) || (type == v8) || (type == v9) || (type == v10) )
    {
        fontID = 3;
    }
    
    if (fontID >= 5) 
    {
      textWidth = dc.getTextWidthInPixels(getValue(type, value), fontMediumNumericValue);
      if (textWidth <= maxWidth) { return fontMediumNumericValue; }
      fontID -= 1;
    }
    
    if (fontID >= 4) 
    {
      textWidth = dc.getTextWidthInPixels(getValue(type, value), fontSmallNumericValue);
      if (textWidth <= maxWidth) { return fontSmallNumericValue; }
      fontID -= 1;
    }
    
    if (fontID >= 3) 
    {
      textWidth = dc.getTextWidthInPixels(getValue(type, value), fontMediumHeader);
      if (textWidth <= maxWidth) { return fontMediumHeader; }
      fontID -= 1;
    }
    
    if (fontID >= 2) 
    {
      textWidth = dc.getTextWidthInPixels(getValue(type, value), fontSmallHeader);
      if (textWidth <= maxWidth) { return fontSmallHeader; }
      fontID -= 1;
    }
    
    return fontTinyHeader;
  }
  
  
  function getBackgroundColor(id)
  {
    var backgroundColor1 = Graphics.COLOR_WHITE;
    var backgroundColor2 = Graphics.COLOR_BLACK;
    
    if (DataField.getBackgroundColor() == Graphics.COLOR_BLACK) {
      backgroundColor1 = Graphics.COLOR_BLACK;
      backgroundColor2 = Graphics.COLOR_WHITE;
    }
    
    if (id == null) { return backgroundColor1; }
    
    if ( (id >= 8) && (id <= 10) ) {
        return backgroundColor2;
    }
    
    return backgroundColor1;
  }
  
  
  function getForegroundColor(id, type, value)
  {
    var foregroundColor1 = Graphics.COLOR_BLACK;
    var foregroundColor2 = Graphics.COLOR_WHITE;
    
    if (DataField.getBackgroundColor() == Graphics.COLOR_BLACK) {
      foregroundColor1 = Graphics.COLOR_WHITE;
      foregroundColor2 = Graphics.COLOR_BLACK;
    }
    
    if (id == null) { return foregroundColor1; }
    
    switch (type)
    {
      case OPTION_CURRENT_HEART_RATE:
      case OPTION_AVERAGE_HEART_RATE:
        if (value instanceof Toybox.Lang.Number == false)
        {
          if ((id >= 8) && (id <= 10)) { return foregroundColor2; }
          return foregroundColor1;
        }
        
        else if (value < hrZones[1]) { return 0x555555; } // Grey
        else if (value < hrZones[2]) { return 0x00AAFF; } // Blue
        else if (value < hrZones[3]) { return 0x55AA55; } // Green
        else if (value < hrZones[4]) { return 0xFF5500; } // Orange
        return 0xFF0000;                                  // Red
        
      case OPTION_CURRENT_PACE:
      case OPTION_AVERAGE_PACE:
      case OPTION_AVERAGE_PACE_MANUAL_CALC:
        if (value <= 0) { return ((id >= 8) && (id <= 10)) ? foregroundColor2 : foregroundColor1; }
        else if (value < minPace) { return Graphics.COLOR_BLUE; }
        else if (value > maxPace) { return Graphics.COLOR_RED; }
        return Graphics.COLOR_DK_GREEN;
    }
    
    if ( ((id >= 8) && (id <= 10)) ) { return foregroundColor2; }
    return foregroundColor1;
  }
  
  
  function min(a, b)
  {
    return (a < b) ?  a : b;
  }
  
  
  function max(a, b)
  {
    return (a > b) ?  a : b;
  }
  
  function getWidth(y)
  {
    if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
      var radius = deviceWidth / 2;
      var angle = 2 * Math.toDegrees(Math.acos(1 - (y.toFloat() / radius))); // Angle = 2 * arccos(1 - height(y) / radius)
      return (2 * radius * Math.sin(Math.toRadians(angle) / 2)).toNumber();
    }
    
    //else if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_SEMI_ROUND) {}
    //else if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE) {}
    return deviceWidth;
  }


  function formatDuration(seconds, displayHour)
  {
    if (seconds instanceof String) { return seconds; } 
    seconds = seconds.toNumber();
    
    var hh = 0;
    var mm = 0;
    
    if (displayHour == true)
    {
      hh = seconds / 3600;
      mm = seconds / 60 % 60;
    }
    
    else
    {
      mm = seconds / 60;
      if (mm > 99) { return "--:--"; }
    }
    
    var ss = seconds % 60;
    return hh > 0 ? hh + ":" + mm.format("%02d") + ":" + ss.format("%02d") : mm.format("%d") + ":" + ss.format("%02d");
  }
  
  
  function drawGPS(dc, x, y, width, gpsAccuracy)
  {
    var height = width * 5/7;
    var x1 = x - (width / 2);
    var y1 = y - (height / 2);
    var space = 2;
    var barWidth = (width / 4) - space;
    
    if (gpsAccuracy <= 0)
    {
      dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    }
    
    else
    {
      dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    }
    
    dc.fillRectangle(x1 + 0 * (barWidth + space), y1 + (0.6 * height), barWidth, 0.4 * height);
    dc.fillRectangle(x1 + 1 * (barWidth + space), y1 + (0.4 * height), barWidth, 0.6 * height);
    dc.fillRectangle(x1 + 2 * (barWidth + space), y1 + (0.2 * height), barWidth, 0.8 * height);
    dc.fillRectangle(x1 + 3 * (barWidth + space), y1 + (0.0 * height), barWidth, 1.0 * height);
    
    switch (gpsAccuracy)
    {
      case 1:
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        break;
      
      case 2:
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        break;
      
      case 3:
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        break;
      
      case 4:
        dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_TRANSPARENT);
        break;
      
      default:
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        break;
    }
    
    switch (gpsAccuracy)
    {
      case 4:
        // Good
        dc.fillRectangle(x1 + 3 * (barWidth + space), y1 + (0.0 * height), barWidth, 1.0 * height);
      case 3:
        // Usable
        dc.fillRectangle(x1 + 2 * (barWidth + space), y1 + (0.2 * height), barWidth, 0.8 * height);
      case 2:
        // Poor
        dc.fillRectangle(x1 + 1 * (barWidth + space), y1 + (0.4 * height), barWidth, 0.6 * height);
      case 1:
        // Last Known
        dc.fillRectangle(x1 + 0 * (barWidth + space), y1 + (0.6 * height), barWidth, 0.4 * height);
    }
  }
  
  function drawBattery(dc, x, y, width, batteryPercentage, fixedBackground)
  {
    var height = (width * 2/5).toNumber();
    var radius = 0.15 * height;
    var x1 = x - (width / 2).toNumber();
    var y1 = y - (height / 2).toNumber();
    
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.fillCircle(x1 + width, y, radius);
    
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.fillRoundedRectangle(x1 + 1, y1, width, height, 3);
    
    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    dc.drawRoundedRectangle(x1, y1, width, height, 3);
    
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillRoundedRectangle(x1 + 2, y1 + 2, width - 4, height - 4, 2);
    
    if (fixedBackground == true)
    {
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    }
    
    else
    {
      // Display background according to battery percentage
      var width3 = ((100 - batteryPercentage) / 100 * (width - 4)).toNumber();
      var width4 = width - 4 - width3;
      dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
      dc.fillRectangle(x1 + 2 + width4, y1 + 2, width3, height - 4);
      
      if (batteryPercentage < 10) {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
      }
      
      else {
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
      }
    }
    
    dc.drawText(x, y - 1, fontTiny, batteryPercentage.format("%d") + "%", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }
}