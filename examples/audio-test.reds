Red/System []

#include %../src/audio.reds

audio/init

print-line "default output device:"
dev: audio/default-output-device
audio/dump-device dev
audio/free-device dev

print-line "^/output device list:"
count: 0
devs: audio/output-devices :count
iter: devs
loop count [
	audio/dump-device as AUDIO-DEVICE! iter/1
	iter: iter + 1
]
audio/free-devices devs count

print-line "^/input device list:"
count: 0
devs: audio/input-devices :count
iter: devs
loop count [
	audio/dump-device as AUDIO-DEVICE! iter/1
	iter: iter + 1
]
audio/free-devices devs count

print-line "^/all device list:"
count: 0
devs: audio/all-devices :count
iter: devs
loop count [
	audio/dump-device as AUDIO-DEVICE! iter/1
	iter: iter + 1
]
audio/free-devices devs count
