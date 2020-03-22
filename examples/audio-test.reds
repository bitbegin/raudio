Red/System []

#include %../src/audio.reds

audio/init

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

print-line "default output device:"
dev: audio/default-output-device
audio/dump-device dev
print-line "audio-device test:"
printf ["    id: %ls^/" audio-device/id dev]
printf ["    name: %ls^/" audio-device/name dev]
print-line ["    channels: " audio-device/channels-count dev]
audio-device/set-buffer-size dev 10
print-line ["    buffer size: " audio-device/buffer-size dev]
audio-device/set-sample-rate dev 20
print-line ["    sample rate: " audio-device/sample-rate dev]
print-line ["    input?: " audio-device/input? dev]
print-line ["    output?: " audio-device/output? dev]
print-line ["    running?: " audio-device/running? dev]
print-line ["    has-unprocessed-io?: " audio-device/has-unprocessed-io? dev]
audio/free-device dev
