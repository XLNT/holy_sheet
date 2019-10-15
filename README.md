# holy_sheet

A Flutter sheet & panel widget that's good as hell.

HolySheet respects the following conventions:

1. The sheet is always modal.
2. The sheet is always draggable.
3. The sheet passes its constraints to its child, which it then sizes using a `FractionallySizedBox`.
4. The sheet expects that all scrollable areas within itself respect the gesture arena and declare defeat when reasonable.

## Install

```yml
dependencies:
  holy_sheet: ^0.0.1
```

## Usage

```dart
import 'package:holy_sheet/holy_sheet.dart';

// ... somewhere in your widget tree


```
