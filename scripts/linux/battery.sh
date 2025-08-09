#! /bin/bash

upower --dump | grep -E 'Device:|model:|percentage:'
