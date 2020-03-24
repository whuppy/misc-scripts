#!/usr/bin/python
# vim: ts=4:sw=4
# Convert the exported SMS messages from XML to CSV

import xml.dom.minidom
import sys, os
import time, datetime

try:
	docfile = sys.argv[1]
except:
	docfile = "sms-selected-20160412171833.xml"

docobject = xml.dom.minidom.parse(docfile)
offset = 2 # or you could trim the XML file and use an offset of 0
rootnode = docobject.childNodes[offset]
mmsnodelist = rootnode.getElementsByTagName(u'mms')

myphone = "2027442845"
for mmselement in mmsnodelist:
	partlist =  mmselement.getElementsByTagName(u'part')
	print "parts: %s" % partlist
	for part in partlist:
		partCt = part.getAttribute("ct")
		print "Content-type: %s" % partCt
		if "text/plain" == partCt:
			message = part.getAttribute("text")
			print "text: %s" % message
	addrlist =  mmselement.getElementsByTagName(u'addr')
	print "addrs: %s" % addrlist
	for addr in addrlist:
		phonenumber = addr.getAttribute("address")
		print "Address: %s" % phonenumber
