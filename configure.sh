TOP=$(pwd)
SRCDIR=$TOP/source
INSTALLDIR=$TOP/install
DEFFILE=$TOP/sstdefs.sh

# Go to https://software.intel.com/content/www/us/en/develop/articles/pin-a-binary-instrumentation-tool-downloads.html and copy the link to the "Kit" you would like to use for your system
PINURL='https://software.intel.com/sites/landingpage/pintool/downloads/pin-3.20-98437-gf02b61307-gcc-linux.tar.gz'

# Pick your sst repo
SSTREPO=git@github.com:sstsimulator/sst-core.git

echo "Source code will be placed in $SRCDIR"
echo "Programs will be installed in $INSTALLDIR"
echo "Necessary environment variables will be placed in $DEFFILE"

rm -f sstdefs.sh

PATH=$INSTALLDIR/bin:$PATH
echo export PATH=$INSTALLDIR/bin:'$PATH' >> $DEFFILE

echo "Installing autotools"

mkdir -p source/autotools
cp install_autotools.sh source/autotools/
cd source/autotools/
PREFIX=$INSTALLDIR ./install_autotools.sh
cd $TOP

echo "Installing Pin 3"

#mkdir -p install/packages/pin
#cd install/packages/pin
#wget $PINURL
#tar xvzf *.tar.gz
#PIN_HOME=$PWD/$(ls -d */)
#cd $TOP

SST_CORE_HOME=$INSTALLDIR
SST_CORE_ROOT=$SRCDIR/sst-core

echo export SST_CORE_HOME=$INSTALLDIR/sst-core >> $DEFFILE
echo export SST_CORE_ROOT=$SRCDIR/sst-core >> $DEFFILE

#echo export PATH=$INSTALLDIR/bin:'$PATH' >> $DEFFILE


mkdir -p $SRCDIR
cd $SRCDIR
git clone $SSTREPO
cd sst-core
./autogen.sh
./configure --prefix=$SST_CORE_HOME --disable-mpi
make all
make install

echo "Done"

