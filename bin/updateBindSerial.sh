#!/bin/bash

zone="${1}"

set -o nounset
set -o errexit
set -o pipefail

if [ -z "${zone}" ]
then
    echo "You must pass in the path to the zone file to update"
    exit 1
fi

oldserial=`grep '; Serial' "${zone}" | awk '{ print $1 }'`
date=${oldserial:0:8}
rev=${oldserial:8}

curdate=`date +%Y%m%d`

if [ "${curdate}" -ne "${date}" ]
then
    rev="00";
else
    rev=$((rev+1))
fi

if [ ${#rev} == 1 ]
then
    rev="0${rev}"
elif [ ${#rev} >= 3 ]
then
    echo "${rev} can not be more then 99 with this schema."
    exit 1
fi

serial="${curdate}${rev}";

echo "Updating the named serial from ${oldserial} to ${serial}"

sed -i'' -e"s/${oldserial}/${serial}/" "${zone}"

if [ $? -ne 0 ]
then
    echo "Failed!"
    exit 1
fi

exit 0
