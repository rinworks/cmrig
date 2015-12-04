# rig

Software system for Rinworks' Computerized Microscopic (CM) Imaging Rig. Built by Sarang Joshi and Joseph Joy.

## Overview

The `rigserver` package provides basic objects and functions that make controlling a CM Rig easy, using the familiar [Processing IDE](http://processing.org). The library provides the following objects:

- `RigSys`: The central object that provides access to various features of the rig server.
- `RigUtils`: Provides utility functions such as setting up matrix path.
- `Rig`: Represents a CM Rig, with controls such as queueing moves, taking pictures, and switching lights on and off.

## Install

Since `rigserver` is a Processing library, the steps to use the CM Rig library are the same as the process of importing a third-party library into Processing.