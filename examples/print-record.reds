Red/System []

#include %../src/audio.reds

audio/init

record-cb: func [
	dev				[AUDIO-DEVICE!]
	io				[AUDIO-DEVICE-IO!]
	/local
		in*			[AUDIO-BUFFER!]
		frame		[integer!]
		count		[integer!]
		ch			[int-ptr!]
		ch2			[int-ptr!]
		buf			[int-ptr!]
		p			[int-ptr!]
][
	if null? io/buffer [exit]
	in*: io/buffer
	frame: 0
	ch: as int-ptr! in*/channels
	loop in*/frames-count [
		count: 0
		loop in*/channels-count [
			ch2: ch + count
			buf: as int-ptr! ch2/1
			p: buf + (frame * in*/stride)
			print [as int-ptr! p/1 " "]
			count: count + 1
		]
		frame: frame + 1
	]
]

print-line "record test:"
dev: audio/default-input-device
audio/dump-device dev
res: false
res: audio-device/set-sample-format dev ASAMPLE-TYPE-F32
print-line ["set format float!: " res]
res: audio-device/set-channels-type dev AUDIO-SPEAKER-STEREO
print-line ["set channels stereo: " res]
print-line ["new config: "]
audio/dump-device dev
res: audio-device/connect dev as int-ptr! :record-cb
print-line ["connect: " res]
res: audio-device/start dev null null
print-line ["start: " res]
print-line "now record 5 second ..."
sleep 5 * 1000

audio/free-device dev

audio/close
