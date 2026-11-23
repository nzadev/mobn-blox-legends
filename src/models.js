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

function makeFaceTexture(skinHex, hairHex, heroId = '') {
  const canvas = document.createElement('canvas');
  canvas.width = 256;
  canvas.height = 256;
  const ctx = canvas.getContext('2d');

  ctx.fillStyle = skinHex || '#f8d2b4';
  ctx.fillRect(0, 0, 256, 256);

  if (heroId === 'minotor') {
    // Bull snout & fierce glowing yellow eyes (exact match to 0:15 Minotor card!)
    ctx.fillStyle = '#fde047';
    ctx.fillRect(46, 92, 48, 28);
    ctx.fillRect(162, 92, 48, 28);
    ctx.fillStyle = '#7c2d12';
    ctx.fillRect(68, 140, 120, 74);
    // Golden bull nose ring
    ctx.strokeStyle = '#facc15';
    ctx.lineWidth = 12;
    ctx.beginPath();
    ctx.arc(128, 198, 28, 0, Math.PI * 2);
    ctx.stroke();
  } else if (heroId === 'yuzong') {
    // Dark fierce grey face with glowing crimson visor eyes (exact match to 0:14 Yu Zong!)
    ctx.fillStyle = '#09090b';
    ctx.fillRect(36, 88, 184, 42);
    ctx.fillStyle = '#e11d48';
    ctx.shadowColor = '#f43f5e';
    ctx.shadowBlur = 16;
    ctx.fillRect(50, 98, 56, 20);
    ctx.fillRect(150, 98, 56, 20);
    ctx.shadowBlur = 0;
    // Scar / Frown
    ctx.strokeStyle = '#e11d48';
    ctx.lineWidth = 6;
    ctx.beginPath();
    ctx.moveTo(96, 186);
    ctx.lineTo(160, 182);
    ctx.stroke();
  } else {
    // Detailed Anime Roblox Eyes (exact match to 0:00 Laylul & Kimee/Esteez/Yeen)
    ctx.fillStyle = 'rgba(244, 114, 182, 0.35)';
    ctx.beginPath();
    ctx.ellipse(58, 162, 22, 11, 0, 0, Math.PI * 2);
    ctx.ellipse(198, 162, 22, 11, 0, 0, Math.PI * 2);
    ctx.fill();

    // Golden/Dark Eyebrows
    ctx.strokeStyle = heroId === 'laylul' ? '#b45309' : '#1e293b';
    ctx.lineWidth = 9;
    ctx.lineCap = 'round';
    ctx.beginPath();
    ctx.moveTo(46, 86); ctx.quadraticCurveTo(74, 76, 98, 88);
    ctx.moveTo(158, 88); ctx.quadraticCurveTo(182, 76, 210, 86);
    ctx.stroke();

    // Big Sparkling Blue Anime Eyes
    const irisColor = heroId === 'yeen' ? '#f59e0b' : (heroId === 'esteez' ? '#38bdf8' : '#0284c7');
    [74, 182].forEach((cx) => {
      // Upper eyelashes
      ctx.fillStyle = '#0f172a';
      ctx.fillRect(cx - 28, 100, 56, 10);
      // Sclera
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(cx - 24, 108, 48, 42);
      // Outer iris
      ctx.fillStyle = '#0c4a6e';
      ctx.fillRect(cx - 18, 110, 36, 38);
      // Inner bright iris
      ctx.fillStyle = irisColor;
      ctx.fillRect(cx - 14, 116, 28, 30);
      // Pupil
      ctx.fillStyle = '#082f49';
      ctx.fillRect(cx - 7, 122, 14, 18);
      // Anime eye sparkles
      ctx.fillStyle = '#ffffff';
      ctx.fillRect(cx - 14, 112, 11, 11);
      ctx.fillRect(cx + 6, 132, 7, 7);
    });

    // Cute confident smile
    ctx.strokeStyle = '#9a3412';
    ctx.lineWidth = 7;
    ctx.lineCap = 'round';
    ctx.beginPath();
    ctx.arc(128, 174, 18, 0.18 * Math.PI, 0.82 * Math.PI);
    ctx.stroke();
  }

  const tex = new THREE.CanvasTexture(canvas);
  tex.needsUpdate = true;
  return tex;
}

function makeTorsoTexture(hero, c) {
  const canvas = document.createElement('canvas');
  canvas.width = 256;
  canvas.height = 256;
  const ctx = canvas.getContext('2d');

  ctx.fillStyle = c.torso;
  ctx.fillRect(0, 0, 256, 256);

  if (hero.id === 'laylul') {
    // Exact match to 0:00 Laylul's white/lilac corset, vertical purple-gold pleats, and golden waist belt!
    ctx.fillStyle = '#d8cfe8';
    ctx.fillRect(0, 0, 62, 256);
    ctx.fillRect(194, 0, 62, 256);

    // Vertical lilac/purple stripes on top bodice
    const stripeColors = ['#6b21a8', '#a855f7', '#d97706', '#6b21a8'];
    for (let i = 0; i < 4; i++) {
      ctx.fillStyle = stripeColors[i];
      ctx.fillRect(72 + i * 28, 18, 18, 92);
    }

    // Golden corset trim frames
    ctx.strokeStyle = '#d97706';
    ctx.lineWidth = 10;
    ctx.strokeRect(64, 12, 128, 108);

    // Dark purple lower vest + gold buttons
    ctx.fillStyle = '#3b0764';
    ctx.fillRect(68, 125, 120, 100);
    ctx.fillStyle = '#facc15';
    ctx.fillRect(0, 198, 256, 26);
    ctx.fillStyle = '#38bdf8';
    ctx.fillRect(112, 194, 32, 34);
  } else {
    // Royal armor / jacket trim details
    ctx.fillStyle = c.coat;
    ctx.fillRect(0, 0, 68, 256);
    ctx.fillRect(188, 0, 68, 256);
    ctx.fillStyle = c.trim;
    ctx.fillRect(62, 0, 12, 256);
    ctx.fillRect(182, 0, 12, 256);
    ctx.fillRect(0, 206, 256, 24);
  }

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

  const matSkin = new THREE.MeshStandardMaterial({ color: c.skin, roughness: 0.42, metalness: 0.05 });
  const matHair = new THREE.MeshStandardMaterial({ color: c.hair, roughness: 0.38, metalness: 0.12 });
  const matCoat = new THREE.MeshStandardMaterial({ color: c.coat, roughness: 0.45, metalness: 0.22 });
  const matTrim = new THREE.MeshStandardMaterial({
    color: c.trim,
    roughness: 0.28,
    metalness: 0.68,
    emissive: c.trim,
    emissiveIntensity: 0.18
  });
  const matPants = new THREE.MeshStandardMaterial({ color: c.pants, roughness: 0.58 });
  const matWeapon = new THREE.MeshStandardMaterial({
    color: c.weaponColor,
    roughness: 0.25,
    metalness: 0.78,
    emissive: c.weaponColor,
    emissiveIntensity: 0.25
  });

  const faceTex = makeFaceTexture(c.skin, c.hair, hero.id);
  const headMaterials = [
    matSkin, matSkin, matSkin, matSkin,
    new THREE.MeshStandardMaterial({ map: faceTex, roughness: 0.42 }),
    matSkin
  ];

  const torsoTex = makeTorsoTexture(hero, c);
  const torsoMaterials = [
    matCoat, matCoat, matCoat, matCoat,
    new THREE.MeshStandardMaterial({ map: torsoTex, roughness: 0.45 }),
    matCoat
  ];

  // Legs (pivoted at hip y = 1.0)
  const leftLegPivot = new THREE.Group();
  leftLegPivot.position.set(-0.27, 1.0, 0);
  const leftLeg = new THREE.Mesh(new THREE.BoxGeometry(0.47, 1.0, 0.47), matPants);
  leftLeg.position.y = -0.5;
  leftLeg.castShadow = true;
  leftLegPivot.add(leftLeg);

  const leftBoot = new THREE.Mesh(new THREE.BoxGeometry(0.51, 0.3, 0.53), matCoat);
  leftBoot.position.set(0, -0.86, 0.02);
  leftLegPivot.add(leftBoot);
  const leftSole = new THREE.Mesh(new THREE.BoxGeometry(0.53, 0.1, 0.55), matTrim);
  leftSole.position.set(0, -0.98, 0.02);
  leftLegPivot.add(leftSole);
  root.add(leftLegPivot);

  const rightLegPivot = new THREE.Group();
  rightLegPivot.position.set(0.27, 1.0, 0);
  const rightLeg = new THREE.Mesh(new THREE.BoxGeometry(0.47, 1.0, 0.47), matPants);
  rightLeg.position.y = -0.5;
  rightLeg.castShadow = true;
  rightLegPivot.add(rightLeg);

  const rightBoot = new THREE.Mesh(new THREE.BoxGeometry(0.51, 0.3, 0.53), matCoat);
  rightBoot.position.set(0, -0.86, 0.02);
  rightLegPivot.add(rightBoot);
  const rightSole = new THREE.Mesh(new THREE.BoxGeometry(0.53, 0.1, 0.55), matTrim);
  rightSole.position.set(0, -0.98, 0.02);
  rightLegPivot.add(rightSole);
  root.add(rightLegPivot);

  // Torso (R6 Blocky Chest + Custom Corset/Armor Texture)
  const torsoGroup = new THREE.Group();
  torsoGroup.position.set(0, 1.55, 0);
  const torsoMesh = new THREE.Mesh(new THREE.BoxGeometry(1.06, 1.1, 0.54), torsoMaterials);
  torsoMesh.castShadow = true;
  torsoGroup.add(torsoMesh);

  // Collar / Shoulder pauldrons
  const collarL = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.22, 0.62), matCoat);
  collarL.position.set(-0.36, 0.48, 0.02);
  torsoGroup.add(collarL);
  const collarR = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.22, 0.62), matCoat);
  collarR.position.set(0.36, 0.48, 0.02);
  torsoGroup.add(collarR);

  // Coattails / Cape for Yu Zong, Esteez, Kajee, Laylul
  if (hero.id === 'laylul' || hero.id === 'yuzong' || hero.id === 'esteez' || hero.id === 'kajee') {
    const cape = new THREE.Mesh(new THREE.BoxGeometry(1.12, 1.35, 0.12), matCoat);
    cape.position.set(0, -0.45, -0.32);
    cape.rotation.x = 0.12;
    torsoGroup.add(cape);
  }

  root.add(torsoGroup);

  // Head
  const headGroup = new THREE.Group();
  headGroup.position.set(0, 2.52, 0);
  const headMesh = new THREE.Mesh(new THREE.BoxGeometry(0.86, 0.86, 0.86), headMaterials);
  headMesh.castShadow = true;
  headGroup.add(headMesh);

  // Sculpted Hair Cap & Side Locks (matching 0:00 Laylul's parted bangs & side hair!)
  const hairTop = new THREE.Mesh(new THREE.BoxGeometry(0.96, 0.3, 0.96), matHair);
  hairTop.position.set(0, 0.38, 0);
  headGroup.add(hairTop);

  const hairBack = new THREE.Mesh(new THREE.BoxGeometry(0.94, 0.84, 0.24), matHair);
  hairBack.position.set(0, 0.04, -0.38);
  headGroup.add(hairBack);

  // Side face-framing hair locks
  [-0.44, 0.44].forEach((sx) => {
    const sideLock = new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.78, 0.32), matHair);
    sideLock.position.set(sx, -0.04, 0.28);
    headGroup.add(sideLock);
  });

  // Front parted bangs
  const bangL = new THREE.Mesh(new THREE.BoxGeometry(0.42, 0.24, 0.18), matHair);
  bangL.position.set(-0.24, 0.28, 0.43);
  bangL.rotation.z = 0.18;
  headGroup.add(bangL);

  const bangR = new THREE.Mesh(new THREE.BoxGeometry(0.42, 0.24, 0.18), matHair);
  bangR.position.set(0.24, 0.28, 0.43);
  bangR.rotation.z = -0.18;
  headGroup.add(bangR);

  let leftTailGroup = null;
  let rightTailGroup = null;

  if (c.hairStyle === 'twintails') {
    // Laylul's iconic massive curving floor-length golden twintails + blue ribbon bows (0:00 in Reel!)
    const bowMat = new THREE.MeshStandardMaterial({ color: '#0284c7', roughness: 0.3 });
    [-1, 1].forEach((dir) => {
      const bow = new THREE.Mesh(new THREE.BoxGeometry(0.32, 0.28, 0.32), bowMat);
      bow.position.set(dir * 0.56, 0.34, -0.05);
      bow.rotation.z = dir * 0.25;
      headGroup.add(bow);

      const tGroup = new THREE.Group();
      tGroup.position.set(dir * 0.64, 0.32, -0.08);
      tGroup.rotation.z = dir * -0.18;

      const seg1 = new THREE.Mesh(new THREE.BoxGeometry(0.36, 0.95, 0.36), matHair);
      seg1.position.set(dir * 0.08, -0.42, 0);
      seg1.castShadow = true;
      tGroup.add(seg1);

      const seg2 = new THREE.Mesh(new THREE.BoxGeometry(0.42, 1.15, 0.42), matHair);
      seg2.position.set(dir * 0.2, -1.35, 0.05);
      seg2.rotation.z = dir * 0.08;
      seg2.castShadow = true;
      tGroup.add(seg2);

      const seg3 = new THREE.Mesh(new THREE.BoxGeometry(0.34, 0.9, 0.34), matHair);
      seg3.position.set(dir * 0.26, -2.22, 0.12);
      seg3.rotation.z = dir * 0.15;
      seg3.castShadow = true;
      tGroup.add(seg3);

      headGroup.add(tGroup);
      if (dir < 0) leftTailGroup = tGroup;
      else rightTailGroup = tGroup;
    });
  } else if (c.hairStyle === 'horns' || c.hairStyle === 'bull_horns') {
    const hornLen = c.hairStyle === 'bull_horns' ? 0.72 : 0.58;
    [-0.46, 0.46].forEach((hx) => {
      const horn = new THREE.Mesh(new THREE.BoxGeometry(0.2, hornLen, 0.2), matTrim);
      horn.position.set(hx, 0.55, 0.05);
      horn.rotation.z = hx < 0 ? 0.38 : -0.38;
      headGroup.add(horn);
    });
  } else if (c.hairStyle === 'cyber_helm' || c.hairStyle === 'goggles_helm') {
    // Sabro's full cyber samurai helmet with red central crest and glowing visor (0:15 left card!)
    const visor = new THREE.Mesh(
      new THREE.BoxGeometry(0.92, 0.24, 0.92),
      new THREE.MeshStandardMaterial({ color: c.trim, emissive: c.trim, emissiveIntensity: 0.95 })
    );
    visor.position.set(0, 0.08, 0.04);
    headGroup.add(visor);

    const crest = new THREE.Mesh(new THREE.BoxGeometry(0.16, 0.48, 0.65), matTrim);
    crest.position.set(0, 0.56, 0.1);
    headGroup.add(crest);
  } else if (c.hairStyle === 'elf_crown' || c.hairStyle === 'bird_crest') {
    const crown = new THREE.Mesh(new THREE.BoxGeometry(0.72, 0.38, 0.22), matTrim);
    crown.position.set(0, 0.56, 0.38);
    headGroup.add(crown);
  }

  root.add(headGroup);

  // Arms (pivoted at shoulder y = 2.0) with layered jacket sleeves & cuffs
  const buildArm = (xOffset) => {
    const pivot = new THREE.Group();
    pivot.position.set(xOffset, 2.0, 0);

    const sleeve = new THREE.Mesh(new THREE.BoxGeometry(0.52, 0.68, 0.54), matCoat);
    sleeve.position.y = -0.26;
    sleeve.castShadow = true;
    pivot.add(sleeve);

    const cuff = new THREE.Mesh(new THREE.BoxGeometry(0.54, 0.14, 0.56), matTrim);
    cuff.position.y = -0.58;
    pivot.add(cuff);

    const hand = new THREE.Mesh(new THREE.BoxGeometry(0.42, 0.45, 0.42), matSkin);
    hand.position.y = -0.82;
    hand.castShadow = true;
    pivot.add(hand);

    return pivot;
  };

  const leftArmPivot = buildArm(-0.8);
  const rightArmPivot = buildArm(0.8);
  root.add(leftArmPivot, rightArmPivot);

  // Signature Weapons
  const weaponGroup = new THREE.Group();
  weaponGroup.position.set(0, -0.92, 0.35);

  if (c.weapon === 'cannon' || c.weapon === 'splat_gun') {
    const barrel = new THREE.Mesh(new THREE.BoxGeometry(0.44, 0.44, 1.65), matWeapon);
    barrel.position.set(0, 0, 0.5);
    weaponGroup.add(barrel);
    const core = new THREE.Mesh(
      new THREE.BoxGeometry(0.54, 0.54, 0.48),
      new THREE.MeshStandardMaterial({ color: c.trim, emissive: c.trim, emissiveIntensity: 0.7 })
    );
    core.position.set(0, 0, 0.12);
    weaponGroup.add(core);
    rightArmPivot.rotation.x = -0.55;
  } else if (c.weapon === 'giant_hammer') {
    const shaft = new THREE.Mesh(new THREE.BoxGeometry(0.18, 0.18, 1.8), matCoat);
    shaft.position.set(0, 0, 0.48);
    weaponGroup.add(shaft);
    const head = new THREE.Mesh(new THREE.BoxGeometry(1.05, 0.7, 0.7), matWeapon);
    head.position.set(0, 0, 1.25);
    weaponGroup.add(head);
    rightArmPivot.rotation.x = -0.45;
  } else if (c.weapon === 'dual_blades' || c.weapon === 'katana' || c.weapon === 'greatsword') {
    const bladeW = c.weapon === 'greatsword' ? 0.3 : 0.14;
    const bladeL = c.weapon === 'greatsword' ? 1.95 : 1.55;
    const blade = new THREE.Mesh(new THREE.BoxGeometry(bladeW, 0.08, bladeL), matWeapon);
    blade.position.set(0, 0, bladeL * 0.48);
    weaponGroup.add(blade);
    if (c.weapon === 'dual_blades') {
      const leftBlade = blade.clone();
      leftBlade.position.set(0, -0.92, 0.72);
      leftArmPivot.add(leftBlade);
    }
  } else {
    const orb = new THREE.Mesh(new THREE.OctahedronGeometry(0.35, 0), matWeapon);
    orb.position.set(0, 0, 0.48);
    weaponGroup.add(orb);
  }

  rightArmPivot.add(weaponGroup);

  root.userData = {
    leftLegPivot,
    rightLegPivot,
    leftArmPivot,
    rightArmPivot,
    headGroup,
    torsoGroup,
    weaponGroup,
    leftTailGroup,
    rightTailGroup,
    walkPhase: Math.random() * Math.PI * 2,
    attackTimer: 0
  };

  return root;
}

function animateRobloxCharacter(mesh, dt, isMoving, isAttacking) {
  if (!mesh || !mesh.userData) return;
  const u = mesh.userData;
  u.walkPhase += dt * (isMoving ? 12.0 : 2.6);

  if (isMoving) {
    const swing = Math.sin(u.walkPhase) * 0.68;
    u.leftLegPivot.rotation.x = swing;
    u.rightLegPivot.rotation.x = -swing;
    u.leftArmPivot.rotation.x = -swing * 0.8;
    if (u.attackTimer <= 0) {
      u.rightArmPivot.rotation.x = -0.45 + swing * 0.45;
    }
    const bounce = Math.abs(Math.cos(u.walkPhase)) * 0.08;
    u.torsoGroup.position.y = 1.55 + bounce;
    u.headGroup.position.y = 2.52 + bounce;
    u.torsoGroup.rotation.z = Math.sin(u.walkPhase) * 0.05;

    if (u.leftTailGroup && u.rightTailGroup) {
      u.leftTailGroup.rotation.x = 0.25 + Math.sin(u.walkPhase * 2) * 0.14;
      u.rightTailGroup.rotation.x = 0.25 + Math.cos(u.walkPhase * 2) * 0.14;
    }
  } else {
    const idleBob = Math.sin(u.walkPhase) * 0.045;
    u.leftLegPivot.rotation.x *= 0.84;
    u.rightLegPivot.rotation.x *= 0.84;
    u.leftArmPivot.rotation.x = idleBob * 1.4;
    if (u.attackTimer <= 0) {
      u.rightArmPivot.rotation.x = -0.35 + idleBob;
    }
    u.torsoGroup.position.y = 1.55 + idleBob;
    u.headGroup.position.y = 2.52 + idleBob;
    u.torsoGroup.rotation.z *= 0.85;

    if (u.leftTailGroup && u.rightTailGroup) {
      u.leftTailGroup.rotation.z = 0.18 + Math.sin(u.walkPhase) * 0.05;
      u.rightTailGroup.rotation.z = -0.18 - Math.sin(u.walkPhase) * 0.05;
      u.leftTailGroup.rotation.x *= 0.85;
      u.rightTailGroup.rotation.x *= 0.85;
    }
  }

  if (isAttacking) {
    u.attackTimer = 0.26;
  }
  if (u.attackTimer > 0) {
    u.attackTimer -= dt;
    const slashProgress = (0.26 - u.attackTimer) / 0.26;
    u.rightArmPivot.rotation.x = -1.45 + Math.sin(slashProgress * Math.PI * 2) * 0.75;
    u.torsoGroup.rotation.y = Math.sin(slashProgress * Math.PI) * 0.28;
  } else {
    u.torsoGroup.rotation.y *= 0.85;
  }
}

function renderPortraitDataURL(hero, skinOverride = null) {
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

  // Twintails if Laylul
  if (c.hairStyle === 'twintails') {
    ctx.fillStyle = c.hair;
    ctx.fillRect(14, 48, 28, 145);
    ctx.fillRect(138, 48, 28, 145);
    ctx.fillStyle = '#0284c7';
    ctx.fillRect(26, 40, 20, 16);
    ctx.fillRect(134, 40, 20, 16);
  }

  // Shoulders / Coat
  ctx.fillStyle = c.coat;
  ctx.fillRect(28, 118, 124, 82);
  ctx.fillStyle = c.torso;
  ctx.fillRect(58, 118, 64, 82);
  ctx.fillStyle = c.trim;
  ctx.fillRect(50, 118, 10, 82);
  ctx.fillRect(120, 118, 10, 82);

  // Head block
  ctx.fillStyle = c.skin;
  ctx.fillRect(50, 42, 80, 74);

  // Hair cap
  ctx.fillStyle = c.hair;
  ctx.fillRect(46, 26, 88, 26);

  if (c.hairStyle === 'horns' || c.hairStyle === 'bull_horns') {
    ctx.fillStyle = c.trim;
    ctx.fillRect(36, 10, 16, 28);
    ctx.fillRect(128, 10, 16, 28);
  } else if (c.hairStyle === 'cyber_helm' || c.hairStyle === 'goggles_helm') {
    ctx.fillStyle = c.trim;
    ctx.fillRect(48, 66, 84, 18);
  }

  // Anime Eyes
  if (hero.id === 'yuzong') {
    ctx.fillStyle = '#e11d48';
    ctx.fillRect(58, 72, 22, 10);
    ctx.fillRect(100, 72, 22, 10);
  } else {
    ctx.fillStyle = '#0f172a';
    ctx.fillRect(62, 68, 16, 18);
    ctx.fillRect(102, 68, 16, 18);
    ctx.fillStyle = '#38bdf8';
    ctx.fillRect(64, 72, 12, 12);
    ctx.fillRect(104, 72, 12, 12);
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(64, 70, 5, 5);
    ctx.fillRect(104, 70, 5, 5);
  }

  // Smile
  ctx.strokeStyle = '#7c2d12';
  ctx.lineWidth = 3.5;
  ctx.beginPath();
  ctx.arc(90, 98, 8, 0.15 * Math.PI, 0.85 * Math.PI);
  ctx.stroke();

  return canvas.toDataURL();
}

window.ROBLOX_BUILDER = {
  buildRobloxHeroMesh,
  animateRobloxCharacter,
  renderPortraitDataURL
};
