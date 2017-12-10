#!/bin/sh
((bin/compiler < $1.c) > $1.ll) 2> $1.txt
