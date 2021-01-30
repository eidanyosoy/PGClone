    UNWANTED_FILES=(
    '*.nfo'
    '*.jpeg'
    '*.jpg'
    '*.rar'
    '*sample*'
    '*.sh'
    '*.html~'
    '*.url'
    '*.htm'
    '*.html'
    '*.sfv'
    '*.pdf'
    '*.xml'
    '*.exe'
    '*.lsn'
    '*.nzb'
    'Click.rar'
    'What.rar'
    '*sample*'
    '*SAMPLE*'
    '*SaMpLE*'
    '*.nfo'
    '*.jpeg'
    '*.jpg'
    '*.srt'
    '*.idx'
    '*.rar'
    '*sample*'
    )
    # advanced settings
    FIND=$(which find)
    FIND_BASE_CONDITION='-type f'
    FIND_ADD_NAME='-o -name'
    FIND_ACTION='-delete'
    #Folder Setting
    TARGET_FOLDER=$1"$(cat /var/plexguide/server.hd.path)/downloads/nzb/"
    if [ ! -d "${TARGET_FOLDER}" ]; then echo 'Target directory does not exist - skipping '; fi
        condition="-name '${UNWANTED_FILES[0]}'"
    for ((i = 1; i < ${#UNWANTED_FILES[@]}; i++))
    do
        condition="${condition} ${FIND_ADD_NAME} '${UNWANTED_FILES[i]}'"
    done
        command="${FIND} '${TARGET_FOLDER}' -maxdepth 3 ${FIND_BASE_CONDITION} \( ${condition} \) ${FIND_ACTION}"
    echo "Executing ${command}"
    eval "${command}"
