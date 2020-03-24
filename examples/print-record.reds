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
	if null? io/input-buffer [exit]
	in*: io/input-buffer
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

audio-device/connect dev ASAMPLE-TYPE-I32 as int-ptr! :record-cb
audio-device/start dev null null

sleep 5 * 1000

audio/free-device dev

audio/close
