#!/usr/bin/python
import random

result=""
for i in range(0, 75):
	result = result + "%d" % random.randrange(0, 8)
print result

