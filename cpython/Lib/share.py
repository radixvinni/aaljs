#!/usr/bin/env python
# -*- coding: utf-8 -*-
"module for distant string sharing"
from _socket import urlopen

def urlencode(d):
        return '&'.join(['%s=%s'%(k,v) for (k,v) in d.items()])


class Share(object):
    def __init__(self,*args):
	self.url_base = '/'.join(args)
	
    def __setattr__(self,name,val):
        urlopen(self.url_base+'/set/'+name,urlencode(val))
        
    def __getattr__(self,name):
        data = urlopen(self.url_base+'/get/'+name)
        if not len(data): raise KeyError
        return data

    @property
    def __dict__(self):
        data = urlopen(self.url_base+'/list')
        return json.loads(data)
    def __dir__(self):return self.__dict__.keys()
    def __contains__(self,var): return var in self.__dict__
