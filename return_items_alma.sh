#!/bin/bash 

# Script zur automatisierten Rueckbuchung von Alma-Rueckgaben ueber die SIP2-Schnittstelle in Aleph 

# Variablen:
# ------------------------
WORKDIR=/opt/scripts/return_items_alma/
DATUM=`date +%Y%m%d`
TIME=`date +%H%M%S`

cd $WORKDIR

echo "Starting returning items of the previous day -- $DATUM -- $TIME" >> $WORKDIR/log/return_items_alma_$DATUM.log

# Abholen Analytics-Reports aus UBE, UBS und ZSB
echo 'Getting data from UBE' >> $WORKDIR/log/return_items_alma_$DATUM.log
perl get_returns_ube.pl 2>> $WORKDIR/log/return_items_alma_$DATUM.log >> $WORKDIR/input/barcodes_ube_$DATUM.sys

echo 'Getting data from UBS' >> $WORKDIR/log/return_items_alma_$DATUM.log
perl get_returns_ubs.pl 2>> $WORKDIR/log/return_items_alma_$DATUM.log >> $WORKDIR/input/barcodes_ubs_$DATUM.sys

echo 'Getting data from ZBS' >> $WORKDIR/log/return_items_alma_$DATUM.log
perl get_returns_zbs.pl 2>> $WORKDIR/log/return_items_alma_$DATUM.log >> $WORKDIR/input/barcodes_zbs_$DATUM.sys

# Rueckbuchungen der Exemplare ueber SIP2
echo 'Returning items via SIP2' >> $WORKDIR/log/return_items_alma_$DATUM.log
perl return_items_sip2.pl >> $WORKDIR/log/return_items_alma_$DATUM.log 2>> $WORKDIR/log/return_items_alma_$DATUM.log

scp $WORKDIR/log/return_items_ubs_$DATUM.log aleph@aleph.unibas.ch:/exlibris/aleph/u22_1/dsv51/scripts/return_items_alma/log/
scp $WORKDIR/log/return_items_ube_$DATUM.log aleph@aleph.unibas.ch:/exlibris/aleph/u22_1/dsv51/scripts/return_items_alma/log/
scp $WORKDIR/log/return_items_zbs_$DATUM.log aleph@aleph.unibas.ch:/exlibris/aleph/u22_1/dsv51/scripts/return_items_alma/log/

echo 'Mails generieren' >> $WORKDIR/log/return_items_alma_$DATUM.log

echo "Alma-Rueckgaben UBS vom Vortag in Aleph zurueckgebucht. Log siehe: https://aleph.unibas.ch/dirlist/u/dsv51/scripts/return_items_alma/log/return_items_ubs_$DATUM.log" | mailx -r ub-alprod@unibas.ch -s "Alma Rueckgaben UBS $DATUM" simone.gloor@unibas.ch silvia.hauser@unibas.ch aleph-ub@unibas.ch
echo "Alma-Rueckgaben UBE vom Vortag in Aleph zurueckgebucht. Log siehe: https://aleph.unibas.ch/dirlist/u/dsv51/scripts/return_items_alma/log/return_items_ube_$DATUM.log" | mailx -r ub-alprod@unibas.ch -s "Alma Rueckgaben UBE $DATUM" alephsupport@ub.unibe.ch aleph-ub@unibas.ch 
echo "Alma-Rueckgaben ZBS vom Vortag in Aleph zurueckgebucht. Log siehe: https://aleph.unibas.ch/dirlist/u/dsv51/scripts/return_items_alma/log/return_items_zbs_$DATUM.log" | mailx -r ub-alprod@unibas.ch -s "Alma Rueckgaben ZBS $DATUM" christine.gasser@zbsolothurn.ch aleph-ub@unibas.ch

echo 'Mails done' >> $WORKDIR/log/return_items_alma_$DATUM.log

echo "Finished returning items of the previous day -- $DATUM -- $TIME" >> $WORKDIR/log/return_items_alma_$DATUM.log

exit


