#!/bin/bash

# first arg:  build_dir
# second arg: report path

# this is getting smelly
builddir=$1
report_path=$2

function jitterbug_build () {
    if [ -f 'dist.ini' ]; then
        echo "Found dist.ini, using Dist::Zilla"
        cpanm Dist::Zilla >> $logfile 2>&1
        dzil authordeps | cpanm >> $logfile 2>&1
        cpanm --installdeps . >> $logfile 2>&1
        HARNESS_VERBOSE=1 HARNESS_TIMER=1 dzil test >> $logfile  2>&1
    elif [ -f 'Build.PL' ]; then
        echo "Found Build.PL, using Build.PL"
        perl Build.PL >> $logfile 2>&1
        # ./Build installdeps is not available in older Module::Build's
        cpanm --installdeps . >> $logfile 2>&1
        # Run this again in case our Build is out of date (suboptimal)
        perl Build.PL >> $logfile 2>&1
        HARNESS_VERBOSE=1 HARNESS_TIMER=1 ./Build test --verbose >> $logfile 2>&1
        coverlogfile="$report_path/perl-$theperl-coverage.txt"
        HARNESS_VERBOSE=1 HARNESS_TIMER=1 ./Build testcover --verbose >> $coverlogfile 2>&1
    elif [ -f 'Makefile.PL' ]; then
        echo "Found Makefile.PL"
        perl Makefile.PL >> $logfile 2>&1
        cpanm --installdeps . >> $logfile 2>&1
        HARNESS_VERBOSE=1 HARNESS_TIMER=1 make test >> $logfile 2>&1
    elif [ -f 'Configure.pl' ]; then
        echo "Found Configure.pl"
        perl Configure.pl >> $logfile 2>&1
        cpanm --installdeps . >> $logfile 2>&1
        HARNESS_VERBOSE=1 HARNESS_TIMER=1 make test >> $logfile 2>&1
    elif [ -f 'Makefile' ]; then
        echo "Found a Makefile"
        make test >> $logfile 2>&1
    fi
}

echo "Creating report_path=$report_path"
mkdir -p $report_path

cd $builddir

export PERLBREW_ROOT=/opt/perlbrew
export PERLBREW_HOME=/opt/perlbrew
source $PERLBREW_ROOT/etc/bashrc

for perl in $PERLBREW_ROOT/perls/perl-5.*
do
  theperl=$($perl -e 'print substr($^V,1')

  logfile="$report_path/perl-$theperl.txt"

  mkdir -p $report_path
  touch $logfile

  echo ">perlbrew use $theperl@jitterbug"
  perlbrew lib create $theperl@jitterbug
  perlbrew use $theperl@jitterbug
  # TODO: check error condition

  jitterbug_build
done
