
sed -i 's/ENB_ID_REPLACE/'$enb_id'/g' /empower-srsLTE/build/srsenb/src/enb.conf
sed -i 's/PHY_CELL_ID_REPLACE/'$phy_cell_id'/g' /empower-srsLTE/build/srsenb/src/enb.conf
sed -i 's/CELL_ID_REPLACE/'$cell_id'/g' /empower-srsLTE/build/srsenb/src/enb.conf
sed -i 's/TAC_REPLACE/'$tac'/g' /empower-srsLTE/build/srsenb/src/enb.conf
sed -i 's/MCC_REPLACE/'$mcc'/g' /empower-srsLTE/build/srsenb/src/enb.conf
sed -i 's/MNC_REPLACE/'$mnc'/g' /empower-srsLTE/build/srsenb/src/enb.conf


if [ "$empower_controller" = "yes" ]; then

    while [ -z $(getent hosts runtime-service | awk '{ print $1 }') ]
    do
        echo "Waiting for the empower runtime to come up..."
        sleep 10
    done

    echo "Empower service found"
    EMPOWER_SERVICE_ADDR=$(getent hosts runtime-service | awk '{ print $1 }')

else

    echo "Empower service ignored"

    if [ -z "$empower_pod_addr" ]; then
        EMPOWER_SERVICE_ADDR=127.0.0.1
    else
        echo "Using provided ip address for Empower"
        EMPOWER_SERVICE_ADDR=$empower_pod_addr
    fi

fi


if [ -z "$epc_pod_addr" ]; then
    while [ $(curl -s -o /dev/null -w "%{http_code}" epc-service:9998 --connect-timeout 5) != 200 ]
    do
        echo "Waiting for the epc to come up..."
        sleep 10
    done

    echo "Epc service found"
    EPC_POD_ADDR=$(curl epc-service:9998)
else
    EPC_POD_ADDR=$epc_pod_addr
fi

if [ -z "$local_pod_addr" ]; then
    LOCAL_POD_ADDR=$(ip route get 1 | awk '{print $(NF-2);exit}')
else
    LOCAL_POD_ADDR=$local_pod_addr
fi

sed -i 's/EPC_REPLACE/'"$EPC_POD_ADDR"'/g' /empower-srsLTE/build/srsenb/src/enb.conf
sed -i 's/LOCAL_REPLACE/'$LOCAL_POD_ADDR'/g' /empower-srsLTE/build/srsenb/src/enb.conf
sed -i 's/EMPOWER_REPLACE/'$EMPOWER_SERVICE_ADDR'/g' /empower-srsLTE/build/srsenb/src/enb.conf
