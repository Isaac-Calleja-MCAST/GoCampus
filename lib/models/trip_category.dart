/// The student travel scenarios supported by the ride planner.
enum TripCategory {
  campusCommute,
  daytimeBeachDeparture,
  nighttimePartyDeparture,
}

/// User-facing labels and defaults for each travel scenario.
extension TripCategoryLabels on TripCategory {
  String get label {
    return switch (this) {
      TripCategory.campusCommute => 'Campus Commute',
      TripCategory.daytimeBeachDeparture => 'Daytime Beach Departure',
      TripCategory.nighttimePartyDeparture => 'Nighttime Party Departure',
    };
  }

  String get shortLabel {
    return switch (this) {
      TripCategory.campusCommute => 'Campus',
      TripCategory.daytimeBeachDeparture => 'Beach',
      TripCategory.nighttimePartyDeparture => 'Night Out',
    };
  }

  String get timePrompt {
    return switch (this) {
      TripCategory.campusCommute => 'Departure Time',
      TripCategory.daytimeBeachDeparture => 'Beach Departure Time',
      TripCategory.nighttimePartyDeparture => 'Night Departure Time',
    };
  }

  int get defaultHour {
    return switch (this) {
      TripCategory.campusCommute => 8,
      TripCategory.daytimeBeachDeparture => 10,
      TripCategory.nighttimePartyDeparture => 21,
    };
  }
}
