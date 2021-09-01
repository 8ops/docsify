#!/usr/bin/env python

import pymongo
import time

DAYS = 100 #max keeping user location

connection = pymongo.MongoClient("localhost", 27017)
db = connection.uplus
lastLoginTime = int(time.time() - 86400 * DAYS) * 1000

#delete expired data
db.userLocation.remove({'lastLoginTime':{'$lt': lastLoginTime}})

#reindex
db.userLocation.reindex()

