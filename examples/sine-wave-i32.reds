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
		nsample		[float!]
		temp		[float!]
		count		[integer!]
		ch			[int-ptr!]
		ch2			[int-ptr!]
		buf			[int-ptr!]
		p			[int-ptr!]
][
	if null? io/buffer [exit]
	out: io/buffer
	frame: 0
	ch: as int-ptr! out/channels
	loop out/frames-count [
		nsample: 0.2 * sin phase
		phase: fmod phase + delta 2.0 * pi
		count: 0
		loop out/channels-count [
			ch2: ch + count
			buf: as int-ptr! ch2/1
			p: buf + (frame * out/stride)
			temp: nsample * 2147483647.0
			p/1: as integer! temp
			count: count + 1
		]
		frame: frame + 1
	]
]

print-line "wave test:"
dev: audio/default-output-device
audio/dump-device dev
res: false
res: audio-device/set-sample-format dev ASAMPLE-TYPE-I32
print-line ["set format integer!: " res]
res: audio-device/set-channels-type dev AUDIO-SPEAKER-STEREO
print-line ["set channels stereo: " res]
print-line ["new config: "]
audio/dump-device dev
rate: as float! audio-device/sample-rate dev
delta: freq * pi / rate
res: audio-device/connect dev as int-ptr! :wave-cb
print-line ["connect: " res]
res: audio-device/start dev null null
print-line ["start: " res]
print-line "now speak 5 second ..."
sleep 5 * 1000

audio/free-device dev

audio/close
