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
;audio-device/set-buffer-size dev 10
print-line ["    buffer size: " audio-device/buffer-size dev]
;audio-device/set-sample-rate dev 20
print-line ["    sample rate: " audio-device/sample-rate dev]
print-line ["    input?: " audio-device/input? dev]
print-line ["    output?: " audio-device/output? dev]
print-line ["    running?: " audio-device/running? dev]
print-line ["    has-unprocessed-io?: " audio-device/has-unprocessed-io? dev]
audio/free-device dev

rate: 0.0
freq: 880.0
delta: 0.0
pi: 3.141593
phase: 0.0
wave-cb: func [
	dev				[AUDIO-DEVICE!]
	io				[AUDIO-DEVICE-IO!]
	/local
		out			[AUDIO-BUFFER!]
		frame		[integer!]
		nsample		[float32!]
		count		[integer!]
		ch			[int-ptr!]
		ch2			[int-ptr!]
		buf			[pointer! [float32!]]
		p			[pointer! [float32!]]
][
	if null? io/output-buffer [exit]
	out: io/output-buffer
	frame: 0
	ch: as int-ptr! out/channels
	loop out/frames-count [
		nsample: as float32! 0.2 * sin phase
		phase: fmod phase + delta 2.0 * pi
		count: 0
		loop out/channels-count [
			ch2: ch + count
			buf: as pointer! [float32!] ch2/1
			p: buf + (frame * out/stride)
			p/1: nsample
			count: count + 1
		]
		frame: frame + 1
	]
]

print-line "wave test:"
dev: audio/default-output-device
audio/dump-device dev
rate: as float! audio-device/sample-rate dev
delta: freq * pi / rate
audio-device/connect dev ASAMPLE-TYPE-F32 as int-ptr! :wave-cb
audio-device/start dev null null
sleep 5 * 1000

audio/free-device dev

audio/close
