
if [ "$local_pod_addr" ]; then
    LOCAL_POD_ADDR=$local_pod_addr
else
    LOCAL_POD_ADDR=$(ip route get 1 | awk '{print $(NF-2);exit}')
fi

sed -i 's/LOCAL_REPLACE/'$LOCAL_POD_ADDR'/g' /srsLTE/build/srsepc/src/epc.conf

sed -i 's/SGI_MB_IF_ADDR_REPLACE/'$sgi_mb_if_addr'/g' /srsLTE/build/srsepc/src/mbms.conf
sed -i 's/SGI_IF_ADDR_REPLACE/'$sgi_if_addr'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/MME_CODE_REPLACE/'$mme_code'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/MME_GROUP_REPLACE/'$mme_group'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/TAC_REPLACE/'$tac'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/MCC_REPLACE/'$mcc'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/MNC_REPLACE/'$mnc'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/DB_FILE_REPLACE/'$db_file'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/DNS_ADDR_REPLACE/'$dns_addr'/g' /srsLTE/build/srsepc/src/epc.conf
