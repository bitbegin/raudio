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

	#import [
		"libasound.so.2" cdecl [
			snd_pcm_type_name: "snd_pcm_type_name" [
				type		[integer!]
				return:		[c-string!]
			]
			snd_pcm_stream_name: "snd_pcm_stream_name" [
				stream		[integer!]
				return:		[c-string!]
			]
			snd_pcm_access_name: "snd_pcm_access_name" [
				access		[integer!]
				return:		[c-string!]
			]
			snd_pcm_format_name: "snd_pcm_format_name" [
				format		[integer!]
				return:		[c-string!]
			]
			snd_pcm_format_description: "snd_pcm_format_description" [
				format		[integer!]
				return:		[c-string!]
			]
			snd_pcm_subformat_name: "snd_pcm_subformat_name" [
				subformat	[integer!]
				return:		[c-string!]
			]
			snd_pcm_subformat_description: "snd_pcm_subformat_description" [
				subformat	[integer!]
				return:		[c-string!]
			]
			snd_pcm_format_value: "snd_pcm_format_value" [
				name		[c-string!]
				return:		[integer!]
			]
			snd_pcm_tstamp_mode_name: "snd_pcm_tstamp_mode_name" [
				mode		[integer!]
				return:		[c-string!]
			]
			snd_pcm_state_name: "snd_pcm_state_name" [
				state		[integer!]
				return:		[c-string!]
			]
			snd_card_next: "snd_card_next" [
				card		[int-ptr!]
				return:		[integer!]
			]
			snd_ctl_open: "snd_ctl_open" [
				ctl			[int-ptr!]
				name		[c-string!]
				mode		[integer!]
				return:		[integer!]
			]
			snd_ctl_card_info: "snd_ctl_card_info" [
				ctl			[int-ptr!]
				info		[int-ptr!]
				return:		[integer!]
			]
			snd_ctl_close: "snd_ctl_close" [
				ctl			[int-ptr!]
				return:		[integer!]
			]
			snd_device_name_hint: "snd_device_name_hint" [
				card		[integer!]
				iface		[c-string!]
				hints		[int-ptr!]
				return:		[integer!]
			]
			snd_device_name_free_hint: "snd_device_name_free_hint" [
				hints		[integer!]
				return:		[integer!]
			]
			snd_device_name_get_hint: "snd_device_name_get_hint" [
				hint		[int-ptr!]
				id			[c-string!]
				return:		[c-string!]
			]
			snd_pcm_open: "snd_pcm_open" [
				pcm			[int-ptr!]
				name		[c-string!]
				stream		[integer!]
				mode		[integer!]
				return:		[integer!]
			]
			snd_pcm_close: "snd_pcm_close" [
				pcm			[integer!]
				return:		[integer!]
			]
			snd_pcm_prepare: "snd_pcm_prepare" [
				pcm			[integer!]
				return:		[integer!]
			]
			snd_strerror: "snd_strerror" [
				errnum		[integer!]
				return:		[c-string!]
			]
			snd_pcm_hw_params_malloc: "snd_pcm_hw_params_malloc" [
				ptr			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_free: "snd_pcm_hw_params_free" [
				obj			[integer!]
			]
			snd_pcm_hw_params_copy: "snd_pcm_hw_params_copy" [
				dst			[integer!]
				src			[integer!]
			]
			snd_pcm_hw_params_any: "snd_pcm_hw_params_any" [
				pcm			[integer!]
				params		[integer!]
				return:		[integer!]
			]
			snd_pcm_hw_params_current: "snd_pcm_hw_params_current" [
				pcm			[integer!]
				params		[integer!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_channels: "__snd_pcm_hw_params_get_channels" [
				params		[integer!]
				val			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_channels_min: "__snd_pcm_hw_params_get_channels_min" [
				params		[integer!]
				val			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_channels_max: "__snd_pcm_hw_params_get_channels_max" [
				params		[integer!]
				val			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_set_channels: "snd_pcm_hw_params_set_channels" [
				pcm			[integer!]
				params		[integer!]
				val			[integer!]
				return:		[integer!]
			]
			snd_pcm_hw_params_test_channels: "snd_pcm_hw_params_test_channels" [
				pcm			[integer!]
				params		[integer!]
				val			[integer!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_format: "__snd_pcm_hw_params_get_format" [
				params		[integer!]
				val			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_test_format: "snd_pcm_hw_params_test_format" [
				pcm			[integer!]
				params		[integer!]
				val			[integer!]
				return:		[integer!]
			]
			snd_pcm_hw_params_set_format: "snd_pcm_hw_params_set_format" [
				pcm			[integer!]
				params		[integer!]
				val			[integer!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_rate: "__snd_pcm_hw_params_get_rate" [
				params		[integer!]
				val			[int-ptr!]
				dir			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_rate_min: "__snd_pcm_hw_params_get_rate_min" [
				params		[integer!]
				val			[int-ptr!]
				dir			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_rate_max: "__snd_pcm_hw_params_get_rate_max" [
				params		[integer!]
				val			[int-ptr!]
				dir			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_set_rate: "snd_pcm_hw_params_set_rate" [
				pcm			[integer!]
				params		[integer!]
				val			[integer!]
				dir			[integer!]
				return:		[integer!]
			]
			snd_pcm_hw_params_test_rate: "snd_pcm_hw_params_test_rate" [
				pcm			[integer!]
				params		[integer!]
				val			[integer!]
				dir			[integer!]
				return:		[integer!]
			]
			snd_pcm_hw_params: "snd_pcm_hw_params" [
				pcm			[integer!]
				params		[integer!]
				return:		[integer!]
			]
			snd_asoundlib_version: "snd_asoundlib_version" [
				return:		[c-string!]
			]
		]
	]

	#define SND_PCM_FORMAT_S16_LE		2
	#define SND_PCM_FORMAT_S32_LE		10
	#define SND_PCM_FORMAT_FLOAT_LE		14

	ALSA-DEVICE!: alias struct! [
		type			[AUDIO-DEVICE-TYPE!]
		id				[unicode-string!]				;-- unicode format
		name			[unicode-string!]				;-- unicode format
		io-cb			[int-ptr!]
		stop-cb			[int-ptr!]
		running?		[logic!]
		buffer-size		[integer!]
		channels		[int-ptr!]						;-- support channels list
		channels-count	[integer!]
		rates			[int-ptr!]						;-- support rates list
		rates-count		[integer!]
		formats			[int-ptr!]						;-- support formats list
		formats-count	[integer!]
		channel			[integer!]						;-- default channels
		rate			[integer!]						;-- default rate
		format			[AUDIO-SAMPLE-TYPE!]			;-- default format
		pcm				[integer!]
	]

	output-desired: [
		"plughw"		6
	]

	input-filters: [
		"default"		7
		"dmix"			4
		"null"			4
		"pulse"			5
		"surround"		8
		"iec958"		6			;-- avoid some issues like: ALSA lib setup.c:547:(add_elem) Cannot obtain info for CTL elem (PCM,'IEC958 Playback PCM Stream',0,0,0): No such file or directory
		"usbstream"		9			;-- ALSA lib pcm_usb_stream.c:508:(_snd_pcm_usb_stream_open) Unknown field hint
	]

	rates-filters: [
		5512
		8000
		11025
		16000
		22050
		32000
		44100
		48000
		64000
		88200
		96000
		176400
		192000
	]

	init: func [
		return:		[logic!]
	][
		dev-monitor: 0
		true
	]

	close: does [
		0
	]

	init-device: func [
		adev			[ALSA-DEVICE!]
		pcm				[integer!]
		return:			[logic!]
		/local
			params		[integer!]
			hr			[integer!]
			p			[int-ptr!]
			id			[c-string!]
			formats		[int-ptr!]
			count		[integer!]
			min			[integer!]
			max			[integer!]
			channels	[int-ptr!]
			num			[integer!]
			rates		[int-ptr!]
			filters		[int-ptr!]
	][
		adev/running?: no
		adev/format: -1
		adev/channel: 0
		adev/rate: 0
		;-- get hw-params
		params: 0
		hr: snd_pcm_hw_params_malloc :params
		if hr < 0 [return false]
		p: as int-ptr! adev/id
		id: as c-string! p + 1
		hr: snd_pcm_hw_params_any pcm params
		if hr < 0 [
			snd_pcm_hw_params_free params
			return false
		]
		;-- get formats
		count: 0
		formats: as int-ptr! allocate 4 * 4
		set-memory as byte-ptr! formats #"^(00)" 4 * 4
		adev/formats: formats
		hr: snd_pcm_hw_params_test_format pcm params SND_PCM_FORMAT_S16_LE
		if hr = 0 [
			formats/1: ASAMPLE-TYPE-I16
			formats: formats + 1
			count: count + 1
			adev/format: ASAMPLE-TYPE-I16
		]
		hr: snd_pcm_hw_params_test_format pcm params SND_PCM_FORMAT_S32_LE
		if hr = 0 [
			formats/1: ASAMPLE-TYPE-I32
			formats: formats + 1
			count: count + 1
			adev/format: ASAMPLE-TYPE-I32
		]
		hr: snd_pcm_hw_params_test_format pcm params SND_PCM_FORMAT_FLOAT_LE
		if hr = 0 [
			formats/1: ASAMPLE-TYPE-F32
			formats: formats + 1
			count: count + 1
			adev/format: ASAMPLE-TYPE-F32
		]
		if count = 0 [
			free as byte-ptr! adev/formats
			adev/formats: null
			snd_pcm_hw_params_free params
			return false
		]
		adev/formats-count: count
		;-- get channels
		min: 0
		hr: snd_pcm_hw_params_get_channels_min params :min
		if hr < 0 [
			snd_pcm_hw_params_free params
			return false
		]
		max: 0
		hr: snd_pcm_hw_params_get_channels_max params :max
		if hr < 0 [
			snd_pcm_hw_params_free params
			return false
		]
		if min > max [
			snd_pcm_hw_params_free params
			return false
		]
		if min = 0 [min: 1]
		if max > 16 [max: 16]
		if max < 0 [max: 16]
		if min = max [max: min + 1]
		count: 0
		channels: as int-ptr! allocate 16 + 1 * 4
		set-memory as byte-ptr! channels #"^(00)" 16 + 1 * 4
		adev/channels: channels
		while [min <= max][
			hr: snd_pcm_hw_params_test_channels pcm params min
			if hr = 0 [
				channels/1: min
				channels: channels + 1
				count: count + 1
				case [
					adev/channel = 0 [
						adev/channel: min
					]
					min = 2 [
						adev/channel: 2
					]
					all [
						min = 1
						adev/channel <> 2
					][
						adev/channel: 1
					]
					true [0]
				]
			]
			min: min + 1
		]
		if count = 0 [
			free as byte-ptr! adev/channels
			adev/channels: null
			snd_pcm_hw_params_free params
			return false
		]
		adev/channels-count: count
		;-- get rates
		min: 0
		hr: snd_pcm_hw_params_get_rate_min params :min null
		if hr < 0 [
			snd_pcm_hw_params_free params
			return false
		]
		max: 0
		hr: snd_pcm_hw_params_get_rate_max params :max null
		if hr < 0 [
			snd_pcm_hw_params_free params
			return false
		]
		if max < 0 [max: 192000]
		num: size? rates-filters
		if min = max [max: min + 1]
		count: 0
		rates: as int-ptr! allocate num + 1 * 4
		set-memory as byte-ptr! rates #"^(00)" num + 1 * 4
		adev/rates: rates
		filters: rates-filters
		loop num [
			if all [
				min <= filters/1
				filters/1 <= max
			][
				hr: snd_pcm_hw_params_test_rate pcm params filters/1 0
				if hr = 0 [
					rates/1: filters/1
					rates: rates + 1
					count: count + 1
					if adev/rate <> 44100 [
						adev/rate: filters/1
					]
				]
			]
			filters: filters + 1
		]
		if count = 0 [
			free as byte-ptr! adev/rates
			adev/rates: null
			snd_pcm_hw_params_free params
			return false
		]
		adev/rates-count: count
		hr: snd_pcm_hw_params_set_format pcm params adev/format
		;if hr < 0 [print-line ["set format: " snd_strerror hr]]
		hr: snd_pcm_hw_params_set_channels pcm params adev/channel
		;if hr < 0 [print-line ["set channels: " snd_strerror hr]]
		hr: snd_pcm_hw_params_set_rate pcm params adev/rate 0
		;if hr < 0 [print-line ["set rate: " snd_strerror hr]]
		snd_pcm_hw_params_free params
		true
	]

	dump-device: func [
		dev			[AUDIO-DEVICE!]
		/local
			adev	[ALSA-DEVICE!]
			val		[integer!]
			hr		[integer!]
			p		[int-ptr!]
	][
		if null? dev [print-line "null device!" exit]
		adev: as ALSA-DEVICE! dev
		print-line "================================"
		print-line ["dev: " dev]
		either adev/type = ADEVICE-TYPE-OUTPUT [
			print-line "    type: speaker"
		][
			print-line "    type: microphone"
		]
		print "    id: "
		type-string/uprint adev/id
		print lf
		print "    name: "
		type-string/uprint adev/name
		print "^/    formats: "
		either null? adev/formats [
			print "none"
		][
			p: adev/formats
			loop adev/formats-count [
				case [
					p/1 = ASAMPLE-TYPE-F32 [
						print "float32! "
					]
					p/1 = ASAMPLE-TYPE-I32 [
						print "integer! "
					]
					p/1 = ASAMPLE-TYPE-I16 [
						print "int16! "
					]
					true [
						print "unknown "
					]
				]
				p: p + 1
			]
		]
		print "^/    channels: "
		either null? adev/channels [
			print "none"
		][
			p: adev/channels
			loop adev/channels-count [
				print [p/1 " "]
				p: p + 1
			]
		]
		print "^/    rates: "
		either null? adev/rates [
			print "none"
		][
			p: adev/rates
			loop adev/rates-count [
				print [p/1 " "]
				p: p + 1
			]
		]
		print ["^/    default format: "]
		case [
			adev/format = ASAMPLE-TYPE-F32 [
				print-line "float32!"
			]
			adev/format = ASAMPLE-TYPE-I32 [
				print-line "integer!"
			]
			adev/format = ASAMPLE-TYPE-I16 [
				print-line "int16!"
			]
			true [
				print-line "unknown"
			]
		]
		print-line ["    default channels: " adev/channel]
		print-line ["    default rate: " adev/rate]
		;print-line ["    buffer frames: " buffer-size dev]
		print-line "================================"
	]

	default-device: func [
		type		[AUDIO-DEVICE-TYPE!]
		return:		[AUDIO-DEVICE!]
		/local
			name	[c-string!]
			pcm		[integer!]
			hr		[integer!]
			adev	[ALSA-DEVICE!]
	][
		name: "default"
		pcm: 0
		hr: snd_pcm_open :pcm name type 0
		if hr < 0 [return null]
		adev: as ALSA-DEVICE! allocate size? ALSA-DEVICE!
		set-memory as byte-ptr! adev #"^(00)" size? ALSA-DEVICE!
		adev/id: type-string/load-utf8 as byte-ptr! name
		adev/name: type-string/load-utf8 as byte-ptr! name
		adev/type: type
		init-device adev pcm
		snd_pcm_close pcm
		as AUDIO-DEVICE! adev
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

	filter-name: func [
		type		[AUDIO-DEVICE-TYPE!]
		name		[c-string!]
		return:		[logic!]
		/local
			size	[integer!]
			p		[int-ptr!]
			i		[integer!]
			j		[integer!]
	][
		if type = ADEVICE-TYPE-INPUT [
			size: size? input-filters
			p: input-filters
			size: size / 2
			loop size [
				if 0 = compare-memory as byte-ptr! name as byte-ptr! p/1 p/2 [
					return false
				]
				p: p + 2
			]
			return true
		]
		size: size? output-desired
		p: output-desired
		size: size / 2
		loop size [
			if 0 = compare-memory as byte-ptr! name as byte-ptr! p/1 p/2 [
				return true
			]
			p: p + 2
		]
		false
	]

	get-devices: func [
		type		[AUDIO-DEVICE-TYPE!]
		count		[int-ptr!]			;-- number of input devices
		return:		[AUDIO-DEVICE!]		;-- an array of AUDIO-DEVICE!
		/local
			num		[integer!]
			list	[int-ptr!]
			iter	[int-ptr!]
			end		[int-ptr!]
			card	[integer!]
			hr		[integer!]
			hints	[integer!]
			hint	[int-ptr!]
			name	[c-string!]
			ioid	[c-string!]
			desc	[c-string!]
			adev	[ALSA-DEVICE!]
			pcm		[integer!]
			nlist	[int-ptr!]
			niter	[int-ptr!]
	][
		count/1: 0
		num: 0
		list: system/stack/allocate 256
		iter: list
		end: list + 256
		end/0: 0
		card: -1
		forever [
			hr: snd_card_next :card
			if any [
				hr <> 0
				card = -1
			][break]
			hints: 0
			hr: snd_device_name_hint card "pcm" :hints
			if hr <> 0 [continue]
			hint: as int-ptr! hints
			while [hint/1 <> 0][
				name: snd_device_name_get_hint as int-ptr! hint/1 "NAME"
				if null? name [
					hint: hint + 1
					continue
				]
				unless filter-name type name [
					free as byte-ptr! name
					hint: hint + 1
					continue
				]
				ioid: snd_device_name_get_hint as int-ptr! hint/1 "IOID"
				if any [
					null? ioid
					all [
						0 = compare-memory as byte-ptr! ioid as byte-ptr! "Input" 6
						type = ADEVICE-TYPE-INPUT
					]
					all [
						0 = compare-memory as byte-ptr! ioid as byte-ptr! "Output" 7
						type = ADEVICE-TYPE-OUTPUT
					]
				][
					pcm: 0
					;print-line ["name: " name]
					hr: snd_pcm_open :pcm name type 0						;-- if the alsa lib not support the device, it will print some warnings
					;print-line ["hr: " hr " " snd_strerror hr]
					if hr >= 0 [
						either iter < end [
							desc: snd_device_name_get_hint as int-ptr! hint/1 "DESC"
							adev: as ALSA-DEVICE! allocate size? ALSA-DEVICE!
							set-memory as byte-ptr! adev #"^(00)" size? ALSA-DEVICE!
							adev/id: type-string/load-utf8 as byte-ptr! name
							unless null? desc [
								adev/name: type-string/load-utf8 as byte-ptr! desc
								free as byte-ptr! desc
							]
							adev/type: type
							init-device adev pcm
							iter/1: as integer! adev
							iter: iter + 1
							num: num + 1
							snd_pcm_close pcm
						][
							free as byte-ptr! name
							unless null? ioid [
								free as byte-ptr! ioid
							]
							snd_pcm_close pcm
							break
						]
					]
				]
				free as byte-ptr! name
				unless null? ioid [
					free as byte-ptr! ioid
				]
				hint: hint + 1
			]
			snd_device_name_free_hint hints
		]

		if num = 0 [
			return null
		]
		iter/1: 0
		count/1: num
		nlist: as int-ptr! allocate num + 1 * 4
		niter: list + num
		niter/1: 0
		copy-memory as byte-ptr! nlist as byte-ptr! list num * 4
		nlist
	]

	input-devices: func [
		count		[int-ptr!]				;-- number of input devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		get-devices ADEVICE-TYPE-INPUT count
	]

	output-devices: func [
		count		[int-ptr!]				;-- number of output devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		get-devices ADEVICE-TYPE-OUTPUT count
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
		/local
			adev	[ALSA-DEVICE!]
	][
		if null? dev [exit]
		;-- stop dev
		adev: as ALSA-DEVICE! dev
		type-string/release adev/id
		type-string/release adev/name
		unless null? adev/channels [
			free as byte-ptr! adev/channels
		]
		unless null? adev/rates [
			free as byte-ptr! adev/rates
		]
		unless null? adev/formats [
			free as byte-ptr! adev/formats
		]
		free as byte-ptr! adev
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

	name: func [
		dev			[AUDIO-DEVICE!]
		return:		[unicode-string!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/name
	]

	id: func [
		dev			[AUDIO-DEVICE!]
		return:		[unicode-string!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/id
	]

	channels: func [
		dev			[AUDIO-DEVICE!]
		count		[int-ptr!]
		return:		[int-ptr!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		if null? adev/channels [return null]
		count/1: adev/channels-count
		adev/channels
	]

	rates: func [
		dev			[AUDIO-DEVICE!]
		count		[int-ptr!]
		return:		[int-ptr!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		if null? adev/rates [return null]
		count/1: adev/rates-count
		adev/rates
	]

	sample-formats: func [
		dev			[AUDIO-DEVICE!]
		count		[int-ptr!]
		return:		[int-ptr!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		if null? adev/formats [return null]
		count/1: adev/formats-count
		adev/formats
	]

	channels-count: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/channel
	]

	set-channels-count: func [
		dev			[AUDIO-DEVICE!]
		chs			[integer!]
		return:		[logic!]
		/local
			adev	[ALSA-DEVICE!]
			pcm		[integer!]
			params	[integer!]
			p		[int-ptr!]
			name	[c-string!]
			hr		[integer!]
	][
		adev: as ALSA-DEVICE! dev
		if adev/running? [return false]
		pcm: 0
		params: 0
		p: as int-ptr! adev/id
		name: as c-string! p + 1
		hr: snd_pcm_open :pcm name adev/type 0
		if hr < 0 [return false]
		hr: snd_pcm_hw_params_malloc :params
		if hr < 0 [
			snd_pcm_close pcm
			return false
		]
		hr: snd_pcm_hw_params_any pcm params
		if hr < 0 [
			snd_pcm_hw_params_free params
			snd_pcm_close pcm
			return false
		]
		hr: snd_pcm_hw_params_set_channels pcm params chs
		if hr < 0 [
			snd_pcm_hw_params_free params
			snd_pcm_close pcm
			return false
		]
		adev/channel: chs
		snd_pcm_hw_params_free params
		snd_pcm_close pcm
		true
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
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/rate
	]

	set-sample-rate: func [
		dev			[AUDIO-DEVICE!]
		rate		[integer!]
		return:		[logic!]
		/local
			adev	[ALSA-DEVICE!]
			pcm		[integer!]
			params	[integer!]
			p		[int-ptr!]
			name	[c-string!]
			hr		[integer!]
	][
		adev: as ALSA-DEVICE! dev
		if adev/running? [return false]
		pcm: 0
		params: 0
		p: as int-ptr! adev/id
		name: as c-string! p + 1
		hr: snd_pcm_open :pcm name adev/type 0
		if hr < 0 [return false]
		hr: snd_pcm_hw_params_malloc :params
		if hr < 0 [
			snd_pcm_close pcm
			return false
		]
		hr: snd_pcm_hw_params_any pcm params
		if hr < 0 [
			snd_pcm_hw_params_free params
			snd_pcm_close pcm
			return false
		]
		hr: snd_pcm_hw_params_set_rate pcm params rate 0
		if hr < 0 [
			snd_pcm_hw_params_free params
			snd_pcm_close pcm
			return false
		]
		adev/rate: rate
		snd_pcm_hw_params_free params
		snd_pcm_close pcm
		true
	]

	sample-format: func [
		dev			[AUDIO-DEVICE!]
		return:		[AUDIO-SAMPLE-TYPE!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/format
	]

	set-sample-format: func [
		dev			[AUDIO-DEVICE!]
		type		[AUDIO-SAMPLE-TYPE!]
		return:		[logic!]
		/local
			adev	[ALSA-DEVICE!]
			pcm		[integer!]
			params	[integer!]
			p		[int-ptr!]
			name	[c-string!]
			hr		[integer!]
			format	[integer!]
	][
		adev: as ALSA-DEVICE! dev
		if adev/running? [return false]
		pcm: 0
		params: 0
		p: as int-ptr! adev/id
		name: as c-string! p + 1
		hr: snd_pcm_open :pcm name adev/type 0
		if hr < 0 [return false]
		hr: snd_pcm_hw_params_malloc :params
		if hr < 0 [
			snd_pcm_close pcm
			return false
		]
		hr: snd_pcm_hw_params_any pcm params
		if hr < 0 [
			snd_pcm_hw_params_free params
			snd_pcm_close pcm
			return false
		]
		case [
			type = ASAMPLE-TYPE-F32 [
				format: SND_PCM_FORMAT_FLOAT_LE
			]
			type = ASAMPLE-TYPE-I32 [
				format: SND_PCM_FORMAT_S32_LE
			]
			type = ASAMPLE-TYPE-I16 [
				format: SND_PCM_FORMAT_S16_LE
			]
			true [
				snd_pcm_hw_params_free params
				snd_pcm_close pcm
				return false
			]
		]
		hr: snd_pcm_hw_params_set_format pcm params format
		if hr < 0 [
			snd_pcm_hw_params_free params
			snd_pcm_close pcm
			return false
		]
		adev/format: type
		snd_pcm_hw_params_free params
		snd_pcm_close pcm
		true
	]

	input?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/type = ADEVICE-TYPE-INPUT
	]

	output?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/type = ADEVICE-TYPE-OUTPUT
	]

	running?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/running?
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
			adev	[ALSA-DEVICE!]
			format	[integer!]
			p		[int-ptr!]
			id		[c-string!]
			hr		[integer!]
	][
		adev: as ALSA-DEVICE! dev
		if adev/running? [return false]
		format: case [
			stype = ASAMPLE-TYPE-F32 [SND_PCM_FORMAT_FLOAT_LE]
			stype = ASAMPLE-TYPE-I32 [SND_PCM_FORMAT_S32_LE]
			stype = ASAMPLE-TYPE-I16 [SND_PCM_FORMAT_S16_LE]
		]
		p: as int-ptr! adev/id
		id: as c-string! p + 1
		hr: snd_pcm_open :adev/pcm id adev/type 0
		if hr <> 0 [return false]
		;hr: snd_pcm_hw_params_test_format adev/pcm adev/params format
		;if hr <> 0 [
		;	snd_pcm_close adev/pcm
		;	return false
		;]
		;snd_pcm_close adev/pcm
		;format: 0
		;hr: snd_pcm_hw_params_get_channels adev/params :format
		;print-line [hr " " format]
		true
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

