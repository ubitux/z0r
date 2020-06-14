#!/usr/bin/env python

import os
import sys
import subprocess
import os.path as op


_N = 16
_REFSDIR, _WWWDIR, _PACKDIR = 'ref', 'docs', 'img'


def _pack_ref_img_cmd(startpos):
    fprefix = 'z0r-de_'
    fsuffix = '.png'
    reffile = op.join(_REFSDIR, 'ref' + fsuffix)
    cmd = ['convert']
    for y in range(_N):
        cmd += ['(']
        for x in range(_N):
            zid = startpos + y*_N + x
            tile = op.join(_REFSDIR, f'{fprefix}{zid}.png')
            if not op.isfile(tile):
                tile = reffile
            cmd += [tile]
        cmd += ['+append', ')']
    cmd += ['-append']
    return cmd


def _pack_imgs(w, h, pack_img, startpos, last):
    imghtml = ''
    for y in range(_N):
        for x in range(_N):
            zid = startpos + y*_N + x
            if zid > last:
                return imghtml
            style  = f'background-image:url(\'{pack_img}\');'
            style += f'background-position:{-x * w}px {-y * h}px;'
            imghtml += f'<div class="c"><h1><a href="https://z0r.de/{zid}">#{zid}</a></h1>'
            imghtml += f'<div class="i" style="{style}"></div></div>\n'
    return imghtml


def _write_css(w, h):
    css = '''
body  { background-color:#444; }
div.c { float:left; border:1px solid #aaa; margin:5px; padding:0; }
div.i { display:block; background-color:#222; background-repeat:no-repeat; width:%dpx; height:%dpx; }
img   { padding:0; margin:0; }
h1    { background-color:black; margin:0; border-bottom:1px solid #aaa; font-size:0.7em; }
a     { color:white; text-decoration:none; }''' % (w, h)
    with open(f'{_WWWDIR}/style.css', 'w') as f:
        f.write(css)


def _write_html(w, h, first, last):
    html = '''<!doctype html>
<html><head><title>z0r.de pic index</title>
<link rel="stylesheet" type="text/css" href="style.css" />
</head><body>\n'''
    for start in range(first, last + 1, _N * _N):
        pack_img = op.join(_PACKDIR, '%04d-%04d.webp' % (start, start + _N * _N))
        pack_img_path = op.join(_WWWDIR, pack_img)
        print('image pack: %s' % pack_img_path)
        cmd = _pack_ref_img_cmd(start)
        ret = subprocess.call(cmd + [pack_img_path])
        assert ret == 0
        html += _pack_imgs(w, h, pack_img, start, last)
    html += '</body></html>'
    with open(op.join(_WWWDIR, 'index.html'), 'w') as f:
        f.write(html)


def _main():
    w = int(sys.argv[1])
    h = int(sys.argv[2])
    first = int(sys.argv[3])
    last  = int(sys.argv[4])
    _write_css(w, h)
    _write_html(w, h, first, last)


if __name__ == '__main__':
    _main()
