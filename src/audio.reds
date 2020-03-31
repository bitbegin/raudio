Red/System []

#define MAX_NUM_CHANNELS		16

#define AUDIO-DEVICE! int-ptr!

#enum AUDIO-DEVICE-TYPE! [
	ADEVICE-TYPE-OUTPUT
	ADEVICE-TYPE-INPUT
]

#enum AUDIO-SAMPLE-TYPE! [
	ASAMPLE-TYPE-F32
	ASAMPLE-TYPE-I32
	ASAMPLE-TYPE-I16
]

#enum AUDIO-DEVICE-EVENT! [
	ADEVICE-LIST-CHANGED
	DEFAULT-INPUT-CHANGED
	DEFAULT-OUTPUT-CHANGED
]

AUDIO-CHANNELS!: alias struct! [
	ch0				[int-ptr!]
	ch1				[int-ptr!]
	ch2				[int-ptr!]
	ch3				[int-ptr!]
	ch4				[int-ptr!]
	ch5				[int-ptr!]
	ch6				[int-ptr!]
	ch7				[int-ptr!]
	ch8				[int-ptr!]
	ch9				[int-ptr!]
	ch10			[int-ptr!]
	ch11			[int-ptr!]
	ch12			[int-ptr!]
	ch13			[int-ptr!]
	ch14			[int-ptr!]
	ch15			[int-ptr!]
]

AUDIO-BUFFER!: alias struct! [
	contiguous?		[logic!]
	frames-count	[integer!]
	channels-count	[integer!]
	sample-type		[AUDIO-SAMPLE-TYPE!]
	stride			[integer!]
	channels		[AUDIO-CHANNELS! value]
]

AUDIO-DEVICE-IO!: alias struct! [
	buffer			[AUDIO-BUFFER! value]
	time			[AUDIO-CLOCK!]
]

AUDIO-IO-CALLBACK!: alias function! [
	dev				[AUDIO-DEVICE!]
	io				[AUDIO-DEVICE-IO!]
]

AUDIO-DEVICE-CALLBACK!: alias function! [dev [AUDIO-DEVICE!]]

AUDIO-CHANGED-CALLBACK!: alias function! []

#include %utils/unicode.reds

#switch OS [
	Windows  [#include %platform/wasapi.reds]
	macOS	 [#include %platform/core-audio.reds]
	Linux	 [#include %platform/alsa.reds]
	FreeBSD  [#include %platform/pulse-audio.reds]
	Syllable [#include %platform/null.reds]
	#default [#include %platform/null.reds]
]

audio: context [
	init: func [return: [logic!]] [
		OS-audio/init
	]
	close: does [
		OS-audio/close
	]

	dump-device: func [
		dev			[audio-device!]
	][
		OS-audio/dump-device dev
	]

	default-input-device: func [
		return: [audio-device!]
	][
		OS-audio/default-input-device
	]

	default-output-device: func [
		return: [audio-device!]
	][
		OS-audio/default-output-device
	]

	input-devices: func [
		count		[int-ptr!]				;-- number of input devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		OS-audio/input-devices count
	]

	output-devices: func [
		count		[int-ptr!]				;-- number of output devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		OS-audio/output-devices count
	]

	all-devices: func [
		count		[int-ptr!]				;-- number of devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		OS-audio/all-devices count
	]

	free-device: func [
		dev			[AUDIO-DEVICE!]
	][
		OS-audio/free-device dev
	]

	free-devices: func [
		devs		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
		count		[integer!]				;-- number of devices
	][
		OS-audio/free-devices devs count
	]

	set-device-changed-callback: func [
		event		[AUDIO-DEVICE-EVENT!]
		cb			[int-ptr!]				;-- audio-changed-callback!
	][
		OS-audio/set-device-changed-callback event cb
	]
	free-device-changed-callback: does [
		OS-audio/free-device-changed-callback
	]
]

audio-device: context [
	id: func [
		dev			[AUDIO-DEVICE!]
		return:		[unicode-string!]
	][
		OS-audio/id dev
	]

	name: func [
		dev			[AUDIO-DEVICE!]
		return:		[unicode-string!]
	][
		OS-audio/name dev
	]

	channels-count: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
	][
		OS-audio/channels-count dev
	]

	buffer-size: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
	][
		OS-audio/buffer-size dev
	]

	set-buffer-size: func [
		dev			[AUDIO-DEVICE!]
		size		[integer!]
		return:		[logic!]
	][
		OS-audio/set-buffer-size dev size
	]

	sample-rate: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
	][
		OS-audio/sample-rate dev
	]

	set-sample-rate: func [
		dev			[AUDIO-DEVICE!]
		rate		[integer!]
		return:		[logic!]
	][
		OS-audio/set-sample-rate dev rate
	]

	input?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		OS-audio/input? dev
	]

	output?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		OS-audio/output? dev
	]

	running?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		OS-audio/running? dev
	]

	can-connect?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][true]

	can-process?: func [
		dev			[AUDIO-DEVICE!]
		return:	[logic!]
	][true]

	has-unprocessed-io?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		OS-audio/has-unprocessed-io? dev
	]

	connect: func [
		dev			[AUDIO-DEVICE!]
		stype		[AUDIO-SAMPLE-TYPE!]
		io-cb		[int-ptr!]				;-- audio-io-callback!
		return:		[logic!]
	][
		OS-audio/connect dev stype io-cb
	]

	start: func [
		dev			[audio-device!]
		start-cb	[int-ptr!]				;-- audio-device-callback!
		stop-cb		[int-ptr!]				;-- audio-device-callback!
		return:		[logic!]
	][
		OS-audio/start dev start-cb stop-cb
	]

	stop: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		OS-audio/stop dev
	]

	wait: func [
		dev			[AUDIO-DEVICE!]
	][
		OS-audio/wait dev
	]
]

sleep: func [ms [integer!]][OS-audio/sleep ms]
