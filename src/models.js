class SoundEngine {
  constructor() {
    this.ctx = null;
    this.muted = false;
    this.bgmMode = null; // 'LOBBY' | 'DRAFT' | 'BATTLE'
    this.bgmTimer = null;
    this.stepIndex = 0;
    this.voices = [];

    if ('speechSynthesis' in window) {
      const loadVoices = () => {
        this.voices = window.speechSynthesis.getVoices();
      };
      loadVoices();
      window.speechSynthesis.onvoiceschanged = loadVoices;
    }
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (AudioCtx) {
        this.ctx = new AudioCtx();
        this.masterGain = this.ctx.createGain();
        this.masterGain.gain.value = 0.72;
        this.masterGain.connect(this.ctx.destination);
      }
    }
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  // MLBB Announcer Voice System ("Welcome to Mobile Blox Legends", "First Blood", "Double Kill", "Savage", etc.)
  announce(phrase, pitch = 0.85, rate = 1.02) {
    if (this.muted) return;
    this.init();

    // Epic cinematic brass stinger behind the voice
    this.playChord([220, 277.18, 329.63, 440], 'sawtooth', 0.55, 0.11);

    if (!('speechSynthesis' in window)) return;
    try {
      window.speechSynthesis.cancel();
      const utter = new SpeechSynthesisUtterance(phrase);
      if (this.voices.length === 0) {
        this.voices = window.speechSynthesis.getVoices();
      }
      const engVoice = this.voices.find((v) => v.lang.includes('en') && (v.name.includes('Google') || v.name.includes('English'))) || this.voices[0];
      if (engVoice) utter.voice = engVoice;
      utter.pitch = pitch;
      utter.rate = rate;
      utter.volume = 0.95;
      window.speechSynthesis.speak(utter);
    } catch (_) {}
  }

  // Dynamic Orchestral / Electronic MOBA Soundtrack Sequencer
  startBGM(mode) {
    if (this.bgmMode === mode && this.bgmTimer) return;
    this.stopBGM();
    this.bgmMode = mode;
    this.stepIndex = 0;

    const lobbyChords = [
      [220, 261.63, 329.63], // Am
      [174.61, 220, 261.63], // F
      [130.81, 164.81, 196], // C
      [196, 246.94, 293.66]  // G
    ];
    const lobbyLead = [440, 523.25, 659.25, 587.33, 523.25, 659.25, 783.99, 659.25];

    const battleBass = [110, 110, 130.81, 146.83, 98, 98, 110, 130.81];
    const battleLead = [440, 0, 523.25, 587.33, 659.25, 587.33, 523.25, 392];

    const intervalMs = mode === 'BATTLE' ? 210 : (mode === 'DRAFT' ? 250 : 380);

    this.bgmTimer = setInterval(() => {
      if (this.muted) return;
      this.init();
      if (!this.ctx || this.ctx.state !== 'running') return;

      const step = this.stepIndex++;
      if (mode === 'LOBBY') {
        if (step % 4 === 0) {
          const chord = lobbyChords[Math.floor(step / 4) % lobbyChords.length];
          this.playChord(chord, 'triangle', 1.35, 0.035);
        }
        const note = lobbyLead[step % lobbyLead.length];
        if (note && step % 2 === 0) {
          this.playTone(note, 'sine', 0.45, 0.03, 0);
        }
      } else if (mode === 'DRAFT') {
        // Tense war-drum + synth pulse during hero draft
        const bass = step % 2 === 0 ? 110 : 146.83;
        this.playTone(bass, 'sawtooth', 0.18, 0.045, -20);
        if (step % 4 === 0) {
          this.playChord([220, 277.18, 329.63], 'triangle', 0.6, 0.04);
        }
      } else if (mode === 'BATTLE') {
        // Energetic MOBA Arena battle beat
        const bNote = battleBass[step % battleBass.length];
        this.playTone(bNote, 'sawtooth', 0.16, 0.042, -15);
        const lNote = battleLead[step % battleLead.length];
        if (lNote > 0 && step % 2 === 0) {
          this.playTone(lNote, 'triangle', 0.25, 0.032, 0);
        }
        if (step % 4 === 0) {
          this.playNoiseHit(0.06, 0.025);
        }
      }
    }, intervalMs);
  }

  stopBGM() {
    if (this.bgmTimer) {
      clearInterval(this.bgmTimer);
      this.bgmTimer = null;
    }
    this.bgmMode = null;
  }

  playChord(freqs, type = 'triangle', duration = 0.5, vol = 0.06) {
    if (this.muted) return;
    this.init();
    if (!this.ctx) return;
    freqs.forEach((f) => this.playTone(f, type, duration, vol / freqs.length, 0));
  }

  playNoiseHit(duration = 0.08, vol = 0.05) {
    if (this.muted || !this.ctx) return;
    const bufferSize = this.ctx.sampleRate * duration;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      data[i] = Math.random() * 2 - 1;
    }
    const noise = this.ctx.createBufferSource();
    noise.buffer = buffer;
    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(vol, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + duration);
    noise.connect(gain);
    gain.connect(this.masterGain || this.ctx.destination);
    noise.start();
  }

  playTone(freq, type = 'sine', duration = 0.15, vol = 0.12, slide = 0) {
    if (this.muted) return;
    this.init();
    if (!this.ctx) return;

    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = type;
    osc.frequency.setValueAtTime(freq, now);
    if (slide !== 0) {
      osc.frequency.exponentialRampToValueAtTime(Math.max(25, freq + slide), now + duration);
    }
    gain.gain.setValueAtTime(vol, now);
    gain.gain.exponentialRampToValueAtTime(0.0008, now + duration);

    osc.connect(gain);
    gain.connect(this.masterGain || this.ctx.destination);
    osc.start(now);
    osc.stop(now + duration);
  }

  click() {
    this.playTone(660, 'triangle', 0.065, 0.11, 200);
  }

  confirm() {
    this.playTone(523.25, 'sine', 0.11, 0.15, 110);
    setTimeout(() => this.playTone(783.99, 'triangle', 0.2, 0.18, 180), 65);
  }

  matchFound() {
    [440, 554.37, 659.25, 880].forEach((f, i) => {
      setTimeout(() => this.playTone(f, 'triangle', 0.24, 0.18, 45), i * 85);
    });
  }

  shoot() {
    this.playTone(520, 'sawtooth', 0.085, 0.09, -280);
    this.playNoiseHit(0.04, 0.03);
  }

  slash() {
    this.playTone(310, 'triangle', 0.11, 0.11, -180);
    this.playNoiseHit(0.06, 0.045);
  }

  skill1() {
    this.playTone(580, 'sawtooth', 0.2, 0.14, 320);
  }

  skill2() {
    this.playTone(360, 'square', 0.24, 0.13, -160);
  }

  ultimate() {
    this.playTone(180, 'sawtooth', 0.55, 0.22, 640);
    setTimeout(() => this.playTone(720, 'triangle', 0.45, 0.2, -380), 110);
    this.playNoiseHit(0.22, 0.08);
  }

  hit() {
    this.playTone(140, 'square', 0.055, 0.08, -60);
  }

  gold() {
    this.playTone(1046.5, 'sine', 0.075, 0.12, 340);
    setTimeout(() => this.playTone(1318.5, 'sine', 0.1, 0.12, 200), 55);
  }

  kill() {
    [587.33, 739.99, 880, 1174.66].forEach((f, i) => {
      setTimeout(() => this.playTone(f, 'triangle', 0.28, 0.2, 40), i * 85);
    });
  }

  levelUp() {
    [523.25, 659.25, 783.99, 1046.5].forEach((f, i) => {
      setTimeout(() => this.playTone(f, 'sine', 0.22, 0.16, 60), i * 65);
    });
  }
}

window.SFX = new SoundEngine();

const _texLoader = (typeof THREE !== 'undefined' && THREE.TextureLoader) ? new THREE.TextureLoader() : null;
const _faceTexCache = {};
const _torsoTexCache = {};

function makeFaceTexture(skinHex, hairHex, heroId = '') {
  if (_texLoader && heroId && !_faceTexCache[heroId]) {
    _faceTexCache[heroId] = _texLoader.load(`assets/textures/faces/${heroId}_face.png?v=3`);
  }
  if (_faceTexCache[heroId]) {
    return _faceTexCache[heroId];
  }
  const canvas = document.createElement('canvas');
  canvas.width = 256;
  canvas.height = 256;
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = skinHex || '#f8d2b4';
  ctx.fillRect(0, 0, 256, 256);
  const tex = new THREE.CanvasTexture(canvas);
  tex.needsUpdate = true;
  return tex;
}

function makeTorsoTexture(hero, c) {
  if (_texLoader && hero && hero.id && !_torsoTexCache[hero.id]) {
    _torsoTexCache[hero.id] = _texLoader.load(`assets/textures/torsos/${hero.id}_torso.png?v=3`);
  }
  if (hero && _torsoTexCache[hero.id]) {
    return _torsoTexCache[hero.id];
  }
  const canvas = document.createElement('canvas');
  canvas.width = 256;
  canvas.height = 256;
  const ctx = canvas.getContext('2d');
  ctx.fillStyle = c.torso;
  ctx.fillRect(0, 0, 256, 256);
  const tex = new THREE.CanvasTexture(canvas);
  tex.needsUpdate = true;
  return tex;
}

function buildRobloxHeroMesh(hero, skinOverride = null) {
  const c = Object.assign({}, hero.colors);
  if (skinOverride) {
    c.coat = skinOverride.coat || c.coat;
    c.hair = skinOverride.hair || c.hair;
    c.trim = skinOverride.trim || c.trim;
  }

  const root = new THREE.Group();

  const matSkin = new THREE.MeshStandardMaterial({ color: c.skin, roughness: 0.38, metalness: 0.06 });
  const matHair = new THREE.MeshStandardMaterial({ color: c.hair, roughness: 0.34, metalness: 0.16 });
  const matCoat = new THREE.MeshStandardMaterial({ color: c.coat, roughness: 0.4, metalness: 0.28 });
  const matTrim = new THREE.MeshStandardMaterial({
    color: c.trim,
    roughness: 0.22,
    metalness: 0.78,
    emissive: c.trim,
    emissiveIntensity: 0.32
  });
  const matAura = new THREE.MeshStandardMaterial({
    color: c.aura,
    roughness: 0.15,
    metalness: 0.4,
    emissive: c.aura,
    emissiveIntensity: 0.9
  });
  const matPants = new THREE.MeshStandardMaterial({ color: c.pants, roughness: 0.52 });
  const matWeapon = new THREE.MeshStandardMaterial({
    color: c.weaponColor,
    roughness: 0.2,
    metalness: 0.85,
    emissive: c.weaponColor,
    emissiveIntensity: 0.4
  });

  const faceTex = makeFaceTexture(c.skin, c.hair, hero.id);
  const headMaterials = [
    matSkin, matSkin, matSkin, matSkin,
    new THREE.MeshStandardMaterial({ map: faceTex, roughness: 0.38 }),
    matSkin
  ];

  const torsoTex = makeTorsoTexture(hero, c);
  const torsoMaterials = [
    matCoat, matCoat, matCoat, matCoat,
    new THREE.MeshStandardMaterial({ map: torsoTex, roughness: 0.4 }),
    matCoat
  ];

  // Sculpted Armored Legs with Knee Guards & Heavy Greaves
  const buildLeg = (xPos) => {
    const legPivot = new THREE.Group();
    legPivot.position.set(xPos, 1.02, 0);

    const thigh = new THREE.Mesh(new THREE.BoxGeometry(0.45, 0.54, 0.46), matPants);
    thigh.position.y = -0.26;
    thigh.castShadow = true;
    legPivot.add(thigh);

    // Metallic Knee Guard
    const knee = new THREE.Mesh(new THREE.BoxGeometry(0.49, 0.2, 0.52), matTrim);
    knee.position.set(0, -0.52, 0.04);
    legPivot.add(knee);

    // Armored Shin Greave
    const shin = new THREE.Mesh(new THREE.BoxGeometry(0.5, 0.46, 0.52), matCoat);
    shin.position.set(0, -0.78, 0.01);
    shin.castShadow = true;
    legPivot.add(shin);

    // Boot & Glowing Sole Trim
    const sole = new THREE.Mesh(new THREE.BoxGeometry(0.54, 0.12, 0.6), matTrim);
    sole.position.set(0, -0.97, 0.04);
    legPivot.add(sole);

    return legPivot;
  };

  const leftLegPivot = buildLeg(-0.28);
  const rightLegPivot = buildLeg(0.28);
  root.add(leftLegPivot, rightLegPivot);

  // Sculpted Armored Torso + 3D Chest Core + Pauldrons + Waist Tassets + Hero Back Attachments
  const torsoGroup = new THREE.Group();
  torsoGroup.position.set(0, 1.56, 0);
  const torsoMesh = new THREE.Mesh(new THREE.BoxGeometry(1.08, 1.12, 0.56), torsoMaterials);
  torsoMesh.castShadow = true;
  torsoGroup.add(torsoMesh);

  // 3D Chest Breastplate & Glowing Power Core Diamond
  const chestPlate = new THREE.Mesh(new THREE.BoxGeometry(0.86, 0.52, 0.12), matCoat);
  chestPlate.position.set(0, 0.16, 0.28);
  torsoGroup.add(chestPlate);

  const coreGem = new THREE.Mesh(new THREE.OctahedronGeometry(0.18, 0), matAura);
  coreGem.position.set(0, 0.16, 0.35);
  torsoGroup.add(coreGem);

  // Tactical Waist Belt & Side Armor Tassets
  const belt = new THREE.Mesh(new THREE.BoxGeometry(1.14, 0.18, 0.62), matTrim);
  belt.position.set(0, -0.44, 0);
  torsoGroup.add(belt);

  [-0.56, 0.56].forEach((tx) => {
    const tasset = new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.46, 0.58), matCoat);
    tasset.position.set(tx, -0.62, 0);
    tasset.rotation.z = tx < 0 ? 0.18 : -0.18;
    torsoGroup.add(tasset);
  });

  // Layered Angled Shoulder Pauldrons with Spikes
  [-1, 1].forEach((dir) => {
    const pauldron = new THREE.Mesh(new THREE.BoxGeometry(0.46, 0.28, 0.68), matTrim);
    pauldron.position.set(dir * 0.54, 0.48, 0.02);
    pauldron.rotation.z = dir * -0.22;
    torsoGroup.add(pauldron);

    const fin = new THREE.Mesh(new THREE.ConeGeometry(0.14, 0.38, 4), matAura);
    fin.position.set(dir * 0.66, 0.66, 0.02);
    fin.rotation.z = dir * -0.45;
    torsoGroup.add(fin);
  });

  // Hero-Specific 3D Back Attachments (Dragon Wings, Jetpack, Cyber Thrusters, Lunar Halo, Royal Cape)
  if (hero.id === 'yuzong') {
    [-1, 1].forEach((dir) => {
      const wingGroup = new THREE.Group();
      wingGroup.position.set(dir * 0.25, 0.22, -0.32);
      for (let i = 0; i < 3; i++) {
        const bone = new THREE.Mesh(new THREE.BoxGeometry(0.16, 1.15 - i * 0.22, 0.14), matTrim);
        bone.position.set(dir * (0.38 + i * 0.34), 0.25 - i * 0.15, -0.12 - i * 0.05);
        bone.rotation.z = dir * (-0.55 - i * 0.25);
        wingGroup.add(bone);
      }
      torsoGroup.add(wingGroup);
    });
  } else if (hero.id === 'kimee') {
    // Alchemist Twin-Turbine Jetpack
    [-0.28, 0.28].forEach((jx) => {
      const tank = new THREE.Mesh(new THREE.CylinderGeometry(0.2, 0.24, 0.88, 12), matTrim);
      tank.position.set(jx, 0.05, -0.45);
      torsoGroup.add(tank);
      const flame = new THREE.Mesh(new THREE.ConeGeometry(0.16, 0.42, 8), matAura);
      flame.position.set(jx, -0.52, -0.45);
      flame.rotation.x = Math.PI;
      torsoGroup.add(flame);
    });
  } else if (hero.id === 'esteez' || hero.id === 'kajee') {
    // Floating Celestial Halo Ring behind Back
    const halo = new THREE.Mesh(new THREE.TorusGeometry(0.95, 0.07, 10, 32), matAura);
    halo.position.set(0, 0.55, -0.42);
    torsoGroup.add(halo);
    const cape = new THREE.Mesh(new THREE.BoxGeometry(1.16, 1.45, 0.1), matCoat);
    cape.position.set(0, -0.45, -0.32);
    cape.rotation.x = 0.16;
    torsoGroup.add(cape);
  } else if (hero.id === 'sabro' || hero.id === 'masteryee' || hero.id === 'gusionox') {
    // Cyber Scarf / Back Blade Wings
    [-1, 1].forEach((dir) => {
      const vane = new THREE.Mesh(new THREE.BoxGeometry(0.12, 1.1, 0.28), matAura);
      vane.position.set(dir * 0.48, 0.28, -0.42);
      vane.rotation.z = dir * -0.42;
      vane.rotation.x = -0.25;
      torsoGroup.add(vane);
    });
  } else {
    const cape = new THREE.Mesh(new THREE.BoxGeometry(1.14, 1.38, 0.1), matCoat);
    cape.position.set(0, -0.45, -0.32);
    cape.rotation.x = 0.14;
    torsoGroup.add(cape);
  }

  root.add(torsoGroup);

  // Sculpted Anime Head + 3D Spiky Hair / Crown / Horns / Visor
  const headGroup = new THREE.Group();
  headGroup.position.set(0, 2.55, 0);
  const headMesh = new THREE.Mesh(new THREE.BoxGeometry(0.88, 0.88, 0.88), headMaterials);
  headMesh.castShadow = true;
  headGroup.add(headMesh);

  // Sculpted Multi-Piece Hair Crown & Anime Bangs
  const hairTop = new THREE.Mesh(new THREE.BoxGeometry(0.98, 0.34, 0.98), matHair);
  hairTop.position.set(0, 0.4, 0);
  headGroup.add(hairTop);

  const hairBack = new THREE.Mesh(new THREE.BoxGeometry(0.96, 0.88, 0.28), matHair);
  hairBack.position.set(0, 0.04, -0.4);
  headGroup.add(hairBack);

  // 3D Anime Spikes on top/back
  for (let i = -1; i <= 1; i++) {
    const spike = new THREE.Mesh(new THREE.ConeGeometry(0.24, 0.56, 4), matHair);
    spike.position.set(i * 0.32, 0.68, -0.12);
    spike.rotation.z = i * -0.32;
    spike.rotation.x = -0.28;
    headGroup.add(spike);
  }

  // Side face-framing hair locks
  [-0.46, 0.46].forEach((sx) => {
    const sideLock = new THREE.Mesh(new THREE.BoxGeometry(0.18, 0.84, 0.34), matHair);
    sideLock.position.set(sx, -0.06, 0.28);
    headGroup.add(sideLock);
  });

  // Front parted anime bangs
  [-1, 1].forEach((dir) => {
    const bang = new THREE.Mesh(new THREE.BoxGeometry(0.44, 0.28, 0.2), matHair);
    bang.position.set(dir * 0.24, 0.28, 0.44);
    bang.rotation.z = dir * -0.22;
    headGroup.add(bang);
  });

  let leftTailGroup = null;
  let rightTailGroup = null;

  if (c.hairStyle === 'twintails') {
    // Laylul's tactical visor goggles + dynamic flowing golden twintails
    const goggles = new THREE.Mesh(new THREE.BoxGeometry(0.94, 0.22, 0.36), matAura);
    goggles.position.set(0, 0.42, 0.36);
    headGroup.add(goggles);

    const bowMat = new THREE.MeshStandardMaterial({ color: '#0284c7', roughness: 0.25, metalness: 0.4 });
    [-1, 1].forEach((dir) => {
      const bow = new THREE.Mesh(new THREE.BoxGeometry(0.36, 0.3, 0.36), bowMat);
      bow.position.set(dir * 0.58, 0.36, -0.05);
      bow.rotation.z = dir * 0.25;
      headGroup.add(bow);

      const tGroup = new THREE.Group();
      tGroup.position.set(dir * 0.66, 0.34, -0.08);
      tGroup.rotation.z = dir * -0.2;

      const seg1 = new THREE.Mesh(new THREE.BoxGeometry(0.38, 0.98, 0.38), matHair);
      seg1.position.set(dir * 0.08, -0.44, 0);
      tGroup.add(seg1);

      const seg2 = new THREE.Mesh(new THREE.BoxGeometry(0.44, 1.18, 0.44), matHair);
      seg2.position.set(dir * 0.22, -1.38, 0.06);
      seg2.rotation.z = dir * 0.1;
      tGroup.add(seg2);

      const seg3 = new THREE.Mesh(new THREE.ConeGeometry(0.28, 0.95, 5), matHair);
      seg3.position.set(dir * 0.3, -2.25, 0.12);
      seg3.rotation.x = Math.PI;
      tGroup.add(seg3);

      headGroup.add(tGroup);
      if (dir < 0) leftTailGroup = tGroup;
      else rightTailGroup = tGroup;
    });
  } else if (c.hairStyle === 'horns' || c.hairStyle === 'bull_horns') {
    const isBull = c.hairStyle === 'bull_horns';
    [-1, 1].forEach((dir) => {
      const hornBase = new THREE.Mesh(new THREE.BoxGeometry(0.24, 0.48, 0.24), matTrim);
      hornBase.position.set(dir * 0.52, 0.46, 0.05);
      hornBase.rotation.z = dir * -0.48;
      headGroup.add(hornBase);

      const hornTip = new THREE.Mesh(new THREE.ConeGeometry(0.18, isBull ? 0.85 : 0.72, 5), matAura);
      hornTip.position.set(dir * 0.74, 0.88, 0.08);
      hornTip.rotation.z = dir * (isBull ? 0.15 : -0.25);
      headGroup.add(hornTip);
    });
  } else if (c.hairStyle === 'cyber_helm' || c.hairStyle === 'goggles_helm') {
    const visor = new THREE.Mesh(new THREE.BoxGeometry(0.96, 0.26, 0.96), matAura);
    visor.position.set(0, 0.08, 0.05);
    headGroup.add(visor);

    const crest = new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.62, 0.82), matTrim);
    crest.position.set(0, 0.62, 0.08);
    headGroup.add(crest);
  } else if (c.hairStyle === 'elf_crown' || c.hairStyle === 'bird_crest') {
    for (let i = -1; i <= 1; i++) {
      const prong = new THREE.Mesh(new THREE.ConeGeometry(0.14, 0.56 - Math.abs(i) * 0.12, 4), matTrim);
      prong.position.set(i * 0.26, 0.68, 0.38);
      headGroup.add(prong);
    }
  }

  root.add(headGroup);

  // Armored Arms with Vambrace Gauntlets
  const buildArm = (xOffset) => {
    const pivot = new THREE.Group();
    pivot.position.set(xOffset, 2.02, 0);

    const sleeve = new THREE.Mesh(new THREE.BoxGeometry(0.5, 0.52, 0.52), matCoat);
    sleeve.position.y = -0.22;
    sleeve.castShadow = true;
    pivot.add(sleeve);

    const vambrace = new THREE.Mesh(new THREE.BoxGeometry(0.55, 0.36, 0.56), matTrim);
    vambrace.position.y = -0.56;
    pivot.add(vambrace);

    const hand = new THREE.Mesh(new THREE.BoxGeometry(0.42, 0.38, 0.42), matSkin);
    hand.position.y = -0.84;
    hand.castShadow = true;
    pivot.add(hand);

    return pivot;
  };

  const leftArmPivot = buildArm(-0.82);
  const rightArmPivot = buildArm(0.82);
  root.add(leftArmPivot, rightArmPivot);

  // High-Detail Signature 3D Weapons (12 Unique Hero Weapons!)
  const weaponGroup = new THREE.Group();
  weaponGroup.position.set(0, -0.9, 0.38);
  const leftWeaponGroup = new THREE.Group();
  leftWeaponGroup.position.set(0, -0.9, 0.38);

  if (hero.id === 'laylul') {
    const body = new THREE.Mesh(new THREE.BoxGeometry(0.56, 0.58, 1.55), matWeapon);
    body.position.set(0, 0, 0.45);
    const barrel = new THREE.Mesh(new THREE.CylinderGeometry(0.24, 0.28, 1.95, 12), matTrim);
    barrel.rotation.x = Math.PI / 2;
    barrel.position.set(0, 0.06, 1.05);
    const ring1 = new THREE.Mesh(new THREE.TorusGeometry(0.32, 0.06, 8, 24), matAura);
    ring1.position.set(0, 0.06, 1.45);
    const ring2 = new THREE.Mesh(new THREE.TorusGeometry(0.38, 0.07, 8, 24), matAura);
    ring2.position.set(0, 0.06, 1.92);
    const fins = new THREE.Mesh(new THREE.BoxGeometry(0.95, 0.14, 0.65), matTrim);
    fins.position.set(0, 0.06, 0.85);
    weaponGroup.add(body, barrel, ring1, ring2, fins);
  } else if (hero.id === 'sabro') {
    [weaponGroup, leftWeaponGroup].forEach((wg) => {
      const guard = new THREE.Mesh(new THREE.BoxGeometry(0.38, 0.12, 0.16), matTrim);
      guard.position.set(0, 0, 0.18);
      const blade = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.08, 1.85), matWeapon);
      blade.position.set(0, 0, 1.12);
      const edge = new THREE.Mesh(new THREE.BoxGeometry(0.06, 0.11, 1.78), matAura);
      edge.position.set(0, 0.02, 1.12);
      wg.add(guard, blade, edge);
    });
  } else if (hero.id === 'yuzong') {
    [weaponGroup, leftWeaponGroup].forEach((wg) => {
      const cuff = new THREE.Mesh(new THREE.BoxGeometry(0.58, 0.48, 0.58), matTrim);
      cuff.position.set(0, 0.05, 0.05);
      wg.add(cuff);
      [-1, 0, 1].forEach((ci) => {
        const talon = new THREE.Mesh(new THREE.ConeGeometry(0.10, 0.92, 5), matAura);
        talon.rotation.x = Math.PI / 2;
        talon.position.set(ci * 0.17, 0, 0.62);
        wg.add(talon);
      });
    });
  } else if (hero.id === 'kajee') {
    for (let s = 0; s < 6; s++) {
      const link = new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.16, 0.36), s % 2 === 0 ? matAura : matTrim);
      link.position.set(Math.sin(s * 0.65) * 0.24, Math.cos(s * 0.5) * 0.12, 0.3 + s * 0.35);
      link.rotation.y = Math.sin(s) * 0.35;
      weaponGroup.add(link);
    }
    const shield = new THREE.Mesh(new THREE.TorusGeometry(0.38, 0.08, 8, 20), matTrim);
    shield.rotation.y = Math.PI / 2;
    shield.position.set(-0.15, 0.1, 0.1);
    leftWeaponGroup.add(shield);
  } else if (hero.id === 'yeen') {
    [weaponGroup, leftWeaponGroup].forEach((wg) => {
      const fist = new THREE.Mesh(new THREE.BoxGeometry(0.68, 0.64, 0.72), matWeapon);
      fist.position.set(0, 0, 0.18);
      const ring = new THREE.Mesh(new THREE.TorusGeometry(0.42, 0.06, 8, 20), matTrim);
      ring.position.set(0, 0.15, 0.15);
      wg.add(fist, ring);
      [-1, 0, 1].forEach((ki) => {
        const spike = new THREE.Mesh(new THREE.ConeGeometry(0.11, 0.38, 5), matAura);
        spike.rotation.x = Math.PI / 2;
        spike.position.set(ki * 0.18, 0, 0.68);
        wg.add(spike);
      });
    });
  } else if (hero.id === 'kimee') {
    const body = new THREE.Mesh(new THREE.BoxGeometry(0.46, 0.48, 1.35), matWeapon);
    body.position.set(0, 0, 0.45);
    const acidMat = new THREE.MeshStandardMaterial({ color: '#4ade80', emissive: '#4ade80', emissiveIntensity: 0.9 });
    const tank = new THREE.Mesh(new THREE.CylinderGeometry(0.24, 0.24, 0.75, 12), acidMat);
    tank.rotation.x = Math.PI / 2;
    tank.position.set(0, 0.42, 0.45);
    const nozL = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.14, 0.65, 10), matTrim);
    nozL.rotation.x = Math.PI / 2;
    nozL.position.set(-0.14, 0.05, 1.25);
    const nozR = nozL.clone();
    nozR.position.x = 0.14;
    weaponGroup.add(body, tank, nozL, nozR);
  } else if (hero.id === 'minotor') {
    const shaft = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 2.35, 10), matCoat);
    shaft.rotation.x = Math.PI / 2;
    shaft.position.set(0, 0, 0.75);
    const head = new THREE.Mesh(new THREE.BoxGeometry(1.55, 0.92, 0.92), matWeapon);
    head.position.set(0, 0, 1.62);
    const band = new THREE.Mesh(new THREE.BoxGeometry(1.68, 0.48, 0.48), matAura);
    band.position.set(0, 0, 1.62);
    const spike = new THREE.Mesh(new THREE.ConeGeometry(0.22, 0.55, 5), matTrim);
    spike.rotation.x = Math.PI / 2;
    spike.position.set(0, 0, 2.25);
    weaponGroup.add(shaft, head, band, spike);
  } else if (hero.id === 'esteez') {
    const staff = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.08, 2.1, 10), matTrim);
    staff.rotation.x = Math.PI / 2;
    staff.position.set(0, 0, 0.65);
    const crescent = new THREE.Mesh(new THREE.TorusGeometry(0.42, 0.08, 10, 24), matAura);
    crescent.position.set(0, 0, 1.65);
    weaponGroup.add(staff, crescent);
    const tome = new THREE.Mesh(new THREE.BoxGeometry(0.55, 0.14, 0.72), matTrim);
    tome.position.set(0, 0.25, 0.45);
    tome.rotation.set(0.3, 0, 0.25);
    const page = new THREE.Mesh(new THREE.BoxGeometry(0.48, 0.18, 0.64), matAura);
    page.position.set(0, 0.3, 0.45);
    page.rotation.set(0.3, 0, 0.25);
    leftWeaponGroup.add(tome, page);
  } else if (hero.id === 'masteryee') {
    const ring = new THREE.Mesh(new THREE.TorusGeometry(0.16, 0.04, 8, 18), matTrim);
    ring.position.set(0, 0, -0.15);
    const hilt = new THREE.Mesh(new THREE.BoxGeometry(0.46, 0.14, 0.18), matTrim);
    hilt.position.set(0, 0, 0.22);
    const blade = new THREE.Mesh(new THREE.BoxGeometry(0.14, 0.08, 2.05), matWeapon);
    blade.position.set(0, 0, 1.25);
    weaponGroup.add(ring, hilt, blade);
    [0, 1, 2].forEach((gi) => {
      const gem = new THREE.Mesh(new THREE.BoxGeometry(0.18, 0.14, 0.18), matAura);
      gem.position.set(0, 0, 0.55 + gi * 0.45);
      weaponGroup.add(gem);
    });
  } else if (hero.id === 'ketootoo') {
    [weaponGroup, leftWeaponGroup].forEach((wg) => {
      const grip = new THREE.Mesh(new THREE.BoxGeometry(0.24, 0.36, 0.28), matCoat);
      grip.position.set(0, -0.1, 0.15);
      const frame = new THREE.Mesh(new THREE.BoxGeometry(0.28, 0.28, 0.95), matWeapon);
      frame.position.set(0, 0.08, 0.52);
      const muzzle = new THREE.Mesh(new THREE.CylinderGeometry(0.12, 0.12, 0.42, 10), matAura);
      muzzle.rotation.x = Math.PI / 2;
      muzzle.position.set(0, 0.08, 0.95);
      wg.add(grip, frame, muzzle);
    });
  } else if (hero.id === 'alucardox') {
    const guard = new THREE.Mesh(new THREE.BoxGeometry(0.88, 0.18, 0.24), matTrim);
    guard.position.set(0, 0, 0.25);
    const blade = new THREE.Mesh(new THREE.BoxGeometry(0.46, 0.10, 2.45), matWeapon);
    blade.position.set(0, 0, 1.48);
    const core = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.14, 2.25), matAura);
    core.position.set(0, 0, 1.45);
    const tip = new THREE.Mesh(new THREE.ConeGeometry(0.24, 0.55, 4), matWeapon);
    tip.rotation.x = Math.PI / 2;
    tip.position.set(0, 0, 2.85);
    weaponGroup.add(guard, blade, core, tip);
  } else if (hero.id === 'gusionox') {
    const mainDagger = new THREE.Mesh(new THREE.ConeGeometry(0.14, 1.25, 4), matAura);
    mainDagger.rotation.x = Math.PI / 2;
    mainDagger.position.set(0, 0, 0.72);
    weaponGroup.add(mainDagger);
    [-2, -1, 0, 1, 2].forEach((di) => {
      const fanDagger = new THREE.Mesh(new THREE.ConeGeometry(0.08, 0.95, 4), matAura);
      fanDagger.rotation.set(Math.PI / 2, di * 0.25, 0);
      fanDagger.position.set(di * 0.22, 0, 0.55);
      leftWeaponGroup.add(fanDagger);
    });
  }

  rightArmPivot.add(weaponGroup);
  leftArmPivot.add(leftWeaponGroup);

  root.userData = {
    heroId: hero.id,
    leftLegPivot,
    rightLegPivot,
    leftArmPivot,
    rightArmPivot,
    headGroup,
    torsoGroup,
    weaponGroup,
    leftWeaponGroup,
    leftTailGroup,
    rightTailGroup,
    walkPhase: Math.random() * Math.PI * 2,
    attackTimer: 0,
    comboStep: 0
  };

  return root;
}

function animateRobloxCharacter(mesh, dt, isMoving, isAttacking) {
  if (!mesh || !mesh.userData) return;
  const u = mesh.userData;
  const hid = u.heroId || 'laylul';
  let spdMult = 12.5;
  if (hid === 'sabro' || hid === 'masteryee' || hid === 'gusionox') spdMult = 15.5;
  else if (hid === 'minotor' || hid === 'yuzong') spdMult = 10.2;
  else if (hid === 'kimee' || hid === 'esteez') spdMult = 8.5;

  u.walkPhase += dt * (isMoving ? spdMult : 2.8);

  const applyArmStance = (phaseVal) => {
    if (hid === 'laylul' || hid === 'kimee') {
      u.rightArmPivot.rotation.set(-0.62 - phaseVal * 0.15, -0.15, 0);
      u.leftArmPivot.rotation.set(-0.48 - phaseVal * 0.15, 0.28, 0);
    } else if (hid === 'ketootoo') {
      u.rightArmPivot.rotation.set(-0.75 - phaseVal * 0.3, 0, 0);
      u.leftArmPivot.rotation.set(-0.75 + phaseVal * 0.3, 0, 0);
    } else if (hid === 'sabro' || hid === 'gusionox') {
      u.rightArmPivot.rotation.set(0.45 - phaseVal * 0.4, 0, 0.25);
      u.leftArmPivot.rotation.set(0.45 + phaseVal * 0.4, 0, -0.25);
    } else if (hid === 'yuzong') {
      u.rightArmPivot.rotation.set(-0.35 - phaseVal * 0.35, 0, 0.38);
      u.leftArmPivot.rotation.set(-0.35 + phaseVal * 0.35, 0, -0.38);
    } else if (hid === 'yeen') {
      u.rightArmPivot.rotation.set(-0.85 - phaseVal * 0.25, -0.25, 0);
      u.leftArmPivot.rotation.set(-0.65 + phaseVal * 0.25, 0.25, 0);
    } else if (hid === 'minotor' || hid === 'alucardox') {
      u.rightArmPivot.rotation.set(-0.45 - phaseVal * 0.3, 0.15, 0.18);
      u.leftArmPivot.rotation.set(phaseVal * 0.5, 0, -0.15);
    } else if (hid === 'esteez') {
      u.rightArmPivot.rotation.set(-0.55 - phaseVal * 0.2, 0, 0);
      u.leftArmPivot.rotation.set(-0.72, 0.32, 0);
    } else if (hid === 'masteryee' || hid === 'kajee') {
      u.rightArmPivot.rotation.set(-0.35 - phaseVal * 0.35, -0.2, 0.25);
      u.leftArmPivot.rotation.set(phaseVal * 0.55, 0, -0.18);
    }
  };

  if (isMoving) {
    const swing = Math.sin(u.walkPhase) * 0.68;
    if (hid === 'kimee') {
      u.leftLegPivot.rotation.x = 0.35 + Math.sin(u.walkPhase) * 0.15;
      u.rightLegPivot.rotation.x = 0.45 - Math.sin(u.walkPhase) * 0.15;
      u.torsoGroup.position.y = 1.75 + Math.sin(u.walkPhase) * 0.12;
      u.torsoGroup.rotation.x = 0.22;
      u.headGroup.position.y = 2.72 + Math.sin(u.walkPhase) * 0.12;
    } else if (hid === 'esteez') {
      u.leftLegPivot.rotation.x = Math.sin(u.walkPhase) * 0.22;
      u.rightLegPivot.rotation.x = -Math.sin(u.walkPhase) * 0.22;
      u.torsoGroup.position.y = 1.72 + Math.sin(u.walkPhase) * 0.1;
      u.headGroup.position.y = 2.68 + Math.sin(u.walkPhase) * 0.1;
    } else if (hid === 'sabro' || hid === 'masteryee' || hid === 'gusionox') {
      u.leftLegPivot.rotation.x = swing * 1.15;
      u.rightLegPivot.rotation.x = -swing * 1.15;
      u.torsoGroup.position.y = 1.5 + Math.abs(Math.cos(u.walkPhase)) * 0.09;
      u.torsoGroup.rotation.x = 0.28;
      u.headGroup.position.y = 2.48 + Math.abs(Math.cos(u.walkPhase)) * 0.09;
    } else {
      u.leftLegPivot.rotation.x = swing;
      u.rightLegPivot.rotation.x = -swing;
      const bounce = Math.abs(Math.cos(u.walkPhase)) * 0.08;
      u.torsoGroup.position.y = 1.56 + bounce;
      u.headGroup.position.y = 2.55 + bounce;
      u.torsoGroup.rotation.z = Math.sin(u.walkPhase) * 0.06;
      u.torsoGroup.rotation.x = 0.08;
    }
    if (u.attackTimer <= 0) applyArmStance(swing);
    if (u.leftTailGroup && u.rightTailGroup) {
      u.leftTailGroup.rotation.x = 0.25 + Math.sin(u.walkPhase * 2) * 0.15;
      u.rightTailGroup.rotation.x = 0.25 + Math.cos(u.walkPhase * 2) * 0.15;
    }
  } else {
    const idleBob = Math.sin(u.walkPhase) * (hid === 'kimee' || hid === 'esteez' ? 0.11 : 0.05);
    const baseY = (hid === 'kimee' || hid === 'esteez') ? 1.68 : 1.56;
    u.leftLegPivot.rotation.x *= 0.84;
    u.rightLegPivot.rotation.x *= 0.84;
    u.torsoGroup.position.y = baseY + idleBob;
    u.headGroup.position.y = baseY + 0.98 + idleBob;
    u.torsoGroup.rotation.z *= 0.85;
    u.torsoGroup.rotation.x *= 0.85;
    if (u.attackTimer <= 0) applyArmStance(idleBob);
    if (u.leftTailGroup && u.rightTailGroup) {
      u.leftTailGroup.rotation.z = 0.18 + Math.sin(u.walkPhase) * 0.05;
      u.rightTailGroup.rotation.z = -0.18 - Math.sin(u.walkPhase) * 0.05;
      u.leftTailGroup.rotation.x *= 0.85;
      u.rightTailGroup.rotation.x *= 0.85;
    }
  }

  if (isAttacking) {
    u.attackTimer = 0.30;
    u.comboStep = ((u.comboStep || 0) + 1) % 2;
  }
  if (u.attackTimer > 0) {
    u.attackTimer -= dt;
    const p = Math.max(0, Math.min(1, (0.30 - u.attackTimer) / 0.30));
    const wave = Math.sin(p * Math.PI);
    if (hid === 'laylul' || hid === 'kimee') {
      u.rightArmPivot.rotation.x = -0.62 - wave * 0.45;
      u.leftArmPivot.rotation.x = -0.48 - wave * 0.45;
      u.torsoGroup.position.z = -wave * 0.18;
    } else if (hid === 'ketootoo') {
      if (u.comboStep === 0) u.rightArmPivot.rotation.x = -0.95 - wave * 0.55;
      else u.leftArmPivot.rotation.x = -0.95 - wave * 0.55;
      u.torsoGroup.rotation.y = (u.comboStep === 0 ? 0.25 : -0.25) * wave;
    } else if (hid === 'sabro' || hid === 'gusionox') {
      u.rightArmPivot.rotation.x = -1.45 + p * 2.2;
      u.leftArmPivot.rotation.x = -1.45 + p * 2.2;
      u.torsoGroup.rotation.y = Math.sin(p * Math.PI * 2) * 0.55;
    } else if (hid === 'yuzong' || hid === 'yeen') {
      if (u.comboStep === 0) {
        u.rightArmPivot.rotation.x = -1.6 + p * 2.3;
        u.torsoGroup.rotation.y = wave * 0.48;
      } else {
        u.leftArmPivot.rotation.x = -1.6 + p * 2.3;
        u.torsoGroup.rotation.y = -wave * 0.48;
      }
    } else if (hid === 'minotor' || hid === 'alucardox') {
      u.rightArmPivot.rotation.x = -2.1 + p * 2.8;
      u.leftArmPivot.rotation.x = -1.6 + p * 2.2;
      u.torsoGroup.rotation.x = wave * 0.35;
    } else if (hid === 'kajee') {
      u.rightArmPivot.rotation.y = -0.8 + p * 1.8;
      u.rightArmPivot.rotation.x = -0.9;
      u.torsoGroup.rotation.y = wave * 0.52;
    } else {
      u.rightArmPivot.rotation.x = -1.6 + p * 2.4;
      u.torsoGroup.rotation.y = (u.comboStep === 0 ? 0.55 : -0.55) * wave;
    }
  } else {
    u.torsoGroup.rotation.y *= 0.82;
    u.torsoGroup.position.z *= 0.82;
  }
}

function renderPortraitDataURL(hero, skinOverride = null) {
  if (!skinOverride || skinOverride.id === 'default') {
    return `assets/portraits/${hero.id}.png?v=3`;
  }
  const c = Object.assign({}, hero.colors);
  if (skinOverride) {
    c.coat = skinOverride.coat || c.coat;
    c.hair = skinOverride.hair || c.hair;
    c.trim = skinOverride.trim || c.trim;
  }

  const canvas = document.createElement('canvas');
  canvas.width = 180;
  canvas.height = 200;
  const ctx = canvas.getContext('2d');

  // Rich metallic gradient background
  const grad = ctx.createLinearGradient(0, 0, 180, 200);
  grad.addColorStop(0, '#1e3a8a');
  grad.addColorStop(0.5, '#0f172a');
  grad.addColorStop(1, '#090d16');
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, 180, 200);

  // Hero aura glow
  const rad = ctx.createRadialGradient(90, 95, 10, 90, 95, 90);
  rad.addColorStop(0, c.aura + 'aa');
  rad.addColorStop(1, 'transparent');
  ctx.fillStyle = rad;
  ctx.fillRect(0, 0, 180, 200);

  if (c.hairStyle === 'twintails') {
    ctx.fillStyle = c.hair;
    ctx.fillRect(14, 48, 28, 145);
    ctx.fillRect(138, 48, 28, 145);
  }

  ctx.fillStyle = c.coat;
  ctx.fillRect(28, 118, 124, 82);
  ctx.fillStyle = c.trim;
  ctx.fillRect(50, 118, 10, 82);
  ctx.fillRect(120, 118, 10, 82);

  ctx.fillStyle = c.skin;
  ctx.fillRect(50, 42, 80, 74);
  ctx.fillStyle = c.hair;
  ctx.fillRect(46, 26, 88, 26);

  ctx.fillStyle = '#0f172a';
  ctx.fillRect(62, 68, 16, 18);
  ctx.fillRect(102, 68, 16, 18);
  ctx.fillStyle = c.trim;
  ctx.fillRect(64, 72, 12, 12);
  ctx.fillRect(104, 72, 12, 12);

  return canvas.toDataURL();
}

window.ROBLOX_BUILDER = {
  buildRobloxHeroMesh,
  animateRobloxCharacter,
  renderPortraitDataURL
};
