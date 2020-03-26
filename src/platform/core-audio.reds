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
	#define kAudioObjectPropertyScopeInput				"inpt"
	#define kAudioDevicePropertyScopeInput				kAudioObjectPropertyScopeInput
	#define kAudioObjectPropertyScopeOutput				"outp"
	#define kAudioDevicePropertyScopeOutput				kAudioObjectPropertyScopeOutput
	#define kAudioDevicePropertyStreamConfiguration		"slay"
	#define kAudioDevicePropertyNominalSampleRate		"nsrt"
	#define kAudioDevicePropertyBufferFrameSize			"fsiz"

	#define AudioObjectID					integer!
	#define AudioDeviceID					AudioObjectID
	#define AudioObjectPropertySelector		integer!
	#define AudioObjectPropertyScope		integer!
	#define AudioObjectPropertyElement		integer!

	AudioBuffer: alias struct! [
		mNumberChannels		[integer!]
		mDataByteSize		[integer!]
		mData				[byte-ptr!]
	]

	AudioBufferList: alias struct! [
		mNumberBuffers		[integer!]
		mBuffers			[AudioBuffer value]
	]

	COREAUDIO-DEVICE!: alias struct! [
		type			[AUDIO-DEVICE-TYPE!]
		id				[AudioObjectID]
		name			[unicode-string!]				;-- unicode format
		sample-type		[AUDIO-SAMPLE-TYPE!]
		buff-list		[AudioBufferList value]
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
			AudioObjectSetPropertyData: "AudioObjectSetPropertyData" [
				inObjectID				[AudioObjectID]
				inAddress				[AudioObjectPropertyAddress]
				inQualifierDataSize		[integer!]
				inQualifierData			[int-ptr!]
				ioDataSize				[integer!]
				inData					[int-ptr!]
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

	get-buffer-list: func [
		id			[AudioDeviceID]
		type		[AUDIO-DEVICE-TYPE!]
		buff-list	[AudioBufferList]
		return:		[logic!]
		/local
			addr	[AudioObjectPropertyAddress value]
			hr		[integer!]
			dsize	[integer!]
	][
		addr/mSelector: cf-enum kAudioDevicePropertyStreamConfiguration
		addr/mScope: cf-enum either type = ADEVICE-TYPE-OUTPUT [
			kAudioDevicePropertyScopeOutput
		][
			kAudioDevicePropertyScopeInput
		]
		addr/mElement: kAudioObjectPropertyElementMaster
		dsize: 0
		hr: AudioObjectGetPropertyDataSize id addr 0 null :dsize
		if hr <> 0 [return false]
		if dsize <> size? AudioBufferList [return false]
		hr: AudioObjectGetPropertyData id addr 0 null :dsize as int-ptr! buff-list
		if hr <> 0 [return false]
		true
	]

	device-type?: func [
		id			[AudioDeviceID]
		type		[AUDIO-DEVICE-TYPE!]
		return:		[integer!]
		/local
			list	[AudioBufferList value]
	][
		unless get-buffer-list id type list [return -1]
		if list/mNumberBuffers = 1 [return type]
		-1
	]

	get-device-type: func [
		id			[AudioDeviceID]
		return:		[AUDIO-DEVICE-TYPE!]
		/local
			type	[integer!]
			list	[AudioBufferList]
	][
		type: device-type? id ADEVICE-TYPE-INPUT
		if type = ADEVICE-TYPE-INPUT [return ADEVICE-TYPE-INPUT]
		type: device-type? id ADEVICE-TYPE-OUTPUT
		if type = ADEVICE-TYPE-OUTPUT [return ADEVICE-TYPE-OUTPUT]
		return -1
	]

	init-device: func [
		dev			[COREAUDIO-DEVICE!]
		id			[AudioDeviceID]
		type		[integer!]
	][
		set-memory as byte-ptr! dev #"^(00)" size? COREAUDIO-DEVICE!
		dev/id: id
		dev/type: either type = -1 [
			get-device-type id
		][
			type
		]
		if any [
			dev/type = ADEVICE-TYPE-INPUT
			dev/type = ADEVICE-TYPE-OUTPUT
		][
			get-buffer-list id dev/type dev/buff-list
		]
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
			print-line "    type: speaker"
		][
			print-line "    type: microphone"
		]
		print-line ["    id: " cdev/id]
		print "    name: "
		type-string/uprint cdev/name
		print-line ["^/    channels: " cdev/buff-list/mBuffers/mNumberChannels]
		print-line ["    sample rate: " sample-rate dev]
		print-line ["    buffer frames: " buffer-size dev]
		print-line "================================"
	]

	default-device: func [
		type		[AUDIO-DEVICE-TYPE!]
		return:		[AUDIO-DEVICE!]
		/local
			addr	[AudioObjectPropertyAddress value]
			hr		[integer!]
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
		get-devices 1 count
	]

	output-devices: func [
		count		[int-ptr!]				;-- number of output devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		get-devices 0 count
	]

	get-devices*: func [
		count		[int-ptr!]			;-- number of input devices
		return:		[AUDIO-DEVICE!]		;-- an array of AUDIO-DEVICE!
		/local
			addr	[AudioObjectPropertyAddress value]
			hr		[integer!]
			dsize	[integer!]
			ids		[int-ptr!]
			ids2	[int-ptr!]
			list	[int-ptr!]
			end		[int-ptr!]
			itor	[int-ptr!]
			cdev	[COREAUDIO-DEVICE!]
	][
		count/1: 0
		addr/mSelector: cf-enum kAudioHardwarePropertyDevices
		addr/mScope: cf-enum kAudioObjectPropertyScopeGlobal
		addr/mElement: kAudioObjectPropertyElementMaster
		dsize: 0
		hr: AudioObjectGetPropertyDataSize kAudioObjectSystemObject addr 0 null :dsize
		if hr <> 0 [return null]
		count/1: dsize / size? AudioDeviceID
		if count/1 = 0 [return null]
		ids: as int-ptr! allocate dsize
		ids2: ids
		hr: AudioObjectGetPropertyData kAudioObjectSystemObject addr 0 null :dsize ids
		if hr <> 0 [free as byte-ptr! ids return null]
		list: as int-ptr! allocate count/1 + 1 * 4
		itor: list
		end: list + count/1
		end/1: 0
		loop count/1 [
			either itor < end [
				cdev: as COREAUDIO-DEVICE! allocate size? COREAUDIO-DEVICE!
				init-device cdev ids2/1 -1
				itor/1: as integer! cdev
				itor: itor + 1
				ids2: ids2 + 1
			][
				free as byte-ptr! ids
				free as byte-ptr! list
				return null
			]
		]
		free as byte-ptr! ids
		list
	]

	get-devices: func [
		mode		[integer!]			;-- 0 for output, 1 for input, 2 for all
		count		[int-ptr!]			;-- number of input devices
		return:		[AUDIO-DEVICE!]		;-- an array of AUDIO-DEVICE!
		/local
			num		[integer!]
			list	[int-ptr!]
			iter	[int-ptr!]
			num2	[integer!]
			cdev	[COREAUDIO-DEVICE!]
			nlist	[int-ptr!]
			niter	[int-ptr!]
	][
		num: 0
		list: get-devices* :num
		if num = 0 [return null]
		iter: list
		num2: 0
		loop num [
			cdev: as COREAUDIO-DEVICE! iter/1
			if any [
				all [
					mode = 0
					cdev/type = ADEVICE-TYPE-OUTPUT
				]
				all [
					mode = 1
					cdev/type = ADEVICE-TYPE-INPUT
				]
				all [
					mode = 2
					cdev/type <> -1
				]
			][
				num2: num2 + 1
			]
			iter: iter + 1
		]
		if num2 = 0 [return null]
		count/1: num2
		nlist: as int-ptr! allocate num2 + 1 * 4
		niter: nlist + num2
		niter/1: 0
		niter: nlist
		iter: list
		loop num [
			cdev: as COREAUDIO-DEVICE! iter/1
			either any [
				all [
					mode = 0
					cdev/type = ADEVICE-TYPE-OUTPUT
				]
				all [
					mode = 1
					cdev/type = ADEVICE-TYPE-INPUT
				]
				all [
					mode = 2
					cdev/type <> -1
				]
			][
				niter/1: iter/1
				niter: niter + 1
			][
				free-device as int-ptr! cdev
			]
			iter: iter + 1
		]
		free as byte-ptr! list
		nlist
	]

	all-devices: func [
		count		[int-ptr!]			;-- number of input devices
		return:		[AUDIO-DEVICE!]		;-- an array of AUDIO-DEVICE!
	][
		get-devices 2 count
	]

	free-device: func [
		dev			[AUDIO-DEVICE!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		if null? dev [exit]
		;-- stop dev
		cdev: as COREAUDIO-DEVICE! dev
		type-string/release cdev/name
		free as byte-ptr! cdev
	]

	free-devices: func [
		devs		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
		count		[integer!]				;-- number of devices
		/local
			p		[byte-ptr!]
			cdev	[COREAUDIO-DEVICE!]
	][
		if null? devs [exit]
		p: as byte-ptr! devs
		loop count [
			cdev: as COREAUDIO-DEVICE! devs/1
			free-device as AUDIO-DEVICE! devs/1
			devs: devs + 1
		]
		free p
	]

	name: func [
		dev			[AUDIO-DEVICE!]
		return:		[unicode-string!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		cdev/name
	]

	id: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		cdev/id
	]

	channels-count: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		cdev/buff-list/mBuffers/mNumberChannels
	]

	buffer-size: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
		/local
			cdev	[COREAUDIO-DEVICE!]
			addr	[AudioObjectPropertyAddress value]
			hr		[integer!]
			dsize	[integer!]
			frames	[integer!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		addr/mSelector: cf-enum kAudioDevicePropertyBufferFrameSize
		addr/mScope: cf-enum kAudioObjectPropertyScopeGlobal
		addr/mElement: kAudioObjectPropertyElementMaster
		dsize: 0
		hr: AudioObjectGetPropertyDataSize cdev/id addr 0 null :dsize
		if hr <> 0 [return 0]
		if dsize <> 4 [return 0]
		frames: 0
		hr: AudioObjectGetPropertyData cdev/id addr 0 null :dsize :frames
		if hr <> 0 [return 0]
		frames
	]

	set-buffer-size: func [
		dev			[AUDIO-DEVICE!]
		count		[integer!]
		return:		[logic!]
		/local
			cdev	[COREAUDIO-DEVICE!]
			addr	[AudioObjectPropertyAddress value]
			hr		[integer!]
			frames	[integer!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		addr/mSelector: cf-enum kAudioDevicePropertyBufferFrameSize
		addr/mScope: cf-enum kAudioObjectPropertyScopeGlobal
		addr/mElement: kAudioObjectPropertyElementMaster
		frames: count
		hr: AudioObjectSetPropertyData cdev/id addr 0 null size? integer! :frames
		if hr <> 0 [return false]
		true
	]

	sample-rate: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
		/local
			cdev	[COREAUDIO-DEVICE!]
			addr	[AudioObjectPropertyAddress value]
			hr		[integer!]
			dsize	[integer!]
			rate	[float!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		addr/mSelector: cf-enum kAudioDevicePropertyNominalSampleRate
		addr/mScope: cf-enum kAudioObjectPropertyScopeGlobal
		addr/mElement: kAudioObjectPropertyElementMaster
		dsize: 0
		hr: AudioObjectGetPropertyDataSize cdev/id addr 0 null :dsize
		if hr <> 0 [return 0]
		rate: 0.0
		hr: AudioObjectGetPropertyData cdev/id addr 0 null :dsize as int-ptr! :rate
		if hr <> 0 [return 0]
		as integer! rate
	]

	set-sample-rate: func [
		dev			[AUDIO-DEVICE!]
		rate		[integer!]
		return:		[logic!]
		/local
			cdev	[COREAUDIO-DEVICE!]
			addr	[AudioObjectPropertyAddress value]
			hr		[integer!]
			frate	[float!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		addr/mSelector: cf-enum kAudioDevicePropertyNominalSampleRate
		addr/mScope: cf-enum kAudioObjectPropertyScopeGlobal
		addr/mElement: kAudioObjectPropertyElementMaster
		frate: as float! rate
		hr: AudioObjectSetPropertyData cdev/id addr 0 null size? float! as int-ptr! :frate
		if hr <> 0 [return false]
		true
	]

	input?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		cdev/type = ADEVICE-TYPE-INPUT
	]

	output?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		cdev/type = ADEVICE-TYPE-OUTPUT
	]

	running?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		cdev/running?
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
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		if cdev/running? [exit]
		cdev/sample-type: stype
		cdev/io-cb: io-cb
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

