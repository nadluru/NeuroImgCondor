#/bin/sh
cd CHTCCompile
rm -f *.tar.gz
tar -zcvf NODDIFiles.tar.gz *.m
rm -f *.m
chtc_mcc --mfiles=NODDIFiles.tar.gz --mtargets=NODDIFittingCondor.m --stderr
