#!/usr/bin/python
# vim: ts=4:sw=4
# Convert the exported SMS messages from XML to CSV

import xml.dom.minidom
import sys, os
import time, datetime

try:
	docfile = sys.argv[1]
except:
	docfile = "/home/schmelzer64/documents/notes/Commerce/divorce/sms-20100831213351.xml"

docobject = xml.dom.minidom.parse(docfile)
offset = 2 # or you could trim the XML file and use an offset of 0
rootnode = docobject.childNodes[offset]
smsnodelist = rootnode.getElementsByTagName(u'sms')

myphone = "2027442845"
fields = ("date", "address", "type", "body")
for smselement in smsnodelist:
	sms_dict = {}
	for f in fields:
		sms_dict[f] = smselement.getAttribute(f)

	d = int(sms_dict['date']) / 1000
	datestamp = datetime.datetime.fromtimestamp(d)
	datestring = datestamp.isoformat()

	body = sms_dict['body'].encode('ascii','replace')
	for c in ('\n', '\r'):
		body = body.replace(c, "")

	if sms_dict["type"] == "1":
		# From
		print "%s,%s,%s,\"%s\"" % (datestring, sms_dict['address'], myphone, body)
	else:
		# To
		print "%s,%s,%s,\"%s\"" % (datestring, myphone, sms_dict['address'], body)


