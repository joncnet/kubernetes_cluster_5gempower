#!/bin/sh

cd /vgtp
cmake -DCMAKE_BUILD_TYPE=Release .
make

cd /vgtp/click/lvnfs2
autoconf
./configure --prefix=/usr/local
make
sudo make install

cd /

