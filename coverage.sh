#!/bin/bash
flutter test --coverage --test-randomize-ordering-seed random && genhtml coverage/lcov.info -o coverage/
flutter pub global run flutter_coverage_badge
