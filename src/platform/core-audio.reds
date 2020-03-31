Red/System []


AUDIO-CLOCK!: alias struct! [
	t1				[integer!]
	t2				[integer!]
	t3				[integer!]
	t4				[integer!]
]

OS-audio: context [

	DEVICE-MONITOR-NOTIFY!: alias struct! [
		list-notify		[int-ptr!]
		input-notify	[int-ptr!]
		output-notify	[int-ptr!]
	]
	DEVICE-MONITOR!: alias struct! [
		enable?		[integer!]
		notifys		[DEVICE-MONITOR-NOTIFY! value]
	]
	dev-monitor: declare DEVICE-MONITOR!

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
		id-str			[unicode-string!]
		name			[unicode-string!]				;-- unicode format
		sample-type		[AUDIO-SAMPLE-TYPE!]
		buff-list		[AudioBufferList value]
		io-cb			[int-ptr!]
		stop-cb			[int-ptr!]
		running?		[logic!]
		buffer-size		[integer!]
		proc-id			[integer!]
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
			AudioDeviceCreateIOProcID: "AudioDeviceCreateIOProcID" [
				inDevice				[AudioObjectID]
				inProc					[int-ptr!]
				inClientData			[int-ptr!]
				outIOProcID				[int-ptr!]
				return:					[integer!]
			]
			AudioDeviceStart: "AudioDeviceStart" [
				inDevice				[AudioObjectID]
				inProcID				[int-ptr!]
				return:					[integer!]
			]
			AudioDeviceDestroyIOProcID: "AudioDeviceDestroyIOProcID" [
				inDevice				[AudioObjectID]
				inProcID				[integer!]
				return:					[integer!]
			]
			AudioDeviceStop: "AudioDeviceStop" [
				inDevice				[AudioObjectID]
				inProcID				[int-ptr!]
				return:					[integer!]
			]
			AudioObjectAddPropertyListener: "AudioObjectAddPropertyListener" [
				inObjectID				[AudioObjectID]
				inAddress				[AudioObjectPropertyAddress]
				inListener				[int-ptr!]
				inClientData			[int-ptr!]
				return:					[integer!]
			]
			AudioObjectRemovePropertyListener: "AudioObjectRemovePropertyListener" [
				inObjectID				[AudioObjectID]
				inAddress				[AudioObjectPropertyAddress]
				inListener				[int-ptr!]
				inClientData			[int-ptr!]
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

	init: func [return: [logic!]] [
		set-memory as byte-ptr! dev-monitor #"^(00)" size? DEVICE-MONITOR!
		true
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
		/local
			buff	[byte-ptr!]
	][
		set-memory as byte-ptr! dev #"^(00)" size? COREAUDIO-DEVICE!
		buff: as byte-ptr! system/stack/allocate 4
		sprintf [buff "%04X" id]
		dev/id: id
		dev/id-str: type-string/load-utf8 buff
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
		type-string/release cdev/id-str
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
		return:		[unicode-string!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		cdev/id-str
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
		return:		[logic!]
		/local
			cdev	[COREAUDIO-DEVICE!]
	][
		if stype <> ASAMPLE-TYPE-F32 [return false]
		cdev: as COREAUDIO-DEVICE! dev
		if cdev/running? [return false]
		cdev/sample-type: ASAMPLE-TYPE-F32
		cdev/io-cb: io-cb
		true
	]

	_device-callback: func [
		[cdecl]
		id			[AudioObjectID]
		now			[int-ptr!]
		input_data	[AudioBufferList]
		input_time	[int-ptr!]
		output_data	[AudioBufferList]
		output_time	[int-ptr!]
		ptr-to-this	[int-ptr!]
		return:		[integer!]
		/local
			cdev		[COREAUDIO-DEVICE!]
			abuff		[AUDIO-DEVICE-IO! value]
			pcb			[AUDIO-IO-CALLBACK!]
			ch-count	[integer!]
			bytes		[integer!]
			size		[integer!]
			chs			[int-ptr!]
			step		[integer!]
	][
		if null? ptr-to-this [return -1]
		cdev: as COREAUDIO-DEVICE! ptr-to-this
		if cdev/type = ADEVICE-TYPE-OUTPUT [
			set-memory as byte-ptr! abuff #"^(00)" size? AUDIO-DEVICE-IO!
			if output_data/mNumberBuffers <> 1 [return 1]
			abuff/buffer/sample-type: cdev/sample-type
			ch-count: output_data/mBuffers/mNumberChannels
			bytes: output_data/mBuffers/mDataByteSize
			size: either cdev/sample-type = ASAMPLE-TYPE-I16 [2][4]
			abuff/buffer/channels-count: ch-count
			abuff/buffer/frames-count: bytes / size / ch-count
			abuff/buffer/stride: ch-count
			abuff/buffer/contiguous?: yes
			chs: as int-ptr! abuff/buffer/channels
			step: as integer! output_data/mBuffers/mData
			loop ch-count [
				chs/1: step
				chs: chs + 1
				step: step + size
			]
			pcb: as AUDIO-IO-CALLBACK! cdev/io-cb
			pcb ptr-to-this abuff
			return 0
		]
		if cdev/type = ADEVICE-TYPE-INPUT [
			set-memory as byte-ptr! abuff #"^(00)" size? AUDIO-DEVICE-IO!
			if input_data/mNumberBuffers <> 1 [return 1]
			abuff/buffer/sample-type: cdev/sample-type
			ch-count: input_data/mBuffers/mNumberChannels
			bytes: input_data/mBuffers/mDataByteSize
			size: either cdev/sample-type = ASAMPLE-TYPE-I16 [2][4]
			abuff/buffer/channels-count: ch-count
			abuff/buffer/frames-count: bytes / size / ch-count
			abuff/buffer/stride: ch-count
			abuff/buffer/contiguous?: yes
			chs: as int-ptr! abuff/buffer/channels
			step: as integer! input_data/mBuffers/mData
			loop ch-count [
				chs/1: step
				chs: chs + 1
				step: step + size
			]
			pcb: as AUDIO-IO-CALLBACK! cdev/io-cb
			pcb ptr-to-this abuff
			return 0
		]
		0
	]

	start: func [
		dev			[audio-device!]
		start-cb	[int-ptr!]				;-- audio-device-callback!
		stop-cb		[int-ptr!]				;-- audio-device-callback!
		return:		[logic!]
		/local
			cdev		[COREAUDIO-DEVICE!]
			hr			[integer!]
			start_cb	[AUDIO-DEVICE-CALLBACK!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		if cdev/running? [return true]
		unless null? cdev/io-cb [
			hr: AudioDeviceCreateIOProcID cdev/id as int-ptr! :_device-callback dev :cdev/proc-id
			if hr <> 0 [
				return false
			]
			hr: AudioDeviceStart cdev/id as int-ptr! :_device-callback
			if hr <> 0 [
				AudioDeviceDestroyIOProcID cdev/id cdev/proc-id
				cdev/proc-id: 0
				return false
			]
		]
		cdev/running?: yes

		unless null? start-cb [
			start_cb: as AUDIO-DEVICE-CALLBACK! start-cb
			start_cb dev
		]
		cdev/stop-cb: stop-cb
		true
	]

	stop: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
		/local
			cdev	[COREAUDIO-DEVICE!]
			hr		[integer!]
			stop_cb	[AUDIO-DEVICE-CALLBACK!]
	][
		cdev: as COREAUDIO-DEVICE! dev
		if cdev/running? [
			hr: AudioDeviceStop cdev/id as int-ptr! :_device-callback
			if hr <> 0 [return false]
			hr: AudioDeviceDestroyIOProcID cdev/id cdev/proc-id
			if hr <> 0 [return false]
			unless null? cdev/stop-cb [
				stop_cb: as AUDIO-DEVICE-CALLBACK! cdev/stop-cb
				stop_cb dev
			]
			cdev/proc-id: 0
			cdev/running?: no
		]
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
		if dev-monitor/enable? = 0 [
			dev-monitor/enable?: 1
		]
	]

	free-monitor: func [
	][
		set-memory as byte-ptr! dev-monitor #"^(00)" size? DEVICE-MONITOR!
	]

	monitor-cb: func [
		[cdecl]
		id				[AudioObjectID]
		NumAddr			[integer!]
		addr			[AudioObjectPropertyAddress]
		ptr-to-this		[int-ptr!]
		return:			[integer!]
		/local
			notifys		[int-ptr!]
			d-cb		[AUDIO-CHANGED-CALLBACK!]
	][
		notifys: as int-ptr! dev-monitor/notifys
		case [
			addr/mSelector = cf-enum kAudioHardwarePropertyDevices [
				d-cb: as AUDIO-CHANGED-CALLBACK! notifys/1
			]
			addr/mSelector = cf-enum kAudioHardwarePropertyDefaultInputDevice [
				d-cb: as AUDIO-CHANGED-CALLBACK! notifys/2
			]
			addr/mSelector = cf-enum kAudioHardwarePropertyDefaultOutputDevice [
				d-cb: as AUDIO-CHANGED-CALLBACK! notifys/3
			]
			true [
				return 0
			]
		]
		d-cb
		0
	]

	set-device-changed-callback: func [
		event			[AUDIO-DEVICE-EVENT!]
		cb				[int-ptr!]				;-- audio-changed-callback!
		/local
			addr		[AudioObjectPropertyAddress value]
			hr			[integer!]
			notifys		[int-ptr!]
	][
		init-monitor
		addr/mSelector: cf-enum case [
			event = ADEVICE-LIST-CHANGED [
				kAudioHardwarePropertyDevices
			]
			event = DEFAULT-INPUT-CHANGED [
				kAudioHardwarePropertyDefaultInputDevice
			]
			event = DEFAULT-OUTPUT-CHANGED [
				kAudioHardwarePropertyDefaultOutputDevice
			]
		]
		addr/mScope: cf-enum kAudioObjectPropertyScopeGlobal
		addr/mElement: kAudioObjectPropertyElementMaster
		hr: AudioObjectAddPropertyListener kAudioObjectSystemObject addr as int-ptr! :monitor-cb as int-ptr! dev-monitor
		notifys: as int-ptr! dev-monitor/notifys
		notifys: notifys + event
		if notifys/1 <> 0 [
			hr: AudioObjectRemovePropertyListener kAudioObjectSystemObject addr as int-ptr! :monitor-cb as int-ptr! dev-monitor
		]
		notifys/1: as integer! cb
	]

	free-device-changed-callback: func [
		/local
			notifys		[int-ptr!]
			i			[integer!]
			addr		[AudioObjectPropertyAddress value]
			hr			[integer!]
	][
		notifys: as int-ptr! dev-monitor/notifys
		i: 0
		loop 3 [
			if notifys/1 <> 0 [
				addr/mSelector: cf-enum case [
					i = 0 [
						kAudioHardwarePropertyDevices
					]
					i = 1 [
						kAudioHardwarePropertyDefaultInputDevice
					]
					i = 2 [
						kAudioHardwarePropertyDefaultOutputDevice
					]
				]
				i: i + 1
				addr/mScope: cf-enum kAudioObjectPropertyScopeGlobal
				addr/mElement: kAudioObjectPropertyElementMaster
				hr: AudioObjectRemovePropertyListener kAudioObjectSystemObject addr as int-ptr! :monitor-cb as int-ptr! dev-monitor
			]
			notifys: notifys + 1
		]
		free-monitor
	]
]

