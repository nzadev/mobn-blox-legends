extends Node

signal announcer_callout(phrase: String)

var muted: bool = false
var bgm_mode: String = ""
var _step_index: int = 0
var _bgm_timer: float = 0.0
var _bgm_interval: float = 0.35

var _sfx_player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _sample_rate: float = 22050.0
var _active_tones: Array[Dictionary] = []

func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = _sample_rate
	gen.buffer_length = 0.15
	_sfx_player.stream = gen
	_sfx_player.volume_db = -4.0
	add_child(_sfx_player)
	_sfx_player.play()
	_playback = _sfx_player.get_stream_playback() as AudioStreamGeneratorPlayback

func _process(delta: float) -> void:
	if bgm_mode != "" and not muted:
		_bgm_timer += delta
		if _bgm_timer >= _bgm_interval:
			_bgm_timer = 0.0
			_step_bgm()
	_fill_audio_buffer()

func _fill_audio_buffer() -> void:
	if _playback == null:
		return
	var frames: int = _playback.get_frames_available()
	if frames <= 0:
		return

	for _i: int in range(frames):
		var sample: float = 0.0
		if not muted and _active_tones.size() > 0:
			for idx: int in range(_active_tones.size() - 1, -1, -1):
				var t: Dictionary = _active_tones[idx]
				var elapsed: float = t["elapsed"]
				var dur: float = t["duration"]
				if elapsed >= dur:
					_active_tones.remove_at(idx)
					continue
				var env: float = (1.0 - (elapsed / dur)) * float(t["vol"])
				var freq: float = float(t["freq"]) + float(t["slide"]) * (elapsed / dur)
				var phase: float = float(t["phase"])
				var wave_type: String = t["type"]
				var val: float = 0.0
				if wave_type == "sine":
					val = sin(phase * TAU)
				elif wave_type == "square":
					val = 1.0 if sin(phase * TAU) >= 0.0 else -1.0
				elif wave_type == "sawtooth":
					val = 2.0 * (phase - floor(0.5 + phase))
				elif wave_type == "noise":
					val = randf_range(-1.0, 1.0)
				else:
					val = 2.0 * absf(2.0 * (phase - floor(phase + 0.5))) - 1.0
				sample += val * env
				t["phase"] = fmod(phase + maxf(25.0, freq) / _sample_rate, 1.0)
				t["elapsed"] = elapsed + (1.0 / _sample_rate)
		sample = clampf(sample, -0.9, 0.9)
		_playback.push_frame(Vector2(sample, sample))

func play_tone(freq: float, wave_type: String = "sine", duration: float = 0.15, vol: float = 0.14, slide: float = 0.0) -> void:
	if muted:
		return
	if _active_tones.size() > 16:
		_active_tones.pop_front()
	_active_tones.append({
		"freq": freq,
		"type": wave_type,
		"duration": duration,
		"vol": vol,
		"slide": slide,
		"phase": 0.0,
		"elapsed": 0.0
	})

func play_chord(freqs: Array[float], wave_type: String = "triangle", duration: float = 0.45, vol: float = 0.12) -> void:
	if muted or freqs.is_empty():
		return
	var per_vol: float = vol / float(freqs.size())
	for f: float in freqs:
		play_tone(f, wave_type, duration, per_vol, 0.0)

func start_bgm(mode: String) -> void:
	if bgm_mode == mode:
		return
	bgm_mode = mode
	_step_index = 0
	_bgm_timer = 0.0
	if mode == "BATTLE":
		_bgm_interval = 0.22
	elif mode == "DRAFT":
		_bgm_interval = 0.26
	else:
		_bgm_interval = 0.38

func stop_bgm() -> void:
	bgm_mode = ""

func _step_bgm() -> void:
	var step: int = _step_index
	_step_index += 1
	if bgm_mode == "LOBBY":
		var lobby_chords: Array = [
			[220.0, 261.63, 329.63],
			[174.61, 220.0, 261.63],
			[130.81, 164.81, 196.0],
			[196.0, 246.94, 293.66]
		]
		var lobby_lead: Array[float] = [440.0, 523.25, 659.25, 587.33, 523.25, 659.25, 783.99, 659.25]
		if step % 4 == 0:
			var c: Array = lobby_chords[(step / 4) % lobby_chords.size()]
			var typed_c: Array[float] = [float(c[0]), float(c[1]), float(c[2])]
			play_chord(typed_c, "triangle", 1.1, 0.05)
		if step % 2 == 0:
			var note: float = lobby_lead[step % lobby_lead.size()]
			play_tone(note, "sine", 0.38, 0.035, 0.0)
	elif bgm_mode == "DRAFT":
		var bass: float = 110.0 if (step % 2 == 0) else 146.83
		play_tone(bass, "sawtooth", 0.18, 0.05, -20.0)
		if step % 4 == 0:
			play_chord([220.0, 277.18, 329.63], "triangle", 0.5, 0.05)
	elif bgm_mode == "BATTLE":
		var battle_bass: Array[float] = [110.0, 110.0, 130.81, 146.83, 98.0, 98.0, 110.0, 130.81]
		var battle_lead: Array[float] = [440.0, 0.0, 523.25, 587.33, 659.25, 587.33, 523.25, 392.0]
		var b_note: float = battle_bass[step % battle_bass.size()]
		play_tone(b_note, "sawtooth", 0.16, 0.045, -15.0)
		var l_note: float = battle_lead[step % battle_lead.size()]
		if l_note > 0.0 and step % 2 == 0:
			play_tone(l_note, "triangle", 0.24, 0.038, 0.0)
		if step % 4 == 0:
			play_tone(120.0, "noise", 0.05, 0.03, 0.0)

func announce(phrase: String) -> void:
	announcer_callout.emit(phrase)
	if muted:
		return
	play_chord([220.0, 277.18, 329.63, 440.0], "sawtooth", 0.5, 0.14)
	var voices: PackedStringArray = DisplayServer.tts_get_voices_for_language("en")
	if voices.size() > 0:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(phrase, voices[0], 90, 0.88, 1.04)

func click() -> void:
	play_tone(660.0, "triangle", 0.065, 0.12, 200.0)

func confirm() -> void:
	play_tone(523.25, "sine", 0.11, 0.15, 110.0)
	play_tone(783.99, "triangle", 0.2, 0.16, 180.0)

func match_found() -> void:
	play_chord([440.0, 554.37, 659.25, 880.0], "triangle", 0.38, 0.22)

func shoot() -> void:
	play_tone(520.0, "sawtooth", 0.085, 0.11, -280.0)
	play_tone(200.0, "noise", 0.04, 0.04, 0.0)

func slash() -> void:
	play_tone(310.0, "triangle", 0.11, 0.12, -180.0)
	play_tone(180.0, "noise", 0.06, 0.05, 0.0)

func skill1() -> void:
	play_tone(580.0, "sawtooth", 0.2, 0.15, 320.0)

func skill2() -> void:
	play_tone(360.0, "square", 0.24, 0.14, -160.0)

func ultimate() -> void:
	play_tone(180.0, "sawtooth", 0.5, 0.22, 640.0)
	play_tone(720.0, "triangle", 0.4, 0.18, -380.0)
	play_tone(150.0, "noise", 0.2, 0.09, 0.0)

func hit() -> void:
	play_tone(140.0, "square", 0.055, 0.09, -60.0)

func gold() -> void:
	play_tone(1046.5, "sine", 0.08, 0.13, 340.0)
	play_tone(1318.5, "sine", 0.12, 0.13, 200.0)

func kill_fanfare() -> void:
	play_chord([587.33, 739.99, 880.0, 1174.66], "triangle", 0.42, 0.24)

func level_up() -> void:
	play_chord([523.25, 659.25, 783.99, 1046.5], "sine", 0.35, 0.2)

