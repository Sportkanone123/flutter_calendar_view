// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../calendar_constants.dart';
import '../calendar_controller_provider.dart';
import '../calendar_event_data.dart';
import '../components/components.dart';
import '../components/event_scroll_notifier.dart';
import '../components/safe_area_wrapper.dart';
import '../constants.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../extensions.dart';
import '../modals.dart';
import '../style/header_style.dart';
import '../typedefs.dart';
import '_internal_custom_view_page.dart';

/// [Widget] to display week view.
class CustomView<T extends Object?> extends StatefulWidget {
  /// Builder to build tile for events.
  final EventTileBuilder<T>? eventTileBuilder;

  /// Builder for timeline.
  final DateWidgetBuilder? timeLineBuilder;

  /// Header builder for week page header.
  final WeekPageHeaderBuilder? weekPageHeaderBuilder;

  /// Builds custom PressDetector widget
  ///
  /// If null, internal PressDetector will be used to handle onDateLongPress()
  ///
  final DetectorBuilder? weekDetectorBuilder;

  /// This function will generate dateString int the calendar header.
  /// Useful for I18n
  final StringProvider? headerStringBuilder;

  /// This function will generate the TimeString in the timeline.
  /// Useful for I18n
  final StringProvider? timeLineStringBuilder;

  /// This function will generate WeekDayString in the weekday.
  /// Useful for I18n
  final String Function(int)? weekDayStringBuilder;

  /// This function will generate WeekDayDateString in the weekday.
  /// Useful for I18n
  final String Function(int)? weekDayDateStringBuilder;

  /// Arrange events.
  final EventArranger<T>? eventArranger;

  /// Called whenever user changes week.
  final CalendarPageChangeCallBack? onPageChange;

  /// Minimum day to display in week view.
  ///
  /// In calendar first date of the week that contains this data will be
  /// minimum date.
  ///
  /// ex, If minDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 14th date will
  /// be the actual minimum date.
  final DateTime? minDay;

  /// Maximum day to display in week view.
  ///
  /// In calendar last date of the week that contains this data will be
  /// maximum date.
  ///
  /// ex, If maxDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 20th date will
  /// be the actual maximum date.
  final DateTime? maxDay;

  /// Initial week to display in week view.
  final DateTime? initialDay;

  /// Settings for hour indicator settings.
  final HourIndicatorSettings? hourIndicatorSettings;

  /// Settings for live time indicator settings.
  final HourIndicatorSettings? liveTimeIndicatorSettings;

  /// duration for page transition while changing the week.
  final Duration pageTransitionDuration;

  /// Transition curve for transition.
  final Curve pageTransitionCurve;

  /// Controller for Week view thia will refresh view when user adds or removes
  /// event from controller.
  final EventController<T>? controller;

  /// Defines height occupied by one minute of time span. This parameter will
  /// be used to calculate total height of Week view.
  final double heightPerMinute;

  /// Width of time line.
  final double? timeLineWidth;

  /// Flag to show live time indicator in all day or only [initialDay]
  final bool showLiveTimeLineInAllDays;

  /// Offset of time line
  final double timeLineOffset;

  /// Width of week view. If null provided device width will be considered.
  final double? width;

  /// Height of week day title,
  final double weekTitleHeight;

  /// Builder to build week day.
  final DateWidgetBuilder? dayBuilder;

  /// Background color of week view page.
  final Color backgroundColor;

  /// Scroll offset of week view page.
  final double scrollOffset;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onEventTap;

  /// Defines how many days should be displayed on screen.
  final int showDays;

  /// This method will be called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// Defines the day from which the week starts.
  ///
  /// Default value is [WeekDays.monday].
  final WeekDays startDay;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  /// Style for WeekView header.
  final HeaderStyle headerStyle;

  /// Option for SafeArea.
  final SafeAreaOption safeAreaOption;

  /// Display full day event builder.
  final FullDayEventBuilder<T>? fullDayEventBuilder;

  /// Main widget for week view.
  const CustomView({
    Key? key,
    this.controller,
    this.eventTileBuilder,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.ease,
    this.heightPerMinute = 1,
    this.timeLineOffset = 0,
    this.showLiveTimeLineInAllDays = false,
    this.width,
    this.minDay,
    this.maxDay,
    this.initialDay,
    this.hourIndicatorSettings,
    this.timeLineBuilder,
    this.timeLineWidth,
    this.liveTimeIndicatorSettings,
    this.onPageChange,
    this.weekPageHeaderBuilder,
    this.eventArranger,
    this.weekTitleHeight = 50,
    this.dayBuilder,
    this.backgroundColor = Colors.white,
    this.scrollOffset = 0.0,
    this.onEventTap,
    this.onDateLongPress,
    this.onDateTap,
    this.showDays = 3,
    this.startDay = WeekDays.monday,
    this.minuteSlotSize = MinuteSlotSize.minutes60,
    this.weekDetectorBuilder,
    this.headerStringBuilder,
    this.timeLineStringBuilder,
    this.weekDayStringBuilder,
    this.weekDayDateStringBuilder,
    this.headerStyle = const HeaderStyle(),
    this.safeAreaOption = const SafeAreaOption(),
    this.fullDayEventBuilder,
  })  : assert((timeLineOffset) >= 0,
            "timeLineOffset must be greater than or equal to 0"),
        assert(width == null || width > 0,
            "Calendar width must be greater than 0."),
        assert(timeLineWidth == null || timeLineWidth > 0,
            "Time line width must be greater than 0."),
        assert(
            heightPerMinute > 0, "Height per minute must be greater than 0."),
        assert(
          weekDetectorBuilder == null || onDateLongPress == null,
          """If you use [weekPressDetectorBuilder] 
          do not provide [onDateLongPress]""",
        ),
        super(key: key);

  @override
  CustomViewState<T> createState() => CustomViewState<T>();
}

class CustomViewState<T extends Object?> extends State<CustomView<T>> {
  late double _width;
  late double _height;
  late double _timeLineWidth;
  late double _hourHeight;
  late DateTime _currentStartDate;
  late DateTime _currentEndDate;
  late DateTime _maxDate;
  late DateTime _minDate;
  late DateTime _currentDate;
  late int _totalViews;
  late int _currentIndex;

  late EventArranger<T> _eventArranger;

  late HourIndicatorSettings _hourIndicatorSettings;
  late HourIndicatorSettings _liveTimeIndicatorSettings;

  late PageController _pageController;

  late DateWidgetBuilder _timeLineBuilder;
  late EventTileBuilder<T> _eventTileBuilder;
  late WeekPageHeaderBuilder _weekHeaderBuilder;
  late DateWidgetBuilder _dayBuilder;
  late FullDayEventBuilder<T> _fullDayEventBuilder;
  late DetectorBuilder _weekDetectorBuilder;

  late double _weekTitleWidth;
  late int _totalDaysInWeek;

  late VoidCallback _reloadCallback;

  EventController<T>? _controller;

  late ScrollController _scrollController;

  ScrollController get scrollController => _scrollController;

  final _scrollConfiguration = EventScrollConfiguration();

  @override
  void initState() {
    super.initState();

    _reloadCallback = _reload;

    _totalDaysInWeek = widget.showDays;
    _setDateRange();

    _currentDate = (widget.initialDay ?? DateTime.now()).withoutTime;

    _regulateCurrentDate();

    _calculateHeights();
    _scrollController =
        ScrollController(initialScrollOffset: widget.scrollOffset);
    _pageController = PageController(initialPage: _currentIndex);
    _eventArranger = widget.eventArranger ?? SideEventArranger<T>();

    _assignBuilders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (_controller != newController) {
      _controller = newController;

      _controller!
        // Removes existing callback.
        ..removeListener(_reloadCallback)

        // Reloads the view if there is any change in controller or
        // user adds new events.
        ..addListener(_reloadCallback);
    }

    _updateViewDimensions();
  }

  @override
  void didUpdateWidget(CustomView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller.
    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (newController != _controller) {
      _controller?.removeListener(_reloadCallback);
      _controller = newController;
      _controller?.addListener(_reloadCallback);
    }

    _totalDaysInWeek = widget.showDays;

    // Update date range.
    if (widget.minDay != oldWidget.minDay ||
        widget.maxDay != oldWidget.maxDay) {
      _setDateRange();
      _regulateCurrentDate();

      _pageController.jumpToPage(_currentIndex);
    }

    _eventArranger = widget.eventArranger ?? SideEventArranger<T>();

    // Update heights.
    _calculateHeights();

    _updateViewDimensions();

    // Update builders and callbacks
    _assignBuilders();
  }

  @override
  void dispose() {
    _controller?.removeListener(_reloadCallback);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaWrapper(
      option: widget.safeAreaOption,
      child: SizedBox(
        width: _width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _weekHeaderBuilder(_currentStartDate, _currentEndDate),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(color: widget.backgroundColor),
                child: SizedBox(
                  height: _height,
                  width: _width,
                  child: PageView.builder(
                    itemCount: _totalViews,
                    controller: _pageController,
                    onPageChanged: _onPageChange,
                    itemBuilder: (_, index) {
                      final date = DateTime(_minDate.year, _minDate.month,
                          _minDate.day + (index * widget.showDays));

                      final dates = [
                        date
                      ];

                      for(var i = 1; i < widget.showDays; i++){
                        dates.add(date.add(Duration(days: i)));
                      }

                      return ValueListenableBuilder(
                        valueListenable: _scrollConfiguration,
                        builder: (_, __, ___) => InternalCustomViewPage<T>(
                          key: ValueKey(
                              _hourHeight.toString() + dates[0].toString()),
                          height: _height,
                          width: _width,
                          weekTitleWidth: _weekTitleWidth,
                          weekTitleHeight: widget.weekTitleHeight,
                          weekDayBuilder: _dayBuilder,
                          weekDetectorBuilder: _weekDetectorBuilder,
                          liveTimeIndicatorSettings: _liveTimeIndicatorSettings,
                          timeLineBuilder: _timeLineBuilder,
                          onTileTap: widget.onEventTap,
                          onDateLongPress: widget.onDateLongPress,
                          onDateTap: widget.onDateTap,
                          eventTileBuilder: _eventTileBuilder,
                          heightPerMinute: widget.heightPerMinute,
                          hourIndicatorSettings: _hourIndicatorSettings,
                          dates: dates,
                          showLiveLine: widget.showLiveTimeLineInAllDays ||
                              _showLiveTimeIndicator(dates),
                          timeLineOffset: widget.timeLineOffset,
                          timeLineWidth: _timeLineWidth,
                          verticalLineOffset: 0,
                          showVerticalLine: true,
                          controller: controller,
                          hourHeight: _hourHeight,
                          scrollController: _scrollController,
                          eventArranger: _eventArranger,
                          showDays: widget.showDays,
                          minuteSlotSize: widget.minuteSlotSize,
                          scrollConfiguration: _scrollConfiguration,
                          fullDayEventBuilder: _fullDayEventBuilder,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns [EventController] associated with this Widget.
  ///
  /// This will throw [AssertionError] if controller is called before its
  /// initialization is complete.
  EventController<T> get controller {
    if (_controller == null) {
      throw "EventController is not initialized yet.";
    }

    return _controller!;
  }

  /// Reloads page.
  void _reload() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateViewDimensions() {
    _width = widget.width ?? MediaQuery.of(context).size.width;

    _timeLineWidth = widget.timeLineWidth ?? _width * 0.13;

    _liveTimeIndicatorSettings = widget.liveTimeIndicatorSettings ??
        HourIndicatorSettings(
          color: Constants.defaultLiveTimeIndicatorColor,
          height: widget.heightPerMinute,
          offset: 5,
        );

    assert(_liveTimeIndicatorSettings.height < _hourHeight,
        "liveTimeIndicator height must be less than minuteHeight * 60");

    _hourIndicatorSettings = widget.hourIndicatorSettings ??
        HourIndicatorSettings(
          height: widget.heightPerMinute,
          color: Constants.defaultBorderColor,
          offset: 5,
        );

    assert(_hourIndicatorSettings.height < _hourHeight,
        "hourIndicator height must be less than minuteHeight * 60");

    _weekTitleWidth =
        (_width - _timeLineWidth - _hourIndicatorSettings.offset) /
            _totalDaysInWeek;
  }

  void _calculateHeights() {
    _hourHeight = widget.heightPerMinute * 60;
    _height = _hourHeight * Constants.hoursADay;
  }

  void _assignBuilders() {
    _timeLineBuilder = widget.timeLineBuilder ?? _defaultTimeLineBuilder;
    _eventTileBuilder = widget.eventTileBuilder ?? _defaultEventTileBuilder;
    _weekHeaderBuilder =
        widget.weekPageHeaderBuilder ?? _defaultWeekPageHeaderBuilder;
    _dayBuilder = widget.dayBuilder ?? _defaultWeekDayBuilder;
    _weekDetectorBuilder =
        widget.weekDetectorBuilder ?? _defaultPressDetectorBuilder;
    _fullDayEventBuilder =
        widget.fullDayEventBuilder ?? _defaultFullDayEventBuilder;
  }

  Widget _defaultFullDayEventBuilder(
      List<CalendarEventData<T>> events, DateTime dateTime) {
    return FullDayEventView(
      events: events,
      boxConstraints: BoxConstraints(maxHeight: 65),
      date: dateTime,
    );
  }

  /// Sets the current date of this month.
  ///
  /// This method is used in initState and onUpdateWidget methods to
  /// regulate current date in Month view.
  ///
  /// If maximum and minimum dates are change then first call _setDateRange
  /// and then _regulateCurrentDate method.
  ///
  void _regulateCurrentDate() {
    if (_currentDate.isBefore(_minDate)) {
      _currentDate = _minDate;
    } else if (_currentDate.add(Duration(days: widget.showDays - 1)).isAfter(_maxDate)) {
      _currentDate = _maxDate.subtract(Duration(days: widget.showDays - 1));
    }

    _currentStartDate = _currentDate;
    _currentEndDate = _currentDate.add(Duration(days: widget.showDays - 1));
    
    _currentIndex =
        (_minDate.getDayDifference(_currentDate) / widget.showDays).floor();
  }

  /// Sets the minimum and maximum dates for current view.
  void _setDateRange() {
    _minDate = (widget.minDay ?? CalendarConstants.epochDate)
        .withoutTime;

    _maxDate = (widget.maxDay ?? CalendarConstants.maxDate)
        .withoutTime;

    assert(
      _minDate.isBefore(_maxDate),
      "Minimum date must be less than maximum date.\n"
      "Provided minimum date: $_minDate, maximum date: $_maxDate",
    );

    _totalViews =
        (_minDate.getDayDifference(_maxDate) / widget.showDays).floor();
  }

  /// Default press detector builder. This builder will be used if
  /// [widget.weekDetectorBuilder] is null.
  ///
  Widget _defaultPressDetectorBuilder({
    required DateTime date,
    required double height,
    required double width,
    required double heightPerMinute,
    required MinuteSlotSize minuteSlotSize,
  }) {
    final heightPerSlot = minuteSlotSize.minutes * heightPerMinute;
    final slots = (Constants.hoursADay * 60) ~/ minuteSlotSize.minutes;

    return Container(
      height: height,
      width: width,
      child: Stack(
        children: [
          for (int i = 0; i < slots; i++)
            Positioned(
              top: heightPerSlot * i,
              left: 0,
              right: 0,
              bottom: height - (heightPerSlot * (i + 1)),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPress: () => widget.onDateLongPress?.call(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    0,
                    minuteSlotSize.minutes * i,
                  ),
                ),
                onTap: () => widget.onDateTap?.call(
                  DateTime(
                    date.year,
                    date.month,
                    date.day,
                    0,
                    minuteSlotSize.minutes * i,
                  ),
                ),
                child: SizedBox(width: width, height: heightPerSlot),
              ),
            ),
        ],
      ),
    );
  }

  /// Default builder for week line.
  Widget _defaultWeekDayBuilder(DateTime date) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.weekDayStringBuilder?.call(date.weekday - 1) ??
              Constants.weekTitles[date.weekday - 1]),
          Text(widget.weekDayDateStringBuilder?.call(date.day) ??
              date.day.toString()),
        ],
      ),
    );
  }

  /// Default timeline builder this builder will be used if
  /// [widget.eventTileBuilder] is null
  ///
  Widget _defaultTimeLineBuilder(DateTime date) {
    final timeLineString = widget.timeLineStringBuilder?.call(date) ??
        "${((date.hour - 1) % 12) + 1} ${date.hour ~/ 12 == 0 ? "am" : "pm"}";
    return Transform.translate(
      offset: Offset(0, -7.5),
      child: Padding(
        padding: const EdgeInsets.only(right: 7.0),
        child: Text(
          timeLineString,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  /// Default timeline builder. This builder will be used if
  /// [widget.eventTileBuilder] is null
  Widget _defaultEventTileBuilder(
      DateTime date,
      List<CalendarEventData<T>> events,
      Rect boundary,
      DateTime startDuration,
      DateTime endDuration) {
    if (events.isNotEmpty)
      return RoundedEventTile(
        borderRadius: BorderRadius.circular(6.0),
        title: events[0].title,
        titleStyle: events[0].titleStyle ??
            TextStyle(
              fontSize: 12,
              color: events[0].color.accent,
            ),
        descriptionStyle: events[0].descriptionStyle,
        totalEvents: events.length,
        padding: EdgeInsets.all(7.0),
        backgroundColor: events[0].color,
      );
    else
      return Container();
  }

  /// Default view header builder. This builder will be used if
  /// [widget.dayTitleBuilder] is null.
  Widget _defaultWeekPageHeaderBuilder(DateTime startDate, DateTime endDate) {
    return WeekPageHeader(
      startDate: _currentStartDate,
      endDate: _currentEndDate,
      onNextDay: nextPage,
      onPreviousDay: previousPage,
      onTitleTapped: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: startDate,
          firstDate: _minDate,
          lastDate: _maxDate,
        );

        if (selectedDate == null) return;
        jumpToWeek(selectedDate);
      },
      headerStringBuilder: widget.headerStringBuilder,
      headerStyle: widget.headerStyle,
    );
  }

  /// Called when user change page using any gesture or inbuilt functions.
  void _onPageChange(int index) {
    if (mounted) {
      setState(() {
        _currentStartDate = DateTime(
          _currentStartDate.year,
          _currentStartDate.month,
          _currentStartDate.add(Duration(days: widget.showDays)).day,
        );
        _currentEndDate = _currentStartDate.add(
            Duration(days: widget.showDays - 1)
        );
        _currentIndex = index;
      });
    }
    widget.onPageChange?.call(_currentStartDate, _currentIndex);
  }

  /// Animate to next page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  void nextPage({Duration? duration, Curve? curve}) {
    _pageController.nextPage(
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Animate to previous page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  void previousPage({Duration? duration, Curve? curve}) {
    _pageController.previousPage(
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Jumps to page number [page]
  ///
  ///
  void jumpToPage(int page) => _pageController.jumpToPage(page);

  /// Animate to page number [page].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToPage(int page,
      {Duration? duration, Curve? curve}) async {
    await _pageController.animateToPage(page,
        duration: duration ?? widget.pageTransitionDuration,
        curve: curve ?? widget.pageTransitionCurve);
  }

  /// Returns current page number.
  int get currentPage => _currentIndex;

  /// Jumps to page which gives day calendar for [week]
  void jumpToWeek(DateTime week) {
    if (week.isBefore(_minDate) || week.isAfter(_maxDate)) {
      throw "Invalid date selected.";
    }
    _pageController
        .jumpToPage(_minDate.getWeekDifference(week, start: widget.startDay));
  }

  /// Animate to page which gives day calendar for [week].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [WeekView.pageTransitionDuration] and [WeekView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToWeek(DateTime week,
      {Duration? duration, Curve? curve}) async {
    if (week.isBefore(_minDate) || week.isAfter(_maxDate)) {
      throw "Invalid date selected.";
    }
    await _pageController.animateToPage(
      _minDate.getWeekDifference(week, start: widget.startDay),
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Returns the current visible week's first date.
  DateTime get currentDate => DateTime(
      _currentStartDate.year, _currentStartDate.month, _currentStartDate.day);

  /// Jumps to page which contains given events and make event
  /// tile visible to user.
  ///
  Future<void> jumpToEvent(CalendarEventData<T> event) async {
    jumpToWeek(event.date);

    await _scrollConfiguration.setScrollEvent(
      event: event,
      duration: Duration.zero,
      curve: Curves.ease,
    );
  }

  /// Animate to page which contains given events and make event
  /// tile visible to user.
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  ///
  /// Actual duration will be 2 times the given duration.
  ///
  /// Ex, If provided duration is 200 milliseconds then this function will take
  /// 200 milliseconds for animate to page then 200 milliseconds for
  /// scroll to event tile.
  ///
  ///
  Future<void> animateToEvent(CalendarEventData<T> event,
      {Duration? duration, Curve? curve}) async {
    await animateToWeek(event.date, duration: duration, curve: curve);
    await _scrollConfiguration.setScrollEvent(
      event: event,
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// Animate to specific scroll controller offset
  void animateTo(
    double offset, {
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.linear,
  }) {
    _scrollController.animateTo(
      offset,
      duration: duration,
      curve: curve,
    );
  }

  /// check if any dates contains current date or not.
  /// Returns true if it does else false.
  bool _showLiveTimeIndicator(List<DateTime> dates) =>
      dates.any((date) => date.compareWithoutTime(DateTime.now()));
}
