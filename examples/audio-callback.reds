Red/System []

#include %../src/audio.reds

audio/init

print-all-device: func [
	/local
		count	[integer!]
		devs	[AUDIO-DEVICE!]
		iter	[AUDIO-DEVICE!]
][
	print-line "^/all device list:"
	;sleep 500
	count: 0
	devs: audio/all-devices :count
	iter: devs
	loop count [
		audio/dump-device as AUDIO-DEVICE! iter/1
		iter: iter + 1
	]
	audio/free-devices devs count
]

list-cb: does [
	print-line "device list changed callback!"
	print-all-device
]

input-cb: does [
	print-line "default input changed callback!"
	print-all-device
]

output-cb: does [
	print-line "default output changed callback!"
	print-all-device
]

print-all-device

audio/set-device-changed-callback ADEVICE-LIST-CHANGED as int-ptr! :list-cb
audio/set-device-changed-callback DEFAULT-INPUT-CHANGED as int-ptr! :input-cb
audio/set-device-changed-callback DEFAULT-OUTPUT-CHANGED as int-ptr! :output-cb

sleep 50 * 1000

audio/free-device-changed-callback

audio/close
