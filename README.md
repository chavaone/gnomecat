GNOMECAT
=======

## What is GNOMECAT?
GNOMECAT is a computer asisted translation tool written in Vala and created as part of GSoC program.


##Installing

There is a bug (#30) so automake fails :(. To fix this you should touch the file config.rpath:

    touch config.rpath
    
Then you should be able to install the application as a normal app:

    ./autogen.sh
    ./configure
    make
    sudo make install
    
