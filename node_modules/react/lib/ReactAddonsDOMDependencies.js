/**
 * Copyright 2013-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 */

'use strict';

var ReactDOM = require('react-dom/lib/ReactDOM');
var ReactInstanceMap = require('react-dom/lib/ReactInstanceMap');

exports.getReactDOM = function () {
  return ReactDOM;
};

exports.getReactInstanceMap = function () {
  return ReactInstanceMap;
};

if (process.env.NODE_ENV !== 'production') {
  var ReactPerf = require('react-dom/lib/ReactPerf');
  var ReactTestUtils = require('react-dom/lib/ReactTestUtils');

  exports.getReactPerf = function () {
    return ReactPerf;
  };

  exports.getReactTestUtils = function () {
    return ReactTestUtils;
  };
}