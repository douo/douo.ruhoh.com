# -*- coding:utf-8 -*-


import os
import urllib2
import yaml
import base64
import subprocess


def isprefix(s):
    if len(s) > 3 and s[:3]=='---':
        return True
    return False


def render(fr):
    print 'rending '+fr
    try:
        date = fr[fr.rindex('/')+1:fr.rindex('/')+11]
    except ValueError:
        date = fr[0:10]
    f =open(fr,'r');
    meta = ''
    ctn = ''
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
                ctn = ctn + s
        break;
    f.close()

    # !binary 貌似不是规范的yaml tag。不清楚jekyll的wordpress 转换工具为什么要这样用
    meta = meta.replace('!binary','!!binary')
    data = yaml.safe_load(meta)
    meta = update_meta(data,date)
    ctn = to_markdown(ctn)
    f.close()
    # 见 http://pyyaml.org/ticket/11
    return yaml.safe_dump(meta, allow_unicode=True,explicit_start=True)  + '---\n' + ctn


def update_meta(meta,date):
    cc = ['Coder','Life','Otaku']
    cs =[];
    for c in cc:
        try:
            cs.append( meta['tags'].pop(meta['tags'].index(c)))
        except:
            pass
    meta['categories'] = cs
    meta['date']=date
    return meta
    
def write(data,to):
    #print data
    f = open(to,'w')
    f.write(data)
    f.close()

def to_markdown(html):
    p = subprocess.Popen(
        ['/usr/local/bin/pandoc', '--from=html', '--to=markdown+lhs'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE)
    return p.communicate(html)[0]
    

def ensure_dir(dir):
    if not os.path.exists(dir):
        os.makedirs(dir)

output_dir = './oput'
input_dir ='./_posts'
ensure_dir(output_dir)
for fn in os.listdir(input_dir):
    if (fn[-4:]=='html'):
        data = render(input_dir+'/'+fn)
        fn = urllib2.unquote(fn)
        write(data,output_dir+'/'+fn[11:-4]+'md')



