// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:bloc_concurrency_demos/app/app.dart';
import 'package:bloc_concurrency_demos/bootstrap.dart';

void main() {
  bootstrap((preloadedConfig) => App(preloadedConfig: preloadedConfig));
}
