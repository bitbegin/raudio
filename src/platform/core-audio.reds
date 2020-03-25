Red/System []


AUDIO-CLOCK!: alias struct! [
	t1				[integer!]
	t2				[integer!]
	t3				[integer!]
	t4				[integer!]
]

OS-audio: context [

	dev-monitor: declare integer!


	#import [
		LIBC-file cdecl [
			usleep: "usleep" [
				us			[integer!]
				return:		[integer!]
			]
			sec.sleep: "sleep" [
				s			[integer!]
				return:		[integer!]
			]
		]
	]

	#define kAudioObjectSystemObject					1
	#define kAudioHardwarePropertyDevices				"dev#"
	#define kAudioHardwarePropertyDefaultInputDevice	"dIn "
	#define kAudioHardwarePropertyDefaultOutputDevice	"dOut"
	#define kAudioObjectPropertyScopeGlobal				"glob"
	#define kAudioObjectPropertyElementMaster			0
	#define kAudioDevicePropertyDeviceName				"name"

	#define AudioObjectID					integer!
	#define AudioDeviceID					AudioObjectID
	#define AudioObjectPropertySelector		integer!
	#define AudioObjectPropertyScope		integer!
	#define AudioObjectPropertyElement		integer!

	COREAUDIO-DEVICE!: alias struct! [
		type			[AUDIO-DEVICE-TYPE!]
		id				[AudioObjectID]
		name			[unicode-string!]				;-- unicode format
		sample-type		[AUDIO-SAMPLE-TYPE!]
		io-cb			[int-ptr!]
		stop-cb			[int-ptr!]
		running?		[logic!]
		buffer-size		[integer!]
	]

	AudioObjectPropertyAddress: alias struct! [
		mSelector			[AudioObjectPropertySelector]
		mScope				[AudioObjectPropertyScope]
		mElement			[AudioObjectPropertyElement]
	]

	#import [
		"/System/Library/Frameworks/CoreAudio.framework/CoreAudio" cdecl [
			AudioObjectGetPropertyDataSize: "AudioObjectGetPropertyDataSize" [
				inObjectID				[AudioObjectID]
				inAddress				[AudioObjectPropertyAddress]
				inQualifierDataSize		[integer!]
				inQualifierData			[int-ptr!]
				outData					[int-ptr!]
				return:					[integer!]
			]
			AudioObjectGetPropertyData: "AudioObjectGetPropertyData" [
				inObjectID				[AudioObjectID]
				inAddress				[AudioObjectPropertyAddress]
				inQualifierDataSize		[integer!]
				inQualifierData			[int-ptr!]
				ioDataSize				[int-ptr!]
				outData					[int-ptr!]
				return:					[integer!]
			]
		]
	]

	cf-enum: func [
		str			[c-string!]
		return:		[integer!]
		/local
			ret		[integer!]
			pb		[byte-ptr!]
	][
		ret: 0
		pb: as byte-ptr! :ret
		pb/1: str/4
		pb/2: str/3
		pb/3: str/2
		pb/4: str/1
		ret
	]

	init: does [
		dev-monitor: 0
	]

	close: does [
		0
	]

	get-device-name: func [
		id			[AudioDeviceID]
		return:		[unicode-string!]
		/local
			addr	[AudioObjectPropertyAddress value]
			hr		[integer!]
			dsize	[integer!]
			buff	[byte-ptr!]
			ustr	[unicode-string!]
	][
		addr/mSelector: cf-enum kAudioDevicePropertyDeviceName
		addr/mScope: cf-enum kAudioObjectPropertyScopeGlobal
		addr/mElement: kAudioObjectPropertyElementMaster
		dsize: 0
		hr: AudioObjectGetPropertyDataSize id addr 0 null :dsize
		if hr <> 0 [return null]
		buff: allocate dsize
		hr: AudioObjectGetPropertyData id addr 0 null :dsize as int-ptr! buff
		if hr <> 0 [free buff return null]
		ustr: type-string/load-utf8 buff
		free buff
		ustr
	]

	init-device: func [
		dev			[COREAUDIO-DEVICE!]
		id			[AudioDeviceID]
		type		[AUDIO-DEVICE-TYPE!]
	][
		set-memory as byte-ptr! dev #"^(00)" size? COREAUDIO-DEVICE!
		dev/id: id
		dev/type: type
		dev/name: get-device-name id
		dev/running?: no
	]

	dump-device: func [
		dev			[AUDIO-DEVICE!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		if null? dev [print-line "null device!" exit]
		cdev: as COREAUDIO-DEVICE! dev
		print-line "================================"
		print-line ["dev: " dev]
		either cdev/type = ADEVICE-TYPE-OUTPUT [
			print-line "    type: input"
		][
			print-line "    type: output"
		]
		print-line ["    id: " cdev/id]
		print "    name: "
		type-string/uprint cdev/name
		print-line "^/================================"
	]

	default-device: func [
		type		[AUDIO-DEVICE-TYPE!]
		return:		[AUDIO-DEVICE!]
		/local
			addr	[AudioObjectPropertyAddress value]
			hr		[integer!]
			size	[integer!]
			id		[AudioDeviceID]
			dsize	[integer!]
			cdev	[COREAUDIO-DEVICE!]
	][
		addr/mSelector: cf-enum either type = ADEVICE-TYPE-OUTPUT [
			kAudioHardwarePropertyDefaultOutputDevice
		][
			kAudioHardwarePropertyDefaultInputDevice
		]
		addr/mScope: cf-enum kAudioObjectPropertyScopeGlobal
		addr/mElement: kAudioObjectPropertyElementMaster
		size: 0
		id: 0
		dsize: size? AudioDeviceID
		hr: AudioObjectGetPropertyData kAudioObjectSystemObject addr 0 null :dsize :id
		if hr <> 0 [return null]
		cdev: as COREAUDIO-DEVICE! allocate size? COREAUDIO-DEVICE!
		init-device cdev id type
		as AUDIO-DEVICE! cdev
	]

	default-input-device: func [
		return: [AUDIO-DEVICE!]
	][
		default-device ADEVICE-TYPE-INPUT
	]

	default-output-device: func [
		return: [AUDIO-DEVICE!]
	][
		default-device ADEVICE-TYPE-OUTPUT
	]

	input-devices: func [
		count		[int-ptr!]				;-- number of input devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		null
	]

	output-devices: func [
		count		[int-ptr!]				;-- number of output devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		null
	]

	free-device: func [
		dev			[AUDIO-DEVICE!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		if null? dev [exit]
		;-- stop dev
		cdev: as COREAUDIO-DEVICE! dev
		type-string/release wdev/name
		free as byte-ptr! cdev
	]

	free-devices: func [
		devs		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
		count		[integer!]				;-- number of devices
	][
		0
	]

	name: func [
		dev			[AUDIO-DEVICE!]
		return:		[unicode-string!]
	][
		null
	]

	id: func [
		dev			[AUDIO-DEVICE!]
		return:		[int-ptr!]
	][
		null
	]

	channels-count: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
	][
		0
	]

	buffer-size: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
	][
		0
	]

	set-buffer-size: func [
		dev			[AUDIO-DEVICE!]
		count		[integer!]
		return:		[logic!]
	][
		true
	]

	sample-rate: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
	][
		0
	]

	set-sample-rate: func [
		dev			[AUDIO-DEVICE!]
		rate		[integer!]
		return:		[logic!]
	][
		true
	]

	input?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		false
	]

	output?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		false
	]

	running?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		no
	]

	has-unprocessed-io?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		no
	]

	connect: func [
		dev			[AUDIO-DEVICE!]
		stype		[AUDIO-SAMPLE-TYPE!]
		io-cb		[int-ptr!]
	][
		0
	]

	start: func [
		dev			[audio-device!]
		start-cb	[int-ptr!]				;-- audio-device-callback!
		stop-cb		[int-ptr!]				;-- audio-device-callback!
		return:		[logic!]
	][
		yes
	]

	stop: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		true
	]

	wait: func [
		dev			[AUDIO-DEVICE!]
	][
		0
	]

	sleep: func [
		ms			[integer!]
		/local
			s		[integer!]
			r		[integer!]
	][
		s: ms / 1000
		if s <> 0 [
			sec.sleep s
		]
		r: ms - (s * 1000)
		if r <> 0 [
			r: r * 1000
			usleep r
		]
	]

	init-monitor: func [
	][
		0
	]

	free-monitor: func [
	][
		0
	]

	set-device-changed-callback: func [
		event			[AUDIO-DEVICE-EVENT!]
		cb				[int-ptr!]				;-- audio-changed-callback!
	][
		0
	]

	free-device-changed-callback: func [
	][
		0
		free-monitor
	]
]

