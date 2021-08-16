TOP=$(pwd)
SRCDIR=$TOP/source
INSTALLDIR=$TOP/install
DEFFILE=$TOP/sstdefs.sh

# Pull In Urls
. configure_urls.sh

echo "Source code will be placed in $SRCDIR"
echo "Programs will be installed in $INSTALLDIR"
echo "Necessary environment variables will be placed in $DEFFILE"

rm -f sstdefs.sh

PATH=$INSTALLDIR/bin:$PATH
echo export PATH=$INSTALLDIR/bin:'$PATH' >> $DEFFILE

echo "Installing autotools"

mkdir -p $SRCDIR/autotools
cp install_autotools.sh $SRCDIR/autotools/
cd $SRCDIR/autotools/
PREFIX=$INSTALLDIR ./install_autotools.sh
cd $TOP

echo "Installing Pin 3"

mkdir -p $INSTALLDIR/packages/pin
cd $INSTALLDIR/packages/pin
wget $PINURL
tar xvzf *.tar.gz
PIN_HOME=$PWD/$(ls -d */)
cd $TOP

SST_CORE_HOME=$INSTALLDIR
SST_CORE_ROOT=$SRCDIR/sst-core

echo export SST_CORE_HOME=$INSTALLDIR >> $DEFFILE
echo export SST_CORE_ROOT=$SRCDIR/sst-core >> $DEFFILE

#echo export PATH=$INSTALLDIR/bin:'$PATH' >> $DEFFILE

# Install Core

mkdir -p $SRCDIR
cd $SRCDIR
git clone $COREREPO
cd sst-core
./autogen.sh
./configure --prefix=$SST_CORE_HOME --disable-mpi
make all -j8
make install
cd $TOP

# Install Cmake
mkdir -p $SRCDIR/cmake
cd $SRCDIR/cmake
wget $CMAKEURL
tar xzf *.tar.gz
cd $(ls -d */)
cp bin/* $INSTALLDIR/bin/
cp -r share/* $INSTALLDIR/share/
cd $TOP

# Install DramSIM3
mkdir $SRCDIR
cd $SRCDIR
git clone $DRAMSIM3REPO
cd DRAMsim3
cmake .
make -j8
DRAMDIR=$PWD
cd $TOP

# Install Elements

SST_ELEMENTS_HOME=$INSTALLDIR
SST_ELEMENTS_ROOT=$SRCDIR/sst-elements

echo export SST_ELEMENTS_HOME=$INSTALLDIR >> $DEFFILE
echo export SST_ELEMENTS_ROOT=$SRCDIR/sst-elements >> $DEFFILE

mkdir -p $SRCDIR
cd $SRCDIR
git clone $ELEMENTSREPO
cd sst-elements
# Remove Werror lmao
find . -name Makefile.am -exec sed -i s'/-Werror//g' {} \;
./autogen.sh
./configure --prefix=$SST_ELEMENTS_HOME --with-sst-core=$SST_CORE_HOME --with-pin=$PIN_HOME --with-dramsim3=$DRAMDIR
#make all -j8
#make install
cd $TOP

echo "Done"

