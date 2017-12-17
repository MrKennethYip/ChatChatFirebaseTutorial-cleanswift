#!/usr/bin/env bash
xcodebuild test -workspace ChatChat.xcworkspace -scheme ChatChat -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2'
