

if [ "$empower_db_repo" ]; then

    git clone $empower_db_repo /db_files
    cp /db_files/$empower_db_name.db /empower-runtime/deploy/empower.db 

fi
