#!/usr/bin/python
# rudimentary craps simulator 2012-09-19 mjs

import random
import logging

def twodsix():
	'''
	Roll 2d6.
	'''
	return random.randrange(1, 7) + random.randrange(1, 7)

def crapsround():
	'''
	Play a round of craps. 
	Return 1 for win, 0 for lose.
	'''
	comeout = twodsix()
	logging.info("Come out roll: %s" % comeout)
	if comeout in [7, 11]:
		logging.info( "Natural win!")
		return 1
	elif comeout in [2, 3, 12]:
		logging.info( "Craps lose")
		return 0
	elif comeout in [4, 5, 6, 8, 9, 10]:
		logging.info( "Point set to %s" % comeout)
		while 1:
			roll = twodsix()
			logging.info( "Rolled a %d" % roll)
			if roll == comeout:
				logging.info( "Point match win!")
				return 1
			if roll == 7:
				logging.info( "Seven out lose")
				return 0

if __name__ == '__main__':
	games = 10000
	wins = 0
	logging.basicConfig(format='%(message)s', filename="craps.log", filemode='w', level=logging.INFO)
	for i in range(0, games):
		wins = wins + crapsround()
	print "Won %s out of %s" % (wins, games)
