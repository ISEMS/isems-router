#!/bin/sh

TTY=/tmp/SERIAL_1
#echo $TTY
HOSTNAME="${COLLECTD_HOSTNAME:-localhost}"
INTERVAL="${COLLECTD_INTERVAL:-60}"

#stty -F $TTY 9600

# cat /tmp/mppt.log

put_value() {
	local what="$1"
	local value="$2"

	printf "PUTVAL \"%s/OpenMPPT-%s/voltage-%s\" N:%s\n" \
		"$HOSTNAME" "${TTY##*/}" "$what" "$value"
}

put_value in U
put_value out U
put_value mpp U
put_value idle U

while read line; do
	field="${line%% *}"
	value="${line#* }"; value="${value%% *}"	
	case "$line" in
		"V_in "*)
			v_in="${line#V_in }"
			v_in="${v_in%% *}"
			put_value in "$v_in"
		;;
		"V_out "*)
			v_out="${line#V_out }"
			v_out="${v_out%% *}"
			put_value out "$v_out"
		;;
		"V_in_idle "*)
			v_in_idle="${line#V_in_idle }"
			v_in_idle="${v_in_idle%% *}"
			put_value idle "$v_in_idle"
		;;
		"Calculated V_mpp "*)
			v_mpp="${line#Calculated V_mpp }"
			v_mpp="${v_mpp%% *}"
			put_value mpp "$v_mpp"
		;;
	esac

done < $TTY

