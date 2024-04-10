#!/bin/bash

cp ../scripts_limit/plotAverage.sh .

if ! command -v pip2 &> /dev/null
then
    sudo apt update
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
    sudo python2 get-pip.py
    pip2 install numpy
fi

for i in $( ls -d */ )
do
    cd $i

    for j in $( ls -d */ )
    do
        cd $j
        cp ../../../scripts_limit/collectlExtract.py .
        cp ../../../scripts_limit/collectlResultFilter.py .
        cp ../../../scripts_limit/collectlResultFilter2.py .
        cp ../../../scripts_limit/collectlProcExtract.py .
        cp ../../../scripts_limit/front_log_extract.py .
        cp ../../../scripts_limit/client_log_extract.py .
        cp ../../../scripts_limit/aggregateInOutPut_ClientTier3.sh .
        echo Copied all python scripts into $j
        python2 collectlExtract.py
        echo RAN collectlExtract.py
        python2 collectlResultFilter.py
        echo RAN collectlResultFilter.py
        python2 collectlResultFilter2.py
        echo RAN collectlResultFilter2.py
        python2 collectlProcExtract.py
        echo RAN collectlProcExtract.py
        # We don't need to run front_log_extract.py because we don't have sysdig logs
        # python2 front_log_extract.py
        # echo RAN front_log_extract.py

        rm result.jtl
        cat result*.jtl >> result.jtl
        python2 client_log_extract.py

        ./aggregateInOutPut_ClientTier3.sh

        cd ..
    done

    cd ..
done

./plotAverage.sh