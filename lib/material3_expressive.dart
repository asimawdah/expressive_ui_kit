/// Material 3 Expressive widgets for Flutter.
///
/// Drop-in expressive replacements for standard Material widgets:
///
/// | Standard Material              | Material 3 Expressive        |
/// |--------------------------------|------------------------------|
/// | ElevatedButton / FilledButton  | [MEButton]                   |
/// | IconButton                     | [MEIconButton]               |
/// | SegmentedButton                | [MEButtonGroup]              |
/// | (new)                          | [METoggleButton]             |
/// | FloatingActionButton           | [MEFab] / [MEFabMenu]        |
/// | LinearProgressIndicator        | [MELinearProgressIndicator]  |
/// | CircularProgressIndicator      | [MECircularProgressIndicator]|
/// | (new)                          | [MELoadingIndicator]         |
/// | Slider                         | [MESlider]                   |
/// | Switch                         | [MESwitch]                   |
/// | Checkbox                       | [MECheckbox]                 |
/// | Radio                          | [MERadio]                    |
/// | AppBar / SliverAppBar          | [MEAppBar]                   |
/// | BottomAppBar                   | [METoolbar]                  |
/// | NavigationBar                  | [MENavigationBar]            |
/// | NavigationRail                 | [MENavigationRail]           |
/// | Drawer / NavigationDrawer      | [MEDrawer]                   |
/// | TabBar                         | [METabBar]                   |
/// | Card                           | [MECard]                     |
/// | Chip / FilterChip              | [MEChip]                     |
/// | CarouselView                   | [MECarousel]                 |
/// | AlertDialog / showDialog       | [MEDialog] / [showMEDialog]  |
/// | showModalBottomSheet           | [showMEBottomSheet]          |
/// | SnackBar                       | [showMESnackBar]             |
/// | TextField / TextFormField      | [METextField]                |
/// | SearchBar                      | [MESearchBar] / [MESearchAnchor] |
/// | ListTile                       | [MEListTile] / [MEListGroup] / [MECardList] |
/// | ExpansionTile                  | [MEExpansionTile]            |
/// | PopupMenuButton / MenuAnchor   | [MEMenuAnchor]               |
/// | DropdownButton / DropdownMenu  | [MEDropdown]                 |
/// | Badge                          | [MEBadge]                    |
/// | Tooltip                        | [METooltip]                  |
/// | Divider                        | [MEDivider]                  |
/// | showDatePicker                 | [showMEDatePicker]           |
/// | showTimePicker                 | [showMETimePicker]           |
/// | SliverList                     | [MESliverList]               |
/// | SliverGrid                     | [MESliverGrid]               |
/// | SliverPersistentHeader         | [MESliverPinnedHeader]       |
/// | Scaffold + CustomScrollView    | [MESliverScaffold]           |
/// | (new)                          | [MESliverSectionHeader]      |
/// | (new)                          | [MESplitButton]              |
/// | RangeSlider                    | [MERangeSlider]              |
/// | BottomAppBar                   | [MEBottomAppBar]             |
/// | MaterialBanner                 | [MEBanner]                   |
/// | RefreshIndicator               | [MERefreshIndicator]         |
/// | Stepper                        | [MEStepper]                  |
/// | DataTable                      | [MEDataTable]                |
/// | PaginatedDataTable             | [MEPaginatedDataTable]       |
/// | ReorderableListView            | [MEReorderableList]          |
/// | SegmentedButton                | [MESegmentedButton]          |
/// | CircleAvatar                   | [MEAvatar] / [MEAvatarGroup] |
/// | Dismissible                    | [MEDismissible]              |
/// | Autocomplete                   | [MEAutocomplete]             |
/// | (new)                          | [MEPageIndicator]            |
/// | (new)                          | [showMESideSheet]            |
/// | (new)                          | [MEMarkdown]                 |
/// | (new)                          | [MEMarkdownEditor]           |
/// | (new)                          | [MEChatBubble]               |
/// | (new)                          | [MEChatInput]                |
/// | (new)                          | [MEChatTypingIndicator]      |
/// | (new)                          | [MERating]                   |
/// | (new)                          | [MEOtpInput]                 |
/// | (new)                          | [MESkeleton]/[MESkeletonizer]|
/// | (new)                          | [MENumberTicker]             |
/// | (new)                          | [METimeline]                 |
/// | (new)                          | [MEMorphingShape]            |
/// | (new)                          | [MESelection]                |
/// | (new)                          | [MEExpandableList]           |
/// | (new)                          | [MEDismissibleColumn] / [MEDismissibleList] |
/// | (new)                          | [MEDialTimePicker]           |
/// | showDateRangePicker            | [showMEDateRangePicker]      |
/// | SearchAnchor                   | [MESearchAnchor] / [MESearchAppBar] |
/// | (new)                          | [showMEFullScreenDialog]     |
/// | (new)                          | [showMESelectionDialog]      |
/// | CalendarDatePicker             | [MECalendar]                 |
/// | (new)                          | [METagInput]                 |
/// | (new)                          | [METreeView]                 |
/// | (new)                          | [MEEmptyState]               |
/// | (new)                          | [MEProgressButton]           |
/// | (new)                          | [MECodeView]                 |
/// | (new)                          | [MEFileCard]                 |
/// | Image.network                  | [MEImage]                    |
/// | (new)                          | [MEColorPicker]              |
/// | (new)                          | [MEPasswordField]            |
/// | (new)                          | [MESparkline]                |
/// | (new)                          | [MEBarChart]                 |
/// | (new)                          | [MEFlipCard]                 |
/// | (new)                          | [MECountdown]                |
/// | (new)                          | [MEGauge]                    |
/// | (new)                          | [MEDonutChart]               |
/// | (new)                          | [showMEToast]                |
/// | (new)                          | [MEBreadcrumbs]              |
/// | (new)                          | [MESwipeDeck]                |
/// | (new)                          | [MEFloatingToolbar]          |
/// | ExpansionPanelList             | [MEAccordion]                |
/// | (new)                          | [MEStatCard]                 |
/// | (new)                          | [MESlideToConfirm]           |
/// | (new)                          | [MEHeatmap]                  |
/// | (new)                          | [MEQuantityStepper]          |
/// | (new)                          | [MECompareSlider]            |
/// | CupertinoPicker                | [MEWheelPicker]              |
/// | (new)                          | [MELineChart]                |
/// | (new)                          | [showMECoachmark]            |
/// | (new)                          | [MESuccessCheck]             |
/// | (new)                          | [MEActivityRings]            |
/// | (new)                          | [MERadarChart]               |
/// | (new)                          | [MEWaveform]                 |
/// | (new)                          | [MEMarquee]                  |
/// | (new)                          | [showMECommandPalette]       |
/// | (new)                          | [MEDock]                     |
/// | (new)                          | [METiltCard]                 |
/// | (new)                          | [MEStoryRing]                |
/// | (new)                          | [MEKnob]                     |
/// | (new)                          | [MEEqualizer]                |
/// | (new)                          | [MELiquidProgress]           |
/// | (new)                          | [METypewriter]               |
/// | (new)                          | [MEHoldButton]               |
/// | (new)                          | [MEStopwatch]                |
/// | (new)                          | [MEJoystick]                 |
/// | (new)                          | [MEFlipClock]                |
/// | (new)                          | [MESpinWheel]                |
/// | (new)                          | [MEScratchCard]              |
/// | (new)                          | [MEFunnelChart]              |
/// | (new)                          | [MECompass]                  |
/// | (new)                          | [MEDice]                     |
/// | (new)                          | [MEBreathingRing]            |
/// | (new)                          | [MEStackedBarChart]          |
/// | (new)                          | [METhermometer]              |
/// | (new)                          | [MEBattery]                  |
/// | (new)                          | [MECoinFlip]                 |
/// | (new)                          | [MESlotMachine]              |
/// | (new)                          | [MEMetronome]                |
/// | (new)                          | [MESignalStrength]           |
/// | (new)                          | [MECreditCard]               |
/// | (new)                          | [MEOrbitMenu]                |
/// | (new)                          | [MEStickyNote]               |
/// | (new)                          | [MEMoodPicker]               |
/// | (new)                          | [MEStreakFlame]              |
/// | (new)                          | [MEPolaroid]                 |
/// | (new)                          | [MELikeButton]               |
/// | (new)                          | [MEVuMeter]                  |
/// | (new)                          | [MESonar]                    |
/// | (new)                          | [MEDayNightToggle]           |
/// | (new)                          | [MESpeedometer]              |
/// | (new)                          | [MEHourglass]                |
/// | (new)                          | [METrafficLight]             |
/// | (new)                          | [MELockDial]                 |
/// | (new)                          | [MEBubbleChart]              |
/// | (new)                          | [MECandlestickChart]         |
/// | (new)                          | [MEFireworks]                |
/// | (new)                          | [MEStampCard]                |
/// | (new)                          | [MELavaLamp]                 |
/// | (new)                          | [MEPomodoro]                 |
/// | (new)                          | [MEBoardingPass]             |
/// | (new)                          | [MEColorWheel]               |
/// | (new)                          | [MESplashScreen]             |
/// | (new)                          | [MEPinPad]                   |
/// | (new)                          | [MEReceipt]                  |
/// | (new)                          | [MEVinyl]                    |
library;

export 'src/buttons/me_button.dart';
export 'src/buttons/expressive_button.dart';
export 'src/buttons/me_button_group.dart';
export 'src/buttons/me_fab.dart';
export 'src/buttons/me_fab_menu.dart';
export 'src/buttons/me_floating_toolbar.dart';
export 'src/buttons/me_hold_button.dart';
export 'src/buttons/me_icon_button.dart';
export 'src/buttons/me_like_button.dart';
export 'src/buttons/me_orbit_menu.dart';
export 'src/buttons/me_progress_button.dart';
export 'src/buttons/me_segmented_button.dart';
export 'src/buttons/me_split_button.dart';
export 'src/buttons/me_toggle_button.dart';
export 'src/charts/me_activity_rings.dart';
export 'src/charts/me_bubble_chart.dart';
export 'src/charts/me_candlestick_chart.dart';
export 'src/charts/me_charts.dart';
export 'src/charts/me_donut_chart.dart';
export 'src/charts/me_funnel_chart.dart';
export 'src/charts/me_gauge.dart';
export 'src/charts/me_heatmap.dart';
export 'src/charts/me_line_chart.dart';
export 'src/charts/me_radar_chart.dart';
export 'src/charts/me_speedometer.dart';
export 'src/charts/me_stacked_bar_chart.dart';
export 'src/charts/me_thermometer.dart';
export 'src/chat/me_chat_bubble.dart';
export 'src/chat/me_chat_input.dart';
export 'src/communication/me_badge.dart';
export 'src/communication/me_countdown.dart';
export 'src/communication/me_banner.dart';
export 'src/communication/me_battery.dart';
export 'src/communication/me_breathing_ring.dart';
export 'src/communication/me_coachmark.dart';
export 'src/communication/me_compass.dart';
export 'src/communication/me_divider.dart';
export 'src/communication/me_equalizer.dart';
export 'src/communication/me_fireworks.dart';
export 'src/communication/me_flip_clock.dart';
export 'src/communication/me_lava_lamp.dart';
export 'src/communication/me_marquee.dart';
export 'src/communication/me_number_ticker.dart';
export 'src/communication/me_page_indicator.dart';
export 'src/communication/me_pomodoro.dart';
export 'src/communication/me_signal_strength.dart';
export 'src/communication/me_snack_bar.dart';
export 'src/communication/me_sonar.dart';
export 'src/communication/me_stopwatch.dart';
export 'src/communication/me_streak_flame.dart';
export 'src/communication/me_success_check.dart';
export 'src/communication/me_toast.dart';
export 'src/communication/me_traffic_light.dart';
export 'src/communication/me_typewriter.dart';
export 'src/communication/me_tooltip.dart';
export 'src/communication/me_vu_meter.dart';
export 'src/containers/me_avatar.dart';
export 'src/containers/me_boarding_pass.dart';
export 'src/containers/me_bottom_sheet.dart';
export 'src/containers/me_card.dart';
export 'src/containers/me_carousel.dart';
export 'src/containers/me_chip.dart';
export 'src/containers/me_compare_slider.dart';
export 'src/containers/me_credit_card.dart';
export 'src/containers/me_dialog.dart';
export 'src/containers/me_empty_state.dart';
export 'src/containers/me_file_card.dart';
export 'src/containers/me_flip_card.dart';
export 'src/containers/me_image.dart';
export 'src/containers/me_morphing_shape.dart';
export 'src/containers/me_polaroid.dart';
export 'src/containers/me_receipt.dart';
export 'src/containers/me_scratch_card.dart';
export 'src/containers/me_side_sheet.dart';
export 'src/containers/me_splash_screen.dart';
export 'src/containers/me_stamp_card.dart';
export 'src/containers/me_stat_card.dart';
export 'src/containers/me_sticky_note.dart';
export 'src/containers/me_story_ring.dart';
export 'src/containers/me_swipe_deck.dart';
export 'src/containers/me_tilt_card.dart';
export 'src/controls/me_checkbox.dart';
export 'src/controls/me_coin_flip.dart';
export 'src/controls/me_day_night_toggle.dart';
export 'src/controls/me_dice.dart';
export 'src/controls/me_joystick.dart';
export 'src/controls/me_knob.dart';
export 'src/controls/me_lock_dial.dart';
export 'src/controls/me_metronome.dart';
export 'src/controls/me_mood_picker.dart';
export 'src/controls/me_quantity_stepper.dart';
export 'src/controls/me_radio.dart';
export 'src/controls/me_range_slider.dart';
export 'src/controls/me_rating.dart';
export 'src/controls/me_slide_to_confirm.dart';
export 'src/controls/me_slider.dart';
export 'src/controls/me_slot_machine.dart';
export 'src/controls/me_spin_wheel.dart';
export 'src/controls/me_switch.dart';
export 'src/controls/me_vinyl.dart';
export 'src/controls/me_waveform.dart';
export 'src/inputs/me_autocomplete.dart';
export 'src/inputs/me_color_picker.dart';
export 'src/inputs/me_otp_input.dart';
export 'src/inputs/me_password_field.dart';
export 'src/inputs/me_pin_pad.dart';
export 'src/inputs/me_search_anchor.dart';
export 'src/inputs/me_search_bar.dart';
export 'src/inputs/me_tag_input.dart';
export 'src/inputs/me_text_field.dart';
export 'src/containers/expressive_icon_container.dart';
export 'src/lists/action_item.dart';
export 'src/lists/item_position.dart';
export 'src/lists/me_accordion.dart';
export 'src/lists/me_card_list.dart';
export 'src/lists/me_data_table.dart';
export 'src/lists/me_paginated_data_table.dart';
export 'src/lists/me_reorderable_list.dart';
export 'src/lists/me_selection.dart';
export 'src/markdown/me_markdown.dart';
export 'src/markdown/me_markdown_editor.dart';
export 'src/markdown/me_syntax_highlight.dart';
export 'src/lists/me_dismissible.dart';
export 'src/lists/me_dismissible_list.dart';
export 'src/lists/me_dropdown.dart';
export 'src/lists/me_expandable_list.dart';
export 'src/lists/me_expansion_tile.dart';
export 'src/lists/me_list_tile.dart';
export 'src/lists/me_menu.dart';
export 'src/lists/me_stepper.dart';
export 'src/lists/me_timeline.dart';
export 'src/lists/me_tree_view.dart';
export 'src/navigation/me_app_bar.dart';
export 'src/navigation/me_bottom_app_bar.dart';
export 'src/navigation/me_breadcrumbs.dart';
export 'src/navigation/me_dock.dart';
export 'src/navigation/me_drawer.dart';
export 'src/navigation/me_navigation_bar.dart';
export 'src/navigation/me_navigation_rail.dart';
export 'src/navigation/me_tab_bar.dart';
export 'src/navigation/me_toolbar.dart';
export 'src/overlays/me_command_palette.dart';
export 'src/pickers/me_calendar.dart';
export 'src/pickers/me_color_wheel.dart';
export 'src/pickers/me_dial_time_picker.dart';
export 'src/pickers/me_pickers.dart';
export 'src/pickers/me_wheel_picker.dart';
export 'src/progress/me_circular_progress.dart';
export 'src/progress/me_hourglass.dart';
export 'src/progress/me_linear_progress.dart';
export 'src/progress/me_liquid_progress.dart';
export 'src/progress/me_loading_indicator.dart';
export 'src/progress/me_refresh_indicator.dart';
export 'src/progress/me_skeleton.dart';
export 'src/slivers/me_sliver_scaffold.dart';
export 'src/slivers/me_slivers.dart';
export 'src/theme/me_motion.dart';
export 'src/theme/me_shapes.dart';
export 'src/theme/me_theme.dart';
