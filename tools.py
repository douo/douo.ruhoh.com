# -*- coding:utf-8 -*-

import yaml

def isprefix(s):
    if len(s) > 3 and s[:3]=='---':
        return True
    return False


def render(fr):
    f = open(fr)
    meta = ''
    doc = ''
    while(isprefix(f.readline())): 
        while(True):
            s = f.readline()
            if isprefix(s):
                break
            else:
                meta = meta +s
        while(True):
            s = f.readline()
            if s=='':
                break;
            else:
                doc = doc + s
        break;
    f.close()
    return {'meta':meta,'doc':doc}
    
def write(data,to):
    f = open(to,'w')
    s ='---\n'
    s = s+data['meta']
    s = s+'---\n'
    s = s+data['doc']
    f.write(s)
    f.close()
import base64

print text(base64.decodestring('5ZOI5ZOI77yMRkI=')).encode('utf-8')


data = render('./2009-11-17-fb.html')
#write(data,'./wtf.md')



