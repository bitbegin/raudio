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
		/local
			count1	[integer!]
			list1	[int-ptr!]
			count2	[integer!]
			list2	[int-ptr!]
			total	[integer!]
			list	[int-ptr!]
			end		[int-ptr!]
	][
		count/1: 0
		count1: 0
		list1: output-devices :count1
		if null? list1 [count1: 0]
		count2: 0
		list2: input-devices :count2
		if null? list2 [count2: 0]
		if all [count1 = 0 count2 = 0][return null]
		total: count1 + count2
		list: as int-ptr! allocate total + 1 * 4
		end: list + count/1
		end/1: 0
		if count1 <> 0 [
			copy-memory as byte-ptr! list as byte-ptr! list1 count1 * 4
			free as byte-ptr! list1
		]
		if count2 <> 0 [
			copy-memory as byte-ptr! list + count1 as byte-ptr! list2 count2 * 4
			free as byte-ptr! list2
		]
		count/1: total
		list
	]

	free-device: func [
		dev			[AUDIO-DEVICE!]
	][
		OS-audio/free-device dev
	]

	free-devices: func [
		devs		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
		count		[integer!]				;-- number of devices
		/local
			p		[byte-ptr!]
	][
		if null? devs [exit]
		p: as byte-ptr! devs
		loop count [
			free-device as AUDIO-DEVICE! devs/1
			devs: devs + 1
		]
		free p
	]
]

audio-device: context [
	name: func [
		dev			[AUDIO-DEVICE!]
		return:		[byte-ptr!]			;-- unicode16
	][
		OS-audio/name dev
	]

	id: func [
		dev			[AUDIO-DEVICE!]
		return:		[byte-ptr!]			;-- unicode16
	][
		OS-audio/id dev
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

