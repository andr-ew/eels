#!/bin/bash

mkdir build
cd ..
zip -r eels/build/complete-source-code.zip eels/ -x "eels/.git/*"
