
if [ "$empower_db_url" ]; then

    git clone $empower_db_url /kubernetes_onthefly_files
    cp /kubernetes_onthefly_files/empower.db /empower-runtime/deploy/empower.db 

fi
