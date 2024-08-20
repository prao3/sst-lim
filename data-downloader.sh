#!/bin/bash

# Getting SST data from NOAA
# Saving the data in the directory this script is run

# Getting bounds on data from user
echo "Starting year:"
read start_year

echo "Ending year (exclusive):"
read end_year

echo "Downloading..."

# Prints all urls for data in given year and month
# The first input variable is the year
# The second input variable is the month
save_url() {
        # Year
        yr=$1
        # Month
        mth=$2
        # Assigning the number of days to loop over for downloads
        if (( mth == 1 || mth == 3 || mth == 5 || mth == 7 || mth == 8 || mth == 10 || mth == 12 )); then
                # 31 days in months 1, 3, 5, 7, 8, 10 or 12
                days=31
        # Leap year case
        elif (( mth == 2 && yr % 4 == 0 )); then
                # 29 days in feb for a leap year
                days=29
        # Non leap year case
        elif (( mth == 2 && yr % 4 != 0 )); then
                # 28 days in feb for a non leap year
                days=28
        # Otherwise, month has 30 days in it
        else
                days=30
        fi
	# Forcing month to have two digits
	printf -v mth "%02d" $mth
        for i in $(seq -f "%02g" 1 $days);
                do
                # Printing data url
                printf "https://www.ncei.noaa.gov/data/sea-surface-temperature-optimum-interpolation/v2.1/access/avhrr/${yr}${mth}/oisst-avhrr-v02r01.${yr}${mth}${i}.nc\n"
        done
}

# Saving URLs for each month from start to stop year
# End year is exclusive, so decrement user input
((end_year--))
for year in $(seq $start_year $end_year);
	do
	# Looping through each month
	for month in $(seq 1 12);
	do
		save_url $year $month >> urls.txt
	done
done

# Timer
start=$SECONDS
# Using xargs to download data in parallel
<urls.txt xargs -P 8 -I % curl -s -O %
# Calculating duration
duration=$(( SECONDS - start ))
echo "Completion time: ${duration}s"
# Removing URL file
rm urls.txt
