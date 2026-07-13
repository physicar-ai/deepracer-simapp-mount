#!/usr/bin/env bash
export XAUTHORITY=/root/.Xauthority

# Ensure we have a roll-out index; also when we have only one worker
if [ -z "$ROLLOUT_IDX" ]; then
	export ROLLOUT_IDX=0
fi

# If we have multiple workers we need to do assignment of worker number
# Additionally if multi-config is enabled then the specifc WORLD and 
# YAML files must be assigned.
if [ "$1" == "multi" ]; then

	# Use Docker Swarm Replica .Task.Slot
	if [ -n "$DOCKER_REPLICA_SLOT" ]; then
		WORKER_NUM=$DOCKER_REPLICA_SLOT
	# Create an 'election file' in local file system
	else
		COMMS_FILE=/mnt/comms/workers
		echo $HOSTNAME >> $COMMS_FILE
		WORKER_NUM=$(cat -n $COMMS_FILE | grep $HOSTNAME | cut -f1)
	fi

	export ROLLOUT_IDX=$(expr $WORKER_NUM - 1 )

	# Check if multi-config has been enabled, then override S3_YAML_NAME and WORLD_NAME
	if [ -n "$MULTI_CONFIG" ]; then
		echo $MULTI_CONFIG
		export S3_YAML_NAME=$(echo $MULTI_CONFIG | jq --arg worker $ROLLOUT_IDX -r '.multi_config[$worker | tonumber ].config_file')
		export WORLD_NAME=$(echo $MULTI_CONFIG | jq --arg worker $ROLLOUT_IDX -r '.multi_config[$worker | tonumber ].world_name')
	fi

	echo "Starting as worker $ROLLOUT_IDX, using world $WORLD_NAME and configuration $S3_YAML_NAME."

fi

export DEEPRACER_JOB_TYPE_ENV="LOCAL"

# Always inject physics into the world file.
# 다중 워커가 같은 월드 파일을 공유(bind mount)하므로:
#  - flock: 파일별 직렬화 (잠금 없이는 두 워커가 동시에 "physics 없음"을 보고 이중
#    삽입 + type 속성 중복 <physics type="ode" type="ode">로 XML이 깨지는 레이스)
#  - 임시 사본 편집 후 mv 원자 교체: 락을 안 잡는 독자(gzserver)가 편집 중간
#    상태를 읽는 일이 없게 — rename(2)이라 구본/신본 중 하나만 보임
#  - type 속성은 존재 확인 후에만 추가 (멱등 — 부분 실행/재실행에도 안전)
WORLD_FILE="/opt/simapp/deepracer_simulation_environment/share/deepracer_simulation_environment/worlds/${WORLD_NAME}.world"
MAX_STEP_SIZE=${MAX_STEP_SIZE:-0.001000}
DEFAULT_UPDATE_RATE=$(awk -v step=$MAX_STEP_SIZE 'BEGIN{ printf "%0.6f", 1.0/step}')
(
	flock -x 200
	TMP_WORLD=$(mktemp "${WORLD_FILE}.tmp.XXXXXX")
	cp "$WORLD_FILE" "$TMP_WORLD"
	if xmlstarlet sel -t -c '/sdf/world/physics' "$TMP_WORLD" >/dev/null 2>&1; then
		xmlstarlet ed -L -u '/sdf/world/physics/max_step_size' -v $MAX_STEP_SIZE $TMP_WORLD
		xmlstarlet ed -L -u '/sdf/world/physics/real_time_update_rate' -v $DEFAULT_UPDATE_RATE $TMP_WORLD 2>/dev/null \
			|| xmlstarlet ed -L -s '/sdf/world/physics' -t elem -n real_time_update_rate -v $DEFAULT_UPDATE_RATE $TMP_WORLD
	else
		xmlstarlet ed -L -s '/sdf/world' -t elem -n physics $TMP_WORLD
		xmlstarlet ed -L -s '/sdf/world/physics' -t elem -n max_step_size -v $MAX_STEP_SIZE $TMP_WORLD
		xmlstarlet ed -L -s '/sdf/world/physics' -t elem -n real_time_update_rate -v $DEFAULT_UPDATE_RATE $TMP_WORLD
		xmlstarlet ed -L -s '/sdf/world/physics' -t elem -n gravity -v '0.000000 0.000000 -9.800000' $TMP_WORLD
	fi
	if ! xmlstarlet sel -t -v '/sdf/world/physics/@type' "$TMP_WORLD" >/dev/null 2>&1; then
		xmlstarlet ed -L -i '/sdf/world/physics' -t attr -n type -v ode $TMP_WORLD
	fi
	# 편집 결과가 유효한 XML일 때만 교체 — 어떤 실패에도 원본은 무손상
	if xmlstarlet sel -t -c '/sdf/world/physics' "$TMP_WORLD" >/dev/null 2>&1; then
		mv -f "$TMP_WORLD" "$WORLD_FILE"
	else
		echo "WARNING: physics injection produced invalid XML for ${WORLD_NAME}; keeping original" >&2
		rm -f "$TMP_WORLD"
	fi
) 200>"${WORLD_FILE}.lock"

# Check if we have an RTF_OVERRIDE to change the RTF - change the world file.
if [[ -n "${RTF_OVERRIDE}" ]]; then
	echo "Setting RTF to ${RTF_OVERRIDE} for ${WORLD_NAME}"
	RTF_UPDATE_RATE=$(awk -v rtf=$RTF_OVERRIDE -v step=$MAX_STEP_SIZE 'BEGIN{ update_rate=rtf/step; printf "%0.6f", update_rate}')
	(
		flock -x 200
		TMP_WORLD=$(mktemp "${WORLD_FILE}.tmp.XXXXXX")
		cp "$WORLD_FILE" "$TMP_WORLD"
		if xmlstarlet sel -t -c '/sdf/world/physics/real_time_factor' "$TMP_WORLD" >/dev/null 2>&1; then
			xmlstarlet ed -L -u '/sdf/world/physics/real_time_factor' -v ${RTF_OVERRIDE} $TMP_WORLD
			xmlstarlet ed -L -u '/sdf/world/physics/real_time_update_rate' -v ${RTF_UPDATE_RATE} $TMP_WORLD
		else
			xmlstarlet ed -L -s '/sdf/world/physics' -t elem -n real_time_factor -v ${RTF_OVERRIDE} $TMP_WORLD
			xmlstarlet ed -L -s '/sdf/world/physics' -t elem -n real_time_update_rate -v ${RTF_UPDATE_RATE} $TMP_WORLD
		fi
		if xmlstarlet sel -t -c '/sdf/world/physics' "$TMP_WORLD" >/dev/null 2>&1; then
			mv -f "$TMP_WORLD" "$WORLD_FILE"
		else
			rm -f "$TMP_WORLD"
		fi
	) 200>"${WORLD_FILE}.lock"
	xmlstarlet sel -t -c '/sdf/world/physics' $WORLD_FILE
fi

# Check if we want to do reward-function debugging
if [[ "${DEBUG_REWARD,,}" == "true" ]]; then
	echo "Enabling Reward Debugging"
	patch -p2 -N --directory=/opt/simapp < debug-reward.diff
fi

# If no run-option given then use the distributed training
if [ -z ${2+x} ]; then
	$2 = "distributed_training.launch"
	exit

fi

# Initialize ROS & the Bundle
export IGN_IP=127.0.0.1
source /opt/ros/${ROS_DISTRO}/setup.bash
source setup.bash

# Start an X server if we do not have one
if [[ "${USE_EXTERNAL_X,,}" != "true" ]]; then
	export DISPLAY=:0 # Select screen 0 by default.
	xvfb-run -f $XAUTHORITY -l -n 0 -s ":0 -screen 0 1400x900x24" jwm &
	x11vnc -bg -forever -nopw -rfbport 5900 -display WAIT$DISPLAY &
# Ensure DISPLAY is defined
else
	if [ -z "$DISPLAY" ]; then
		export DISPLAY=:$(ls /tmp/.X11-unix/ | cut -c2 | head -1)
	fi
fi

# Start the training
roslaunch deepracer_simulation_environment $2 &

# If GUI is desired then also start RQT and RVIZ
if [[ "${ENABLE_GUI,,}" == "true" ]];
then
	rqt &
	rviz &
fi

sleep 1

if [ -n "$MULTI_CONFIG" ]; then
	if [ -f /scripts/alter_environment_$ROLLOUT_IDX.sh ]; then
		echo "Altering environment"
		bash /scripts/alter_environment_$ROLLOUT_IDX.sh &
	fi
else
	if [ -f /scripts/alter_environment.sh ]; then
		echo "Altering environment"
		bash /scripts/alter_environment.sh &
	fi
fi

echo "IP: $(hostname -I) ($(hostname))"

# python3 start_deepracer_node_monitor.py --node_monitor_file_path=deepracer_evaluation_node_monitor_list.txt

wait
