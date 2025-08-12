# Hybrid Step Tracking Implementation

## Overview

This document describes the implementation of a hybrid step tracking system that combines three different approaches to provide the best possible step counting experience:

1. **Google Fit Integration** - Cloud-based step tracking with cross-device sync
2. **Real Device Sensors** - Accelerometer-based step detection using device hardware
3. **Manual Entry** - User-provided step counts for accuracy

## Architecture

### Core Components

#### 1. StepsService (`lib/src/services/steps_service.dart`)
The main service that orchestrates all three tracking methods and provides a unified interface.

#### 2. ActivityPage (`lib/src/pages/activity_page.dart`)
The UI that displays tracking status, provides controls, and shows real-time sensor information.

#### 3. Native Android Bridge (`android/app/src/main/kotlin/`)
Kotlin code that handles Google Fit API calls and permission management.

## Implementation Details

### Real Device Sensor Tracking

#### Accelerometer Integration
- Uses `sensors_plus` package for cross-platform accelerometer access
- Implements a sophisticated step detection algorithm
- Provides real-time movement analysis

#### Step Detection Algorithm
```dart
bool _detectStep(double magnitude) {
  final now = DateTime.now();
  
  // Check minimum time interval between steps
  if (_lastStepTime != null && 
      now.difference(_lastStepTime!).inMilliseconds < _minStepIntervalMs) {
    return false;
  }
  
  // Check if magnitude change exceeds threshold
  final magnitudeChange = (magnitude - _lastMagnitude).abs();
  
  // Dynamic threshold based on walking state
  double currentThreshold = _stepThreshold;
  if (_isWalking && _consecutiveSteps > 5) {
    currentThreshold *= 0.8; // Lower threshold when walking consistently
  }
  
  if (magnitudeChange > currentThreshold) {
    _lastStepTime = now;
    return true;
  }
  
  return false;
}
```

#### Key Features
- **Buffer Smoothing**: Maintains a 10-reading buffer for noise reduction
- **Dynamic Thresholds**: Adjusts sensitivity based on walking patterns
- **Consecutive Step Tracking**: Identifies walking vs. random movement
- **Real-time Updates**: Processes accelerometer data continuously

### Hybrid Approach Logic

#### Priority System
1. **Google Fit** (Highest Priority)
   - Automatically used when connected
   - Provides cloud sync and backup
   - Stops device sensors when active

2. **Device Sensors** (Medium Priority)
   - Activates when Google Fit unavailable
   - Provides real-time tracking
   - Automatically switches based on availability

3. **Manual Entry** (Lowest Priority)
   - Available as fallback
   - Allows user correction
   - Maintains data integrity

#### Automatic Switching
```dart
Future<void> initialize() async {
  // Try Google Fit first
  try {
    final connected = await _fitness.invokeMethod('isConnected') == true;
    if (connected && await _checkAndRequestActivityRecognitionPermission()) {
      _useReal = true;
      _connected = true;
      await _loadRealToday();
      await _loadRealWeekly();
      return;
    }
  } catch (e) {
    _connected = false;
  }

  // Fall back to device sensors
  if (!_connected) {
    await _initializeDeviceSensors();
  }
}
```

### User Interface Enhancements

#### Tracking Method Status
- **Visual Indicators**: Color-coded icons for each tracking method
- **Real-time Updates**: Shows current walking state and consecutive steps
- **Accuracy Information**: Displays sensor confidence levels

#### Sensor Calibration
- **Adjustable Thresholds**: Slider from 5.0 (sensitive) to 20.0 (strict)
- **Real-time Feedback**: Shows current threshold value
- **User Guidance**: Tips for optimal calibration

#### Recommendations Engine
- **Contextual Advice**: Different suggestions based on current state
- **Installation Checks**: Verifies Google Fit availability
- **Permission Guidance**: Helps users grant necessary permissions

## Technical Features

### Permission Management
- **ACTIVITY_RECOGNITION**: Required for step counting on Android 10+
- **Runtime Requests**: Handles permission grants and denials
- **Graceful Degradation**: Falls back to manual entry if permissions denied

### Data Management
- **Daily Resets**: Automatically resets counts at midnight
- **Weekly Aggregation**: Maintains 7-day rolling history
- **Data Persistence**: Caches data for offline access

### Performance Optimization
- **Efficient Sensor Processing**: Minimal battery impact
- **Smart Updates**: Only notifies UI when necessary
- **Memory Management**: Proper cleanup of subscriptions and timers

## Usage Instructions

### For Users

#### 1. First Time Setup
- Grant `ACTIVITY_RECOGNITION` permission when prompted
- The app will automatically choose the best available tracking method

#### 2. Google Fit Connection
- Tap "Connect to Google Fit" button
- Follow Google's authentication flow
- Enjoy automatic cloud sync

#### 3. Device Sensor Calibration
- Adjust the sensitivity slider based on your walking pattern
- Start with default settings and fine-tune as needed
- Monitor the accuracy indicators for feedback

#### 4. Manual Entry
- Use the manual step input form when needed
- Perfect for correcting inaccurate counts
- Maintains data integrity across all methods

### For Developers

#### Adding New Tracking Methods
1. Implement the tracking logic in `StepsService`
2. Add appropriate getters and state variables
3. Update the UI in `ActivityPage`
4. Test the fallback logic

#### Customizing Step Detection
- Modify `_stepThreshold` range in the calibration slider
- Adjust `_minStepIntervalMs` for different walking speeds
- Customize the buffer size for different noise levels

## Benefits of Hybrid Approach

### 1. **Reliability**
- Multiple fallback options ensure continuous tracking
- No single point of failure
- Graceful degradation when services unavailable

### 2. **Accuracy**
- Google Fit provides validated data
- Device sensors offer real-time precision
- Manual entry allows user correction

### 3. **User Experience**
- Seamless switching between methods
- Clear visibility into current tracking state
- Customizable sensitivity for personal preferences

### 4. **Battery Efficiency**
- Smart sensor management
- Automatic method switching
- Minimal background processing

## Future Enhancements

### Potential Improvements
1. **Machine Learning**: Train step detection on user patterns
2. **GPS Integration**: Combine with location data for route tracking
3. **Social Features**: Share achievements and compete with friends
4. **Health Insights**: Provide detailed analytics and trends

### Platform Expansion
1. **iOS Support**: Implement HealthKit integration
2. **Wearable Devices**: Connect to smartwatches and fitness bands
3. **Web Dashboard**: Browser-based tracking and analytics

## Troubleshooting

### Common Issues

#### 1. Steps Not Counting
- Check `ACTIVITY_RECOGNITION` permission
- Verify Google Fit connection status
- Ensure device sensors are active

#### 2. Inaccurate Counts
- Adjust sensor calibration slider
- Check walking pattern consistency
- Verify Google Fit data sync

#### 3. Battery Drain
- Monitor sensor usage in device settings
- Check if multiple tracking methods are active
- Review background app restrictions

### Debug Information
- Enable debug mode for detailed logging
- Check console output for sensor events
- Monitor permission status changes

## Conclusion

The hybrid step tracking implementation provides a robust, user-friendly solution that maximizes accuracy while ensuring reliability. By combining the strengths of multiple tracking methods, users get the best possible experience regardless of their device capabilities or preferences.

The system automatically adapts to changing conditions and provides clear feedback about its current state, making it easy for users to understand and optimize their step tracking experience.

