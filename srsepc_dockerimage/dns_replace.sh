LOCAL_POD_ADDR=$(ip route get 1 | awk '{print $(NF-2);exit}')

sed -i 's/LOCAL_REPLACE/'$LOCAL_POD_ADDR'/g' /srsLTE/build/srsepc/src/epc.conf

sed -i 's/SGI_MB_IF_ADDR_REPLACE/'$sgi_mb_if_addr'/g' /srsLTE/build/srsepc/src/mbms.conf
sed -i 's/SGI_IF_ADDR_REPLACE/'$sgi_if_addr'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/MME_CODE_REPLACE/'$mme_code'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/MME_GROUP_REPLACE/'$mme_group'/g' /srsLTE/build/srsepc/src/epc.conf
sed -i 's/TAC_REPLACE/'$tac'/g' /srsLTE/build/srsepc/src/epc.conf
