set -euo pipefail

TOP=$(pwd)
SRCDIR=$TOP/source
INSTALLDIR=$TOP/install
DEFFILE=$TOP/sstdefs.sh
LOGS=$TOP/logs

# Pull In Urls
. configure_urls.sh

echo "Source code will be placed in $SRCDIR"
echo "Programs will be installed in $INSTALLDIR"
echo "Necessary environment variables will be placed in $DEFFILE"

rm -f sstdefs.sh
rm -rf logs

mkdir logs

PATH=$INSTALLDIR/bin:$PATH
echo export PATH=$INSTALLDIR/bin:'$PATH' >> $DEFFILE

echo -n "Installing autotools... "

touch $LOGS/install_autotools.log
mkdir -p $SRCDIR/autotools
cp install_autotools.sh $SRCDIR/autotools/
cd $SRCDIR/autotools/
PREFIX=$INSTALLDIR ./install_autotools.sh > $LOGS/install_autotools.log 2>&1
cd $TOP

echo "done."

echo -n "Installing Pin 3... "

touch $LOGS/install_pin.log
mkdir -p $INSTALLDIR/packages/pin
cd $INSTALLDIR/packages/pin
wget $PINURL > $LOGS/install_pin.log 2>&1
tar xvzf *.tar.gz >> $LOGS/install_pin.log 2>&1
PIN_HOME=$PWD/$(ls -d */)
cd $TOP

echo "done."

SST_CORE_HOME=$INSTALLDIR
SST_CORE_ROOT=$SRCDIR/sst-core

echo export SST_CORE_HOME=$INSTALLDIR >> $DEFFILE
echo export SST_CORE_ROOT=$SRCDIR/sst-core >> $DEFFILE

#echo export PATH=$INSTALLDIR/bin:'$PATH' >> $DEFFILE

# Install Core

echo -n "Installing sst-core... "
touch $LOGS/install_sst_core.log
mkdir -p $SRCDIR
cd $SRCDIR
git clone $COREREPO
#git clone $COREREPO >> $LOGS/install_sst_core.log 2>&1
cd sst-core
./autogen.sh 
#./autogen.sh >> $LOGS/install_sst_core.log 2>&1
./configure --prefix=$SST_CORE_HOME --disable-mpi >> $LOGS/install_sst_core.log 2>&1
make all -j8 >> $LOGS/install_sst_core.log 2>&1
make install >> $LOGS/install_sst_core.log 2>&1
echo "done."
cd $TOP

# Test core
echo -n "Testing sst-core installation... "

touch $LOGS/sst_tests.log
sst-core-test > $LOGS/sst_tests.log 2>&1
if grep -q "TESTING PASSED" $LOGS/sst_tests.log; then
    echo "done."
else
    echo "failed. Exiting. View logs in $LOGS for details."
    exit
fi

exit

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

