#!/bin/sh

cd /prj
swift build -c release --static-swift-stdlib --arch $1