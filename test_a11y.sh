#!/bin/bash
# Simple script to verify our modifications
if grep -q 'role="progressbar"' dist/templates/dashboard.html; then
  echo "Progressbar a11y added"
else
  echo "Progressbar missing"
fi
