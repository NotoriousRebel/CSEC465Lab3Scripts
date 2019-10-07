#!/bin/bash
echo "Testing google.com (should be no results)."
python3 axfrtest.py google.com
echo "Testing zonetransfer.me (should be some results)."
python3 axfrtest.py zonetransfer.me