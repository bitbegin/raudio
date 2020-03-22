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
	ADEVICE-CHANGED
	ADEVICE-INPUT-CHANGED
	ADEVICE-OUTPUT-CHANGED
]

AUDIO-BUFFER!: alias struct! [
	contiguous?		[logic!]
	frames-count	[integer!]
	channels-count	[integer!]
	sample-type		[AUDIO-SAMPLE-TYPE!]
	stride			[integer!]
	channels		[int-ptr!]
]

AUDIO-DEVICE-IO!: alias struct! [
	input-buffer	[AUDIO-BUFFER!]
	input-time		[AUDIO-CLOCK!]
	output-buffer	[AUDIO-BUFFER!]
	output-time		[AUDIO-CLOCK!]
]

AUDIO-IO-CALLBACK!: alias function! [
	dev				[AUDIO-DEVICE!]
	io				[AUDIO-DEVICE-IO!]
]

AUDIO-DEVICE-CALLBACK!: alias function! [dev [AUDIO-DEVICE!]]

#include %utils/unicode.reds

#switch OS [
	Windows  [#include %platform/wasapi.reds]
	;Syllable [#include %platform/wasapi.reds]
	;macOS	 [#include %platform/wasapi.reds]
	;FreeBSD  [#include %platform/wasapi.reds]
	#default [#include %platform/wasapi.reds]
]

audio: context [
	init: does [
		OS-audio/init
	]

	dump-device: func [
		dev			[audio-device!]
	][
		OS-audio/dump-device dev
	]

	all-devices: func [
		count		[int-ptr!]			;-- number of devices
		return:		[audio-device!]		;-- an array of audio-device!
	][

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

]
