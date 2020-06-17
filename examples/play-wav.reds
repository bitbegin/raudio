Red/System []

#include %utils/pcm-wav.reds
#include %utils/io.reds
#include %utils/play.reds

list: [
	;"wav/think-mono.wav"
	;"wav/think-mono-38000.wav"
	;"wav/think-mono-44100.wav"
	;"wav/think-mono-48000.wav"
	;"wav/think-stereo-44000.wav"
	"wav/think-stereo-48000.wav"
]

buf-size: 512 * 1024
buffer: allocate buf-size

count: size? list
p: list
s: as c-string! 0
len: 0
ret: 0
channel: 0
ctype: 0
rtype: 0
format: declare wav/WAV-FORMAT!

loop count [
	s: as c-string! p/1
	len: read-bin s buffer buf-size
	if len < 0 [
		print-line ["read: " s " failed!"]
		break
	]
	ret: wav/read-head buffer len format
	if ret < 0 [
		print-line [s " format error! len: " len " ret: " ret]
		break
	]
	channel: to-channel-type format/channels
	case [
		format/sample-bits = 16 [
			ctype: ASAMPLE-TYPE-I16
		]
		format/sample-bits = 32 [
			ctype: ASAMPLE-TYPE-I32
		]
	]
	unless play/init ctype :rtype channel format/sample-rate [
		print-line "play init error!"
		print-line ["ctype: " ctype " rtype: " rtype " channel: " channel " rate: " format/sample-rate]
		break
	]
	print-line ["bits: " format/sample-bits " channel: " format/channels " rate: " format/sample-rate " pos: " format/dpos " size: " format/size]
	play/run buffer + format/dpos format/size
	play/close
	p: p + 1
]

free buffer
