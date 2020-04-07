Red/System []

#include %../src/audio.reds

audio/init

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
	if null? io/buffer [exit]
	out: io/buffer
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
audio-device/connect dev as int-ptr! :wave-cb
audio-device/start dev null null
sleep 5 * 1000

audio/free-device dev

audio/close
