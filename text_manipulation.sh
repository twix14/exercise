#!/bin/sh
grep "^.*:$(grep "^$(whoami):.*" /etc/passwd | awk -F : '{print $4}'):.*" /etc/group | awk -F : '{print $4}' | tr ","  "\n"