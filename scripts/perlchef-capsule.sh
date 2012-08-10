#!/bin/bash

# first arg:  build_dir
# second arg: report path

builddir=$1
report_path=$2

function jitterbug_build () {
    if [ -f 'dist.ini' ]; then
        echo "Found dist.ini, using Dist::Zilla" >> $logfile 2>&1
        cpanm Dist::Zilla >> $logfile 2>&1
        dzil authordeps | cpanm >> $logfile 2>&1
        dzil listdeps | cpanm >> $logfile 2>&1
        HARNESS_VERBOSE=1 HARNESS_TIMER=1 dzil test >> $logfile  2>&1
    elif [ -f 'Build.PL' ]; then
        echo "Found Build.PL, using Build.PL" >> $logfile 2>&1
        perl Build.PL >> $logfile 2>&1
        # ./Build installdeps is not available in older Module::Build's
        cpanm --installdeps . >> $logfile 2>&1
        # Run this again in case our Build is out of date (suboptimal)
        perl Build.PL >> $logfile 2>&1
        HARNESS_VERBOSE=1 HARNESS_TIMER=1 ./Build test --verbose >> $logfile 2>&1
    elif [ -f 'Makefile.PL' ]; then
        echo "Found Makefile.PL" >> $logfile 2>&1
        perl Makefile.PL >> $logfile 2>&1
        cpanm --installdeps . >> $logfile 2>&1
        HARNESS_VERBOSE=1 HARNESS_TIMER=1 make test >> $logfile 2>&1
    elif [ -f 'Configure.pl' ]; then
        echo "Found Configure.pl" >> $logfile 2>&1
        perl Configure.pl >> $logfile 2>&1
        cpanm --installdeps . >> $logfile 2>&1
        HARNESS_VERBOSE=1 HARNESS_TIMER=1 make test >> $logfile 2>&1
    elif [ -f 'Makefile' ]; then
        echo "Found a Makefile" >> $logfile 2>&1
        make test >> $logfile 2>&1
    fi
}

cd $builddir

export HOME=/tmp/jitterbug-home
export PERL5OPT=""
export PERLBREW_ROOT=/opt/perlbrew
export PERLBREW_HOME=/tmp/jitterbug-home
source $PERLBREW_ROOT/etc/bashrc

for perl in $PERLBREW_ROOT/perls/perl-5.*
do
  theperl=$($perl/bin/perl -e 'print substr($^V,1)')

  logfile="$report_path/perl-$theperl.txt"

  mkdir -p $report_path
  touch $logfile

  perlbrew lib create perl-$theperl@jitterbug-$theperl
  perlbrew use perl-$theperl@jitterbug-$theperl

  jitterbug_build
done
