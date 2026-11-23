class ArenaBattleEngine {
  constructor(canvas, callbacks) {
    this.canvas = canvas;
    this.cb = callbacks || {};
    this.running = false;

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x0b172a);
    this.scene.fog = new THREE.FogExp2(0x0b172a, 0.007);

    this.camera = new THREE.PerspectiveCamera(42, window.innerWidth / window.innerHeight, 0.5, 220);
    this.renderer = new THREE.WebGLRenderer({ canvas: this.canvas, antialias: true });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;

    // Lobby Scene setup
    this.lobbyScene = new THREE.Scene();
    this.lobbyScene.background = new THREE.Color(0x09142b);
    this.lobbyCamera = new THREE.PerspectiveCamera(35, window.innerWidth / window.innerHeight, 0.5, 100);
    this.lobbyCamera.position.set(0, 2.35, 5.2);
    this.lobbyCamera.lookAt(0, 1.85, 0);

    this.setupLobbyEnvironment();
    this.setupBattleLights();

    this.entities = [];
    this.projectiles = [];
    this.vfx = [];
    this.bushes = [];
    this.obstacles = [];
    this.minions = [];
    this.creeps = [];
    this.turrets = [];

    this.player = null;
    this.matchTime = 38; // Starts at 00:38 just like the Reel!
    this.blueKills = 0;
    this.redKills = 1;
    this.minionWaveTimer = 4;

    this.firstBloodTaken = false;
    this.shakeTimer = 0;
    this.shakeIntensity = 0;

    this.keys = {};
    this.joyVec = { x: 0, y: 0 };
    this.holdingAttack = false;
    this.lockedTarget = null;

    // Target Lock Ring Mesh on ground
    const lockGeo = new THREE.RingGeometry(1.18, 1.38, 32);
    const lockMat = new THREE.MeshBasicMaterial({
      color: 0xef4444,
      side: THREE.DoubleSide,
      transparent: true,
      opacity: 0.85
    });
    this.targetLockRing = new THREE.Mesh(lockGeo, lockMat);
    this.targetLockRing.rotation.x = -Math.PI / 2;
    this.targetLockRing.position.y = 0.08;
    this.targetLockRing.visible = false;

    window.addEventListener('resize', () => this.onResize());
    window.addEventListener('keydown', (e) => {
      this.keys[e.code] = true;
      if (this.running) this.handleKeyShortcuts(e.code);
    });
    window.addEventListener('keyup', (e) => {
      this.keys[e.code] = false;
    });

    this.lastTime = performance.now();
    this.mode = 'LOBBY'; // 'LOBBY' | 'BATTLE'
    this.animateLoop();
  }

  onResize() {
    const w = window.innerWidth;
    const h = window.innerHeight;
    this.camera.aspect = w / h;
    this.camera.updateProjectionMatrix();
    this.lobbyCamera.aspect = w / h;
    this.lobbyCamera.updateProjectionMatrix();
    this.renderer.setSize(w, h);
  }

  triggerScreenShake(intensity = 0.4, duration = 0.28) {
    this.shakeIntensity = Math.max(this.shakeIntensity, intensity);
    this.shakeTimer = Math.max(this.shakeTimer, duration);
  }

  setupLobbyEnvironment() {
    const amb = new THREE.AmbientLight(0xdbeafe, 0.88);
    this.lobbyScene.add(amb);

    const keyLight = new THREE.DirectionalLight(0xfffbeb, 1.3);
    keyLight.position.set(4, 8, 6);
    keyLight.castShadow = true;
    this.lobbyScene.add(keyLight);

    const rimLight = new THREE.PointLight(0x38bdf8, 1.6, 16);
    rimLight.position.set(-3, 4, -2);
    this.lobbyScene.add(rimLight);

    // Pedestal platform matching 0:00 in the video
    const pedGroup = new THREE.Group();
    const baseCyl = new THREE.Mesh(
      new THREE.CylinderGeometry(1.75, 2.05, 0.35, 32),
      new THREE.MeshStandardMaterial({ color: 0x1e293b, metalness: 0.6, roughness: 0.3 })
    );
    baseCyl.position.y = -0.18;
    pedGroup.add(baseCyl);

    const goldRing = new THREE.Mesh(
      new THREE.TorusGeometry(1.78, 0.06, 12, 48),
      new THREE.MeshStandardMaterial({ color: 0xfacc15, emissive: 0xd97706, emissiveIntensity: 0.5 })
    );
    goldRing.rotation.x = Math.PI / 2;
    goldRing.position.y = 0.01;
    pedGroup.add(goldRing);

    const innerRing = new THREE.Mesh(
      new THREE.RingGeometry(1.1, 1.55, 32),
      new THREE.MeshBasicMaterial({ color: 0x38bdf8, side: THREE.DoubleSide, transparent: true, opacity: 0.35 })
    );
    innerRing.rotation.x = -Math.PI / 2;
    innerRing.position.y = 0.02;
    pedGroup.add(innerRing);

    // Night moon & banners in background
    const moon = new THREE.Mesh(
      new THREE.SphereGeometry(1.4, 24, 24),
      new THREE.MeshBasicMaterial({ color: 0xe2e8f0 })
    );
    moon.position.set(2.4, 3.8, -6.5);
    this.lobbyScene.add(moon);

    // Blue & Gold hanging royal banners (seen at 0:00 top-right behind Laylul)
    [-3.2, 1.2, 3.6].forEach((bx, idx) => {
      const banner = new THREE.Mesh(
        new THREE.BoxGeometry(1.1, 3.4, 0.08),
        new THREE.MeshStandardMaterial({ color: 0x1d4ed8, roughness: 0.6 })
      );
      banner.position.set(bx, 3.3, -4.5 - (idx % 2) * 0.5);
      const border = new THREE.Mesh(
        new THREE.BoxGeometry(1.18, 3.46, 0.05),
        new THREE.MeshStandardMaterial({ color: 0xf59e0b, metalness: 0.5 })
      );
      border.position.copy(banner.position);
      border.position.z -= 0.03;
      this.lobbyScene.add(banner, border);
    });

    this.lobbyScene.add(pedGroup);
    this.lobbyPedestal = pedGroup;
    this.lobbyHeroMesh = null;
  }

  setLobbyHero(hero, skinOverride = null) {
    if (this.lobbyHeroMesh) {
      this.lobbyScene.remove(this.lobbyHeroMesh);
    }
    this.lobbyHeroMesh = window.ROBLOX_BUILDER.buildRobloxHeroMesh(hero, skinOverride);
    this.lobbyHeroMesh.position.set(-0.25, 0, 0);
    this.lobbyHeroMesh.rotation.y = 0.18;
    this.lobbyScene.add(this.lobbyHeroMesh);
  }

  setupBattleLights() {
    const amb = new THREE.AmbientLight(0xe0f2fe, 0.82);
    this.scene.add(amb);

    const sun = new THREE.DirectionalLight(0xfffbeb, 1.22);
    sun.position.set(24, 48, 22);
    sun.castShadow = true;
    sun.shadow.mapSize.width = 2048;
    sun.shadow.mapSize.height = 2048;
    sun.shadow.camera.near = 5;
    sun.shadow.camera.far = 140;
    const d = 48;
    sun.shadow.camera.left = -d;
    sun.shadow.camera.right = d;
    sun.shadow.camera.top = d;
    sun.shadow.camera.bottom = -d;
    this.scene.add(sun);
  }

  makeProceduralTerrainTexture(baseHex, noiseHex1, noiseHex2, isBrick = false) {
    const canvas = document.createElement('canvas');
    canvas.width = 256;
    canvas.height = 256;
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = baseHex;
    ctx.fillRect(0, 0, 256, 256);

    if (isBrick) {
      ctx.strokeStyle = noiseHex1;
      ctx.lineWidth = 3;
      for (let y = 0; y < 256; y += 32) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(256, y);
        ctx.stroke();
        const offset = (y / 32) % 2 === 0 ? 0 : 32;
        for (let x = offset; x < 256; x += 64) {
          ctx.beginPath();
          ctx.moveTo(x, y);
          ctx.lineTo(x, y + 32);
          ctx.stroke();
        }
      }
    } else {
      for (let i = 0; i < 650; i++) {
        ctx.fillStyle = i % 2 === 0 ? noiseHex1 : noiseHex2;
        const x = Math.random() * 256;
        const y = Math.random() * 256;
        const s = 3 + Math.random() * 7;
        ctx.fillRect(x, y, s, s);
      }
    }

    const tex = new THREE.CanvasTexture(canvas);
    tex.wrapS = THREE.RepeatWrapping;
    tex.wrapT = THREE.RepeatWrapping;
    tex.repeat.set(isBrick ? 6 : 18, isBrick ? 2 : 18);
    return tex;
  }

  buildArenaMap() {
    while (this.scene.children.length > 0) {
      this.scene.remove(this.scene.children[0]);
    }
    this.setupBattleLights();

    this.obstacles = [];
    this.bushes = [];
    this.turrets = [];
    this.creeps = [];
    this.minions = [];
    this.projectiles = [];
    this.vfx = [];

    const grassTex = this.makeProceduralTerrainTexture('#6ba656', '#76b55f', '#5d9449', false);
    const stoneTex = this.makeProceduralTerrainTexture('#9ca3af', '#8c939e', '#abb2bf', false);
    const brickTex = this.makeProceduralTerrainTexture('#d6d3d1', '#a8a29e', '#e7e5e4', true);

    // Main Lush Green Grass Floor (matches 0:17 - 0:34)
    const grassGeo = new THREE.PlaneGeometry(110, 110, 32, 32);
    const grassMat = new THREE.MeshStandardMaterial({ map: grassTex, roughness: 0.88, metalness: 0.02 });
    const grass = new THREE.Mesh(grassGeo, grassMat);
    grass.rotation.x = -Math.PI / 2;
    grass.receiveShadow = true;
    this.scene.add(grass);

    // Stone Lane Roads & Jungle Paths
    const stoneMat = new THREE.MeshStandardMaterial({ map: stoneTex, roughness: 0.78 });
    const laneMat = new THREE.MeshStandardMaterial({ color: 0xb4b8ab, roughness: 0.75 });

    const midLane = new THREE.Mesh(new THREE.BoxGeometry(10.5, 0.08, 92), laneMat);
    midLane.rotation.y = Math.PI / 4;
    midLane.position.y = 0.02;
    midLane.receiveShadow = true;
    this.scene.add(midLane);

    // White Brick Lane Borders (seen at 0:29 - 0:34)
    const wallBrickMat = new THREE.MeshStandardMaterial({ map: brickTex, roughness: 0.6 });
    const wallCapMat = new THREE.MeshStandardMaterial({ color: 0xa8a29e, roughness: 0.5 });

    const createBrickWall = (x, z, len, rotY) => {
      const wg = new THREE.Group();
      wg.position.set(x, 0, z);
      wg.rotation.y = rotY;
      const body = new THREE.Mesh(new THREE.BoxGeometry(len, 1.8, 1.4), wallBrickMat);
      body.position.y = 0.9;
      body.castShadow = true;
      body.receiveShadow = true;
      wg.add(body);
      const cap = new THREE.Mesh(new THREE.BoxGeometry(len + 0.3, 0.3, 1.65), wallCapMat);
      cap.position.y = 1.9;
      wg.add(cap);
      this.scene.add(wg);
    };

    createBrickWall(16, -18, 22, -Math.PI / 5);
    createBrickWall(-16, 18, 22, -Math.PI / 5);
    createBrickWall(0, -44, 70, 0);
    createBrickWall(0, 44, 70, 0);
    createBrickWall(-44, 0, 70, Math.PI / 2);
    createBrickWall(44, 0, 70, Math.PI / 2);

    // Circular Blue Water River Pool & Central Stone Island (exact match to 0:25 - 0:28!)
    const createRiverPool = (cx, cz, outerR, innerR) => {
      const waterMesh = new THREE.Mesh(
        new THREE.CylinderGeometry(outerR, outerR, 0.12, 40),
        new THREE.MeshStandardMaterial({
          color: 0x0ea5e9,
          emissive: 0x0284c7,
          emissiveIntensity: 0.25,
          roughness: 0.2,
          metalness: 0.15
        })
      );
      waterMesh.position.set(cx, 0.04, cz);
      this.scene.add(waterMesh);

      const foamRing = new THREE.Mesh(
        new THREE.RingGeometry(outerR - 0.35, outerR, 40),
        new THREE.MeshBasicMaterial({ color: 0x7dd3fc, side: THREE.DoubleSide })
      );
      foamRing.rotation.x = -Math.PI / 2;
      foamRing.position.set(cx, 0.11, cz);
      this.scene.add(foamRing);

      const island = new THREE.Mesh(
        new THREE.CylinderGeometry(innerR, innerR + 0.3, 0.25, 32),
        stoneMat
      );
      island.position.set(cx, 0.1, cz);
      island.receiveShadow = true;
      this.scene.add(island);
    };

    createRiverPool(-11, -9, 9.8, 5.6);
    createRiverPool(13, 11, 8.8, 4.8);

    // Blocky Gray Rock Wall Clusters (exact match to 0:17 - 0:22 & 0:30!)
    const rockMat = new THREE.MeshStandardMaterial({ color: 0x78716c, roughness: 0.85 });
    const darkRockMat = new THREE.MeshStandardMaterial({ color: 0x57534e, roughness: 0.9 });

    const createRockCluster = (cx, cz, radius = 3.2, count = 6) => {
      const group = new THREE.Group();
      group.position.set(cx, 0, cz);
      for (let i = 0; i < count; i++) {
        const ang = (i / count) * Math.PI * 2;
        const dist = (i === 0) ? 0 : radius * (0.45 + Math.random() * 0.4);
        const w = 1.6 + Math.random() * 1.4;
        const h = 1.8 + Math.random() * 1.8;
        const d = 1.6 + Math.random() * 1.4;
        const box = new THREE.Mesh(
          new THREE.BoxGeometry(w, h, d),
          i % 2 === 0 ? rockMat : darkRockMat
        );
        box.position.set(Math.cos(ang) * dist, h / 2, Math.sin(ang) * dist);
        box.rotation.y = Math.random() * Math.PI;
        box.castShadow = true;
        box.receiveShadow = true;
        group.add(box);
      }
      this.scene.add(group);
      this.obstacles.push({ x: cx, z: cz, r: radius * 0.85 });
    };

    createRockCluster(-8, 6, 3.2, 7);
    createRockCluster(7, -6, 3.2, 7);
    createRockCluster(-21, -2, 3.5, 8);
    createRockCluster(21, 2, 3.5, 8);
    createRockCluster(-4, -22, 3.2, 7);
    createRockCluster(4, 22, 3.2, 7);

    // Lush Teal-Green Spiky Bush Tuft Clusters (exact match to 0:18, 0:25, 0:31!)
    const bushMat = new THREE.MeshStandardMaterial({
      color: 0x2d8a6e,
      roughness: 0.65,
      flatShading: true
    });

    const createBushPatch = (bx, bz, radius = 3.2) => {
      const bushGroup = new THREE.Group();
      bushGroup.position.set(bx, 0, bz);
      for (let i = 0; i < 16; i++) {
        const cone = new THREE.Mesh(new THREE.ConeGeometry(0.78, 2.2, 5), bushMat.clone());
        const ang = (i / 16) * Math.PI * 2 + (i % 3) * 0.2;
        const rad = (i < 4) ? 0.5 : radius * 0.62;
        cone.position.set(Math.cos(ang) * rad, 0.98, Math.sin(ang) * rad);
        cone.rotation.x = (Math.random() - 0.5) * 0.48;
        cone.rotation.z = (Math.random() - 0.5) * 0.48;
        cone.castShadow = true;
        bushGroup.add(cone);
      }
      this.scene.add(bushGroup);
      this.bushes.push({ x: bx, z: bz, r: radius, mesh: bushGroup });
    };

    createBushPatch(-4.5, 2.5, 3.1);
    createBushPatch(4.5, -2.5, 3.1);
    createBushPatch(-11, -3.2, 3.0);
    createBushPatch(-11, -14.8, 3.0);
    createBushPatch(11, 4.2, 3.0);
    createBushPatch(13, -13, 3.2);
    createBushPatch(-15, 14, 3.2);

    // Blue & Red Team Turrets + Nexuses
    const createTurret = (tx, tz, team, isNexus = false) => {
      const g = new THREE.Group();
      g.position.set(tx, 0, tz);
      const color = team === 'blue' ? 0x3b82f6 : 0xef4444;

      const base = new THREE.Mesh(
        new THREE.CylinderGeometry(isNexus ? 2.8 : 1.6, isNexus ? 3.2 : 2.0, 0.8, 8),
        new THREE.MeshStandardMaterial({ color: 0x334155, roughness: 0.6 })
      );
      base.position.y = 0.4;
      g.add(base);

      const pillar = new THREE.Mesh(
        new THREE.BoxGeometry(isNexus ? 2.2 : 1.3, isNexus ? 4.2 : 3.2, isNexus ? 2.2 : 1.3),
        new THREE.MeshStandardMaterial({ color: 0xcbd5e1, roughness: 0.5 })
      );
      pillar.position.y = isNexus ? 2.4 : 1.9;
      pillar.castShadow = true;
      g.add(pillar);

      const crystal = new THREE.Mesh(
        new THREE.OctahedronGeometry(isNexus ? 1.25 : 0.78, 0),
        new THREE.MeshStandardMaterial({ color, emissive: color, emissiveIntensity: 0.85 })
      );
      crystal.position.y = isNexus ? 5.2 : 4.1;
      g.add(crystal);

      const rangeRing = new THREE.Mesh(
        new THREE.RingGeometry(8.3, 8.5, 36),
        new THREE.MeshBasicMaterial({
          color,
          side: THREE.DoubleSide,
          transparent: true,
          opacity: 0.22
        })
      );
      rangeRing.rotation.x = -Math.PI / 2;
      rangeRing.position.y = 0.06;
      g.add(rangeRing);

      this.scene.add(g);

      const turretObj = {
        id: `turret_${team}_${this.turrets.length}`,
        name: isNexus ? `${team.toUpperCase()} Base` : `${team.toUpperCase()} Turret`,
        isTurret: true,
        isNexus,
        team,
        x: tx,
        z: tz,
        r: isNexus ? 2.6 : 1.7,
        hp: isNexus ? 6500 : 3400,
        maxHp: isNexus ? 6500 : 3400,
        atk: isNexus ? 210 : 165,
        range: 9.0,
        atkCd: 0,
        mesh: g,
        crystal,
        dead: false
      };
      this.turrets.push(turretObj);
    };

    createTurret(-32, 32, 'blue', true);
    createTurret(-18, 18, 'blue', false);
    createTurret(-28, 10, 'blue', false);
    createTurret(-10, 28, 'blue', false);

    createTurret(32, -32, 'red', true);
    createTurret(18, -18, 'red', false);
    createTurret(28, -10, 'red', false);
    createTurret(10, -28, 'red', false);

    // Jungle Creep Monster Camps (seen at 0:17 - 0:21 in the Reel!)
    this.spawnJungleCreep(-10.5, 8.5, 'Crimson Buff Beast', 0xdc2626, 1.35);
    this.spawnJungleCreep(14, -4, 'Azure Golem', 0x2563eb, 1.35);
    this.spawnJungleCreep(-4, -14, 'River Crab', 0xf59e0b, 1.0);
    this.spawnJungleCreep(4, 14, 'Forest Boar', 0xd97706, 1.0);

    if (this.targetLockRing) {
      this.scene.add(this.targetLockRing);
    }
  }

  spawnJungleCreep(x, z, name, colorHex, scale = 1.0) {
    const g = new THREE.Group();
    g.position.set(x, 0, z);
    const bodyMat = new THREE.MeshStandardMaterial({ color: colorHex, roughness: 0.5 });
    const hornMat = new THREE.MeshStandardMaterial({ color: 0xfef08a, metalness: 0.4 });

    const body = new THREE.Mesh(new THREE.BoxGeometry(1.4 * scale, 1.2 * scale, 1.8 * scale), bodyMat);
    body.position.y = 0.8 * scale;
    body.castShadow = true;
    g.add(body);

    const head = new THREE.Mesh(new THREE.BoxGeometry(1.0 * scale, 0.9 * scale, 0.9 * scale), bodyMat);
    head.position.set(0, 1.2 * scale, 1.0 * scale);
    g.add(head);

    [-0.45, 0.45].forEach((hx) => {
      const spike = new THREE.Mesh(new THREE.ConeGeometry(0.22 * scale, 0.75 * scale, 5), hornMat);
      spike.position.set(hx * scale, 1.75 * scale, 0.95 * scale);
      spike.rotation.x = 0.4;
      g.add(spike);
    });

    this.scene.add(g);
    this.creeps.push({
      id: 'creep_' + Math.random().toString(36).slice(2, 7),
      name,
      team: 'neutral',
      isCreep: true,
      homeX: x,
      homeZ: z,
      x,
      z,
      r: 1.1 * scale,
      hp: Math.round(1450 * scale),
      maxHp: Math.round(1450 * scale),
      atk: Math.round(75 * scale),
      def: 12,
      spd: 3.4,
      range: 2.5,
      atkCd: 0,
      level: 4,
      mesh: g,
      dead: false,
      respawnTimer: 0
    });
  }

  startMatch(playerHero, selectedSkin, selectedBuild, blueRoster, redRoster) {
    this.mode = 'BATTLE';
    this.running = true;
    this.matchTime = 38;
    this.blueKills = 0;
    this.redKills = 1;
    this.firstBloodTaken = false;

    this.buildArenaMap();
    this.entities = [];

    blueRoster.forEach((slot, idx) => {
      const isPlayer = idx === 0;
      const spawnOffsets = [
        { x: -6.5, z: 6.5 },
        { x: -9.5, z: 8.0 }, // Jungler Yeen fighting the Crimson Buff Beast right next to player like 0:18!
        { x: -11, z: 15 },
        { x: -18, z: 8 },
        { x: -8, z: 18 }
      ];
      const pos = spawnOffsets[idx] || { x: -24, z: 24 };
      const ent = this.createHeroEntity(slot.hero, 'blue', slot.playerName, pos.x, pos.z, isPlayer, isPlayer ? selectedSkin : null, isPlayer ? selectedBuild : null);
      if (isPlayer) this.player = ent;
      this.entities.push(ent);
    });

    redRoster.forEach((slot, idx) => {
      const spawnOffsets = [
        { x: -0.5, z: -0.5 }, // Enemy Sabro right across the bush ready to be sniped by laser like 0:19!
        { x: 6.5, z: -5.5 },
        { x: 12, z: -11 },
        { x: 17, z: -7 },
        { x: 7, z: -17 }
      ];
      const pos = spawnOffsets[idx] || { x: 24, z: -24 };
      const ent = this.createHeroEntity(slot.hero, 'red', slot.playerName, pos.x, pos.z, false, null, null);
      if (idx === 0) {
        ent.hp = Math.round(ent.maxHp * 0.42);
      }
      this.entities.push(ent);
    });

    this.spawnMinionWave();

    // MLBB Welcome Announcer + BGM
    window.SFX.startBGM('BATTLE');
    setTimeout(() => {
      window.SFX.announce('Welcome to Mobile Blox Legends! Five seconds till the enemy reaches the battlefield. Smash them!', 0.85, 1.04);
    }, 350);
  }

  createHeroEntity(heroData, team, playerName, x, z, isPlayer, skinOverride, buildData) {
    const mesh = window.ROBLOX_BUILDER.buildRobloxHeroMesh(heroData, skinOverride);
    mesh.position.set(x, 0, z);
    this.scene.add(mesh);

    const ringColor = isPlayer ? 0xfacc15 : (team === 'blue' ? 0x38bdf8 : 0xef4444);
    const footRing = new THREE.Mesh(
      new THREE.RingGeometry(0.95, 1.18, 28),
      new THREE.MeshBasicMaterial({ color: ringColor, side: THREE.DoubleSide, transparent: true, opacity: 0.75 })
    );
    footRing.rotation.x = -Math.PI / 2;
    footRing.position.y = 0.05;
    mesh.add(footRing);

    // Floating Golden Ring for Sabro Orbiting Swords / Buff Aura (0:17 in Reel!)
    const auraRing = new THREE.Mesh(
      new THREE.TorusGeometry(1.55, 0.07, 10, 32),
      new THREE.MeshBasicMaterial({ color: 0xfacc15, transparent: true, opacity: 0.0 })
    );
    auraRing.rotation.x = Math.PI / 2;
    auraRing.position.y = 1.25;
    mesh.add(auraRing);

    const bBonus = buildData ? buildData.bonus : { atk: 20, crit: 0.15, atkSpd: 0.2, hp: 200, spd: 0.3 };
    const maxHp = heroData.stats.hp + (bBonus.hp || 0);

    return {
      id: `${team}_${heroData.id}_${Math.random().toString(36).slice(2, 6)}`,
      isHero: true,
      isPlayer,
      team,
      playerName,
      hero: heroData,
      x,
      z,
      vx: 0,
      vz: 0,
      rotY: team === 'blue' ? Math.PI * 0.75 : -Math.PI * 0.25,
      r: 0.9,
      level: 3,
      xp: 0,
      gold: 850,
      kills: 0,
      deaths: isPlayer ? 1 : 0,
      assists: 0,
      multiKillCount: 0,
      multiKillTimer: 0,
      killStreak: 0,
      hp: maxHp,
      maxHp,
      mana: heroData.stats.mana || 450,
      maxMana: heroData.stats.mana || 450,
      atk: heroData.stats.atk + (bBonus.atk || 0),
      def: heroData.stats.def,
      spd: heroData.stats.spd + (bBonus.spd || 0),
      range: heroData.stats.range,
      atkSpd: heroData.stats.atkSpd + (bBonus.atkSpd || 0),
      critChance: bBonus.crit || 0.15,
      atkCd: 0,
      cds: { 1: 0, 2: 0, 3: 0, recall: 0, regen: 0, spell: 0 },
      maxCds: {
        1: heroData.skills[1].cd,
        2: heroData.skills[2].cd,
        3: heroData.skills[3].cd,
        recall: 8,
        regen: 12,
        spell: buildData ? buildData.spell.cd : 30
      },
      stunTimer: 0,
      regenTimer: 0,
      recallTimer: 0,
      speedBuffTimer: 0,
      orbitTimer: heroData.id === 'sabro' ? 8.0 : 0,
      inBush: false,
      dead: false,
      respawnTimer: 0,
      auraRing,
      mesh
    };
  }

  spawnMinionWave() {
    const createMinion = (team, x, z, idx) => {
      const color = team === 'blue' ? 0x2563eb : 0xdc2626;
      const hatColor = team === 'blue' ? 0x93c5fd : 0xfca5a5;
      const g = new THREE.Group();
      g.position.set(x, 0, z);

      const body = new THREE.Mesh(
        new THREE.BoxGeometry(0.75, 0.95, 0.55),
        new THREE.MeshStandardMaterial({ color, roughness: 0.5 })
      );
      body.position.y = 0.65;
      body.castShadow = true;
      g.add(body);

      const head = new THREE.Mesh(
        new THREE.BoxGeometry(0.62, 0.62, 0.62),
        new THREE.MeshStandardMaterial({ color: 0xfde68a, roughness: 0.5 })
      );
      head.position.y = 1.45;
      g.add(head);

      const helm = new THREE.Mesh(
        new THREE.ConeGeometry(0.48, 0.45, 4),
        new THREE.MeshStandardMaterial({ color: hatColor })
      );
      helm.position.y = 1.9;
      g.add(helm);

      this.scene.add(g);
      this.minions.push({
        id: `minion_${team}_${Date.now()}_${idx}`,
        name: `${team === 'blue' ? 'Blue' : 'Red'} Minion`,
        isMinion: true,
        team,
        x,
        z,
        r: 0.6,
        hp: 620,
        maxHp: 620,
        atk: 46,
        def: 6,
        spd: 4.1,
        range: idx === 2 ? 6.0 : 2.3,
        atkCd: 0,
        level: 1,
        mesh: g,
        dead: false
      });
    };

    for (let i = 0; i < 3; i++) {
      createMinion('blue', -14 - i * 1.8, 14 + i * 1.8, i);
      createMinion('red', 14 + i * 1.8, -14 - i * 1.8, i);
    }
  }

  handleKeyShortcuts(code) {
    if (!this.player || this.player.dead) return;
    if (code === 'Space') this.triggerBasicAttack(this.player);
    if (code === 'Digit1' || code === 'KeyQ') this.triggerSkill(this.player, 1);
    if (code === 'Digit2' || code === 'KeyE') this.triggerSkill(this.player, 2);
    if (code === 'Digit3' || code === 'KeyR') this.triggerSkill(this.player, 3);
    if (code === 'KeyB') this.triggerBattleAction(this.player, 'recall');
    if (code === 'KeyF') this.triggerBattleAction(this.player, 'regen');
    if (code === 'KeyG' || code === 'KeyD') this.triggerBattleAction(this.player, 'spell');
  }

  getValidTargets(source, maxRange = 999) {
    const list = [];
    const check = (t) => {
      if (!t || t.dead || t.team === source.team) return;
      const dx = t.x - source.x;
      const dz = t.z - source.z;
      const dist = Math.hypot(dx, dz);
      if (dist <= maxRange) list.push({ target: t, dist });
    };

    this.entities.forEach(check);
    this.minions.forEach(check);
    this.creeps.forEach(check);
    this.turrets.forEach(check);

    list.sort((a, b) => {
      const aHero = a.target.isHero ? 0 : 1;
      const bHero = b.target.isHero ? 0 : 1;
      if (aHero !== bHero) return aHero - bHero;
      return a.dist - b.dist;
    });
    return list;
  }

  triggerBasicAttack(ent) {
    if (!ent || ent.dead || ent.stunTimer > 0 || ent.atkCd > 0) return;
    ent.atkCd = 1 / ent.atkSpd;
    ent.recallTimer = 0;

    const candidates = this.getValidTargets(ent, ent.range + 0.8);
    let aimAngle = ent.rotY;
    const target = candidates.length > 0 ? candidates[0].target : null;

    if (target) {
      aimAngle = Math.atan2(target.x - ent.x, target.z - ent.z);
      ent.rotY = aimAngle;
      ent.mesh.rotation.y = aimAngle;
    }

    window.ROBLOX_BUILDER.animateRobloxCharacter(ent.mesh, 0.016, false, true);

    if (ent.range > 4.5) {
      if (ent.isPlayer) window.SFX.shoot();
      this.spawnProjectile({
        owner: ent,
        x: ent.x + Math.sin(aimAngle) * 0.8,
        z: ent.z + Math.cos(aimAngle) * 0.8,
        vx: Math.sin(aimAngle) * 26,
        vz: Math.cos(aimAngle) * 26,
        color: ent.hero.colors.aura,
        radius: 0.3,
        maxDist: ent.range + 1.5,
        dmg: ent.atk,
        target
      });
    } else {
      if (ent.isPlayer) window.SFX.slash();
      this.spawnSlashArc(ent.x + Math.sin(aimAngle) * 1.4, ent.z + Math.cos(aimAngle) * 1.4, aimAngle, ent.hero.colors.aura, 2.5);
      candidates.forEach((c) => {
        if (c.dist <= ent.range + 1.1) {
          this.applyDamage(ent, c.target, ent.atk, false);
        }
      });
    }
  }

  triggerSkill(ent, slot) {
    if (!ent || ent.dead || ent.stunTimer > 0) return;
    if (ent.cds[slot] > 0) return;

    const skill = ent.hero.skills[slot];
    if (!skill) return;
    if (ent.mana < (skill.mana || 0)) return;

    ent.mana = Math.max(0, ent.mana - (skill.mana || 0));
    ent.cds[slot] = skill.cd;
    ent.recallTimer = 0;

    const candidates = this.getValidTargets(ent, (skill.range || 8) + 2.5);
    let aimAngle = ent.rotY;
    const primary = candidates.length > 0 ? candidates[0].target : null;
    if (primary) {
      aimAngle = Math.atan2(primary.x - ent.x, primary.z - ent.z);
      ent.rotY = aimAngle;
      ent.mesh.rotation.y = aimAngle;
    }

    window.ROBLOX_BUILDER.animateRobloxCharacter(ent.mesh, 0.016, false, true);
    const totalDmg = Math.round((skill.dmg || 250) + ent.atk * (skill.ratio || 1.0));

    if (ent.isPlayer) {
      if (slot === 1) window.SFX.skill1();
      else if (slot === 2) window.SFX.skill2();
      else {
        window.SFX.ultimate();
        this.triggerScreenShake(0.45, 0.35);
      }
    }

    switch (skill.type) {
      case 'mega_laser': {
        const len = skill.range || 17;
        this.spawnLaserBeam(ent.x, ent.z, aimAngle, len, skill.color || '#22d3ee');
        const allEnemies = this.getValidTargets(ent, len + 1.5);
        allEnemies.forEach(({ target }) => {
          const toX = target.x - ent.x;
          const toZ = target.z - ent.z;
          const forward = toX * Math.sin(aimAngle) + toZ * Math.cos(aimAngle);
          const perp = Math.abs(toX * Math.cos(aimAngle) - toZ * Math.sin(aimAngle));
          if (forward > -0.5 && forward <= len + 1.0 && perp <= 2.45) {
            this.applyDamage(ent, target, totalDmg, true);
          }
        });
        break;
      }

      case 'stun_orb': {
        this.spawnProjectile({
          owner: ent,
          x: ent.x + Math.sin(aimAngle) * 0.9,
          z: ent.z + Math.cos(aimAngle) * 0.9,
          vx: Math.sin(aimAngle) * 21,
          vz: Math.cos(aimAngle) * 21,
          color: skill.color || '#a855f7',
          radius: 0.56,
          maxDist: skill.range || 10,
          dmg: totalDmg,
          stun: 1.4,
          aoeRadius: 2.8,
          target: primary
        });
        break;
      }

      case 'line_bolt': {
        ent.speedBuffTimer = 3.2;
        this.spawnProjectile({
          owner: ent,
          x: ent.x + Math.sin(aimAngle) * 0.9,
          z: ent.z + Math.cos(aimAngle) * 0.9,
          vx: Math.sin(aimAngle) * 27,
          vz: Math.cos(aimAngle) * 27,
          color: skill.color || '#facc15',
          radius: 0.46,
          maxDist: skill.range || 11.5,
          dmg: totalDmg,
          aoeRadius: 1.9
        });
        break;
      }

      case 'dash_slash': {
        const dashDist = 5.5;
        const startX = ent.x;
        const startZ = ent.z;
        ent.x = this.clampMap(ent.x + Math.sin(aimAngle) * dashDist);
        ent.z = this.clampMap(ent.z + Math.cos(aimAngle) * dashDist);
        this.spawnLaserBeam(startX, startZ, aimAngle, dashDist, skill.color || '#38bdf8', 0.25);
        this.getValidTargets(ent, 4.2).forEach(({ target }) => {
          this.applyDamage(ent, target, totalDmg, true);
        });
        break;
      }

      case 'orbit_blades': {
        ent.orbitTimer = 4.5;
        this.spawnRingExplosion(ent.x, ent.z, 4.5, skill.color || '#38bdf8');
        this.getValidTargets(ent, 5.2).forEach(({ target }) => {
          this.applyDamage(ent, target, totalDmg, true);
        });
        break;
      }

      case 'triple_sweep':
      case 'domain_barrage':
      case 'divine_chain': {
        if (primary) {
          ent.x = this.clampMap(primary.x - Math.sin(aimAngle) * 1.4);
          ent.z = this.clampMap(primary.z - Math.cos(aimAngle) * 1.4);
          primary.stunTimer = Math.max(primary.stunTimer || 0, 1.4);
          this.spawnRingExplosion(primary.x, primary.z, 4.2, skill.color || '#ef4444');
          this.applyDamage(ent, primary, totalDmg, true);
          if (this.cb.onFloatingText) {
            this.cb.onFloatingText(primary, 'STUNNED!', '#fde047');
          }
        } else {
          this.spawnRingExplosion(ent.x, ent.z, 5.0, skill.color || '#ef4444');
        }
        break;
      }

      case 'aoe_spin':
      case 'ring_pulse':
      case 'minoan_quake':
      case 'dragon_form': {
        const rad = skill.range || 6.0;
        this.spawnRingExplosion(ent.x, ent.z, rad, skill.color || '#e11d48');
        this.getValidTargets(ent, rad).forEach(({ target }) => {
          this.applyDamage(ent, target, totalDmg, true);
          if (skill.type === 'minoan_quake') {
            target.stunTimer = 1.4;
            if (this.cb.onFloatingText) this.cb.onFloatingText(target, 'AIRBORNE!', '#fb923c');
          }
        });
        this.healEntity(ent, Math.round(totalDmg * 0.35));
        break;
      }

      case 'leap_slam': {
        const jumpDist = Math.min(skill.range || 6.5, primary ? Math.hypot(primary.x - ent.x, primary.z - ent.z) : 5.0);
        ent.x = this.clampMap(ent.x + Math.sin(aimAngle) * jumpDist);
        ent.z = this.clampMap(ent.z + Math.cos(aimAngle) * jumpDist);
        this.spawnRingExplosion(ent.x, ent.z, 4.5, skill.color || '#f97316');
        this.getValidTargets(ent, 4.5).forEach(({ target }) => {
          target.stunTimer = 1.0;
          this.applyDamage(ent, target, totalDmg, true);
          if (this.cb.onFloatingText) this.cb.onFloatingText(target, 'STUNNED!', '#fde047');
        });
        break;
      }

      case 'team_heal': {
        this.spawnRingExplosion(ent.x, ent.z, 6.5, '#4ade80');
        this.entities.forEach((ally) => {
          if (!ally.dead && ally.team === ent.team && Math.hypot(ally.x - ent.x, ally.z - ent.z) <= 8.5) {
            this.healEntity(ally, totalDmg);
          }
        });
        break;
      }
    }
  }

  triggerBattleAction(ent, actionType) {
    if (!ent || ent.dead) return;
    if (ent.cds[actionType] > 0) return;

    if (actionType === 'recall') {
      ent.cds.recall = 8;
      ent.recallTimer = 3.0;
      this.spawnRingExplosion(ent.x, ent.z, 2.2, '#38bdf8');
      if (this.cb.onFloatingText) this.cb.onFloatingText(ent, 'RECALLING...', '#38bdf8');
    } else if (actionType === 'regen') {
      ent.cds.regen = 12;
      ent.regenTimer = 4.0;
      if (ent.isPlayer) window.SFX.confirm();
      this.spawnRingExplosion(ent.x, ent.z, 2.0, '#4ade80');
    } else if (actionType === 'spell') {
      ent.cds.spell = ent.maxCds.spell || 30;
      const blinkDist = 6.2;
      this.spawnRingExplosion(ent.x, ent.z, 1.8, '#38bdf8');
      ent.x = this.clampMap(ent.x + Math.sin(ent.rotY) * blinkDist);
      ent.z = this.clampMap(ent.z + Math.cos(ent.rotY) * blinkDist);
      this.spawnRingExplosion(ent.x, ent.z, 2.2, '#38bdf8');
      if (ent.isPlayer) window.SFX.skill1();
      if (this.cb.onFloatingText) this.cb.onFloatingText(ent, 'FLICKER!', '#38bdf8');
    }
  }

  healEntity(ent, amount) {
    if (!ent || ent.dead) return;
    ent.hp = Math.min(ent.maxHp, ent.hp + amount);
    if (this.cb.onFloatingText) {
      this.cb.onFloatingText(ent, `+${amount}`, '#4ade80');
    }
  }

  applyDamage(attacker, target, rawDmg, isSkill = false) {
    if (!target || target.dead) return;
    const def = target.def || 15;
    let dmg = Math.max(18, Math.round(rawDmg * (100 / (100 + def))));

    if (attacker && attacker.hero && attacker.hero.id === 'laylul') {
      const dist = Math.hypot(target.x - attacker.x, target.z - attacker.z);
      dmg = Math.round(dmg * (1 + Math.min(0.3, dist * 0.025)));
    }

    const isCrit = !isSkill && attacker && attacker.critChance && Math.random() < attacker.critChance;
    if (isCrit) dmg = Math.round(dmg * 1.75);

    target.hp = Math.max(0, target.hp - dmg);
    if (target.isHero) target.recallTimer = 0;

    if (attacker && attacker.isPlayer) {
      window.SFX.hit();
      this.spawnHitSpark(target.x, target.z, isCrit ? 0xfacc15 : 0x38bdf8);
    }

    if (this.cb.onFloatingText) {
      if ((attacker && attacker.isPlayer) || target.isPlayer || target.isHero) {
        this.cb.onFloatingText(target, `${isCrit ? '💥' : ''}${dmg}`, isCrit ? '#facc15' : '#ef4444');
      }
    }

    if (target.hp <= 0 && !target.dead) {
      this.handleDeath(attacker, target);
    }
  }

  handleDeath(killer, victim) {
    victim.dead = true;
    if (victim.mesh) victim.mesh.visible = false;

    this.spawnRingExplosion(victim.x, victim.z, 2.8, '#facc15');

    if (victim.isHero) {
      victim.deaths = (victim.deaths || 0) + 1;
      victim.killStreak = 0;
      victim.respawnTimer = 7 + victim.level;

      if (victim.team === 'red') this.blueKills++;
      else if (victim.team === 'blue') this.redKills++;

      let voiceCallout = '';

      if (killer && killer.isHero) {
        killer.kills = (killer.kills || 0) + 1;
        killer.killStreak = (killer.killStreak || 0) + 1;
        if (killer.multiKillTimer > 0) {
          killer.multiKillCount++;
        } else {
          killer.multiKillCount = 1;
        }
        killer.multiKillTimer = 12.0;

        this.grantGoldAndXp(killer, victim, 203, 130); // Exact +203 gold from 0:20 in the Reel!

        if (!this.firstBloodTaken) {
          this.firstBloodTaken = true;
          voiceCallout = 'First Blood!';
        } else if (killer.multiKillCount === 2) {
          voiceCallout = 'Double Kill!';
        } else if (killer.multiKillCount === 3) {
          voiceCallout = 'Triple Kill!';
        } else if (killer.multiKillCount === 4) {
          voiceCallout = 'Maniac!';
        } else if (killer.multiKillCount >= 5) {
          voiceCallout = 'Savage!';
        } else if (killer.killStreak === 3) {
          voiceCallout = 'Killing Spree!';
        } else if (killer.killStreak === 4) {
          voiceCallout = 'Mega Kill!';
        } else if (killer.killStreak === 5) {
          voiceCallout = 'Unstoppable!';
        } else if (killer.killStreak === 6) {
          voiceCallout = 'Monster Kill!';
        } else if (killer.killStreak >= 7) {
          voiceCallout = 'Legendary!';
        } else if (killer.team === 'blue') {
          voiceCallout = 'You have slain an enemy!';
        } else {
          voiceCallout = 'An ally has been slain!';
        }
      } else {
        voiceCallout = victim.team === 'red' ? 'An enemy has been slain!' : 'Executed!';
      }

      // Check Wipe Out (All 5 enemies dead simultaneously)
      const enemyTeam = victim.team;
      const allDead = this.entities.filter((e) => e.team === enemyTeam).every((e) => e.dead);
      if (allDead && enemyTeam === 'red') {
        voiceCallout = 'Wipe Out!';
      }

      this.entities.forEach((ally) => {
        if (!ally.dead && ally !== killer && ally.team !== victim.team) {
          if (Math.hypot(ally.x - victim.x, ally.z - victim.z) <= 14) {
            ally.assists = (ally.assists || 0) + 1;
            this.grantGoldAndXp(ally, victim, 85, 65);
          }
        }
      });

      if (this.cb.onHeroKill) {
        this.cb.onHeroKill(killer, victim, voiceCallout);
      }
      window.SFX.kill();
      this.triggerScreenShake(0.5, 0.35);
      if (voiceCallout) {
        window.SFX.announce(voiceCallout, 0.82, 1.05);
      }
    } else if (victim.isCreep || victim.isMinion) {
      const goldReward = victim.isCreep ? 363 : 58; // +363 gold when clearing jungle camp at 0:22 in the Reel!
      const xpReward = victim.isCreep ? 125 : 48;
      if (victim.isCreep) victim.respawnTimer = 18;
      if (killer && killer.isHero) {
        this.grantGoldAndXp(killer, victim, goldReward, xpReward);
      }
    } else if (victim.isTurret) {
      if (killer && killer.isHero) {
        this.grantGoldAndXp(killer, victim, 320, 180);
      }
      window.SFX.announce(
        victim.team === 'red' ? 'Your team destroyed a turret!' : 'Our turret has been destroyed!',
        0.85,
        1.04
      );
      if (victim.isNexus && this.cb.onMatchEnd) {
        const res = victim.team === 'red' ? 'VICTORY' : 'DEFEAT';
        window.SFX.announce(res === 'VICTORY' ? 'Victory!' : 'Defeat!', 0.85, 0.95);
        this.cb.onMatchEnd(res);
      }
    }
  }

  grantGoldAndXp(heroEnt, sourceTarget, goldAmount, xpAmount) {
    heroEnt.gold += goldAmount;
    heroEnt.xp += xpAmount;

    if (heroEnt.isPlayer) {
      window.SFX.gold();
      if (this.cb.onGoldPopup) {
        this.cb.onGoldPopup(sourceTarget || heroEnt, goldAmount);
      }
    }

    const neededXp = heroEnt.level * 100;
    if (heroEnt.xp >= neededXp && heroEnt.level < 15) {
      heroEnt.xp -= neededXp;
      heroEnt.level++;
      heroEnt.maxHp += 185;
      heroEnt.hp = Math.min(heroEnt.maxHp, heroEnt.hp + 320);
      heroEnt.atk += 14;
      heroEnt.def += 4;
      if (heroEnt.isPlayer) {
        window.SFX.levelUp();
        if (this.cb.onLevelUp) this.cb.onLevelUp(heroEnt.level);
      }
    }
  }

  spawnHitSpark(x, z, colorHex) {
    const geo = new THREE.OctahedronGeometry(0.42, 0);
    const mat = new THREE.MeshBasicMaterial({ color: colorHex, transparent: true, opacity: 0.9 });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.position.set(x, 1.4, z);
    this.scene.add(mesh);
    this.vfx.push({ mesh, timer: 0.16, maxTimer: 0.16, type: 'ring' });
  }

  spawnProjectile(opts) {
    const geo = new THREE.SphereGeometry(opts.radius || 0.3, 10, 10);
    const mat = new THREE.MeshBasicMaterial({ color: opts.color || '#38bdf8' });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.position.set(opts.x, 1.35, opts.z);
    this.scene.add(mesh);

    this.projectiles.push(Object.assign({}, opts, {
      mesh,
      traveled: 0
    }));
  }

  spawnLaserBeam(x, z, angle, length, colorHex, duration = 0.45) {
    const group = new THREE.Group();
    group.position.set(x, 1.35, z);
    group.rotation.y = angle;

    const coreGeo = new THREE.CylinderGeometry(0.45, 0.45, length, 12);
    coreGeo.rotateX(Math.PI / 2);
    coreGeo.translate(0, 0, length / 2);
    const coreMat = new THREE.MeshBasicMaterial({ color: 0xffffff });
    const core = new THREE.Mesh(coreGeo, coreMat);
    group.add(core);

    const glowGeo = new THREE.CylinderGeometry(1.05, 1.05, length, 12);
    glowGeo.rotateX(Math.PI / 2);
    glowGeo.translate(0, 0, length / 2);
    const glowMat = new THREE.MeshBasicMaterial({
      color: colorHex,
      transparent: true,
      opacity: 0.72
    });
    const glow = new THREE.Mesh(glowGeo, glowMat);
    group.add(glow);

    this.scene.add(group);
    this.vfx.push({ mesh: group, timer: duration, maxTimer: duration, type: 'laser' });
  }

  spawnSlashArc(x, z, angle, colorHex, radius = 2.2) {
    const geo = new THREE.RingGeometry(radius * 0.4, radius, 16, 1, -Math.PI * 0.45, Math.PI * 0.9);
    const mat = new THREE.MeshBasicMaterial({
      color: colorHex,
      side: THREE.DoubleSide,
      transparent: true,
      opacity: 0.85
    });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.rotation.x = -Math.PI / 2;
    mesh.rotation.z = -angle;
    mesh.position.set(x, 1.2, z);
    this.scene.add(mesh);
    this.vfx.push({ mesh, timer: 0.2, maxTimer: 0.2, type: 'slash' });
  }

  spawnRingExplosion(x, z, maxRadius, colorHex) {
    const geo = new THREE.RingGeometry(0.3, maxRadius, 32);
    const mat = new THREE.MeshBasicMaterial({
      color: colorHex,
      side: THREE.DoubleSide,
      transparent: true,
      opacity: 0.78
    });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.rotation.x = -Math.PI / 2;
    mesh.position.set(x, 0.14, z);
    mesh.scale.set(0.2, 0.2, 0.2);
    this.scene.add(mesh);
    this.vfx.push({ mesh, timer: 0.38, maxTimer: 0.38, type: 'ring' });
  }

  clampMap(val) {
    return Math.max(-41, Math.min(41, val));
  }

  resolveObstacleCollision(ent) {
    // Unit-to-Unit Smooth Separation (Prevents overlapping/clumping like in screenshot 1!)
    const allUnits = [...this.entities, ...this.minions, ...this.creeps];
    for (const other of allUnits) {
      if (!other || other === ent || other.dead) continue;
      const dx = ent.x - other.x;
      const dz = ent.z - other.z;
      const dist = Math.hypot(dx, dz);
      const minSep = (ent.r || 0.85) + (other.r || 0.85) * 0.82;
      if (dist < minSep && dist > 0.001) {
        const push = (minSep - dist) * 0.48;
        ent.x += (dx / dist) * push;
        ent.z += (dz / dist) * push;
      }
    }

    for (const obs of this.obstacles) {
      const dx = ent.x - obs.x;
      const dz = ent.z - obs.z;
      const dist = Math.hypot(dx, dz);
      const minDist = ent.r + obs.r;
      if (dist < minDist && dist > 0.001) {
        const push = (minDist - dist);
        ent.x += (dx / dist) * push;
        ent.z += (dz / dist) * push;
      }
    }
    ent.x = this.clampMap(ent.x);
    ent.z = this.clampMap(ent.z);
  }

  updateBattle(dt) {
    this.matchTime += dt;
    this.minionWaveTimer -= dt;
    if (this.minionWaveTimer <= 0) {
      this.minionWaveTimer = 22;
      this.spawnMinionWave();
    }

    for (const ent of this.entities) {
      if (ent.dead) {
        ent.respawnTimer -= dt;
        if (ent.respawnTimer <= 0) {
          ent.dead = false;
          ent.hp = ent.maxHp;
          ent.mana = ent.maxMana;
          ent.x = ent.team === 'blue' ? -28 : 28;
          ent.z = ent.team === 'blue' ? 28 : -28;
          ent.mesh.visible = true;
          this.spawnRingExplosion(ent.x, ent.z, 2.5, '#38bdf8');
        }
        continue;
      }

      if (ent.atkCd > 0) ent.atkCd = Math.max(0, ent.atkCd - dt);
      if (ent.multiKillTimer > 0) ent.multiKillTimer = Math.max(0, ent.multiKillTimer - dt);
      for (const k of ['1', '2', '3', 'recall', 'regen', 'spell']) {
        if (ent.cds[k] > 0) ent.cds[k] = Math.max(0, ent.cds[k] - dt);
      }
      if (ent.stunTimer > 0) ent.stunTimer = Math.max(0, ent.stunTimer - dt);
      if (ent.speedBuffTimer > 0) ent.speedBuffTimer = Math.max(0, ent.speedBuffTimer - dt);

      if (ent.auraRing) {
        ent.auraRing.material.opacity = ent.orbitTimer > 0 ? 0.85 : 0.0;
        ent.auraRing.rotation.z += dt * 4.5;
      }

      if (ent.orbitTimer > 0) {
        ent.orbitTimer -= dt;
        if (Math.random() < dt * 3.5) {
          this.getValidTargets(ent, 4.8).forEach(({ target }) => {
            this.applyDamage(ent, target, Math.round(ent.atk * 0.45), true);
          });
        }
      }

      ent.mana = Math.min(ent.maxMana, ent.mana + dt * 8);
      if (ent.regenTimer > 0) {
        const prevTick = Math.floor(ent.regenTimer * 2.2);
        ent.regenTimer = Math.max(0, ent.regenTimer - dt);
        const nextTick = Math.floor(ent.regenTimer * 2.2);
        if (prevTick !== nextTick) {
          const healAmt = 42 + Math.floor(Math.random() * 22);
          this.healEntity(ent, healAmt);
          ent.mana = Math.min(ent.maxMana, ent.mana + 30);
        }
      }

      if (ent.recallTimer > 0) {
        ent.recallTimer -= dt;
        if (ent.recallTimer <= 0) {
          ent.x = ent.team === 'blue' ? -30 : 30;
          ent.z = ent.team === 'blue' ? 30 : -30;
          ent.hp = ent.maxHp;
          ent.mana = ent.maxMana;
          this.spawnRingExplosion(ent.x, ent.z, 3.0, '#38bdf8');
          if (this.cb.onFloatingText) this.cb.onFloatingText(ent, 'RECALLED!', '#38bdf8');
        }
      }

      let isMoving = false;
      const moveSpeed = ent.spd * (ent.speedBuffTimer > 0 ? 1.35 : 1.0);

      if (ent.stunTimer <= 0) {
        if (ent.isPlayer) {
          let mx = this.joyVec.x;
          let mz = this.joyVec.y;
          if (this.keys['KeyW'] || this.keys['ArrowUp']) mz -= 1;
          if (this.keys['KeyS'] || this.keys['ArrowDown']) mz += 1;
          if (this.keys['KeyA'] || this.keys['ArrowLeft']) mx -= 1;
          if (this.keys['KeyD'] || this.keys['ArrowRight']) mx += 1;

          const mag = Math.hypot(mx, mz);
          if (mag > 0.08) {
            mx /= mag;
            mz /= mag;
            const targetVx = mx * moveSpeed;
            const targetVz = mz * moveSpeed;
            ent.vx += (targetVx - ent.vx) * Math.min(1, dt * 16);
            ent.vz += (targetVz - ent.vz) * Math.min(1, dt * 16);

            ent.x += ent.vx * dt;
            ent.z += ent.vz * dt;

            // Smooth shortest-angle rotation interpolation
            const desiredRot = Math.atan2(mx, mz);
            let diff = desiredRot - ent.rotY;
            while (diff > Math.PI) diff -= Math.PI * 2;
            while (diff < -Math.PI) diff += Math.PI * 2;
            ent.rotY += diff * Math.min(1, dt * 18);
            ent.mesh.rotation.y = ent.rotY;

            ent.recallTimer = 0;
            isMoving = true;
          } else {
            ent.vx *= 0.78;
            ent.vz *= 0.78;
          }

          // Hold Spacebar or Attack Button for smooth MLBB auto-kiting & auto-chase!
          if ((this.keys['Space'] || this.holdingAttack) && ent.atkCd <= 0) {
            const inRange = this.getValidTargets(ent, ent.range + 0.9);
            if (inRange.length > 0) {
              this.triggerBasicAttack(ent);
            } else if (!isMoving) {
              // Auto-step toward nearest enemy within 14m if not already in range
              const nearby = this.getValidTargets(ent, 14.5);
              if (nearby.length > 0) {
                const t = nearby[0].target;
                const ang = Math.atan2(t.x - ent.x, t.z - ent.z);
                ent.rotY = ang;
                ent.mesh.rotation.y = ang;
                ent.x += Math.sin(ang) * moveSpeed * dt;
                ent.z += Math.cos(ang) * moveSpeed * dt;
                isMoving = true;
              } else {
                this.triggerBasicAttack(ent);
              }
            }
          }

          // Update Ground Target Lock Reticle under primary target
          const lockCandidates = this.getValidTargets(ent, ent.range + 3.5);
          if (lockCandidates.length > 0 && this.targetLockRing) {
            const locked = lockCandidates[0].target;
            this.targetLockRing.visible = true;
            this.targetLockRing.position.set(locked.x, 0.08, locked.z);
            this.targetLockRing.rotation.z += dt * 3.5;
          } else if (this.targetLockRing) {
            this.targetLockRing.visible = false;
          }
        } else {
          isMoving = this.updateHeroAI(ent, dt, moveSpeed);
        }
      }

      this.resolveObstacleCollision(ent);
      ent.mesh.position.set(ent.x, 0, ent.z);

      ent.inBush = this.bushes.some((b) => Math.hypot(ent.x - b.x, ent.z - b.z) <= b.r);

      window.ROBLOX_BUILDER.animateRobloxCharacter(ent.mesh, dt, isMoving, false);
    }

    for (const b of this.bushes) {
      const playerInside = this.player && !this.player.dead && Math.hypot(this.player.x - b.x, this.player.z - b.z) <= b.r;
      b.mesh.children.forEach((cone) => {
        cone.material.transparent = true;
        cone.material.opacity = playerInside ? 0.48 : 1.0;
      });
    }

    for (let i = this.minions.length - 1; i >= 0; i--) {
      const m = this.minions[i];
      if (m.dead) {
        this.scene.remove(m.mesh);
        this.minions.splice(i, 1);
        continue;
      }
      if (m.atkCd > 0) m.atkCd -= dt;
      const targets = this.getValidTargets(m, 14);
      if (targets.length > 0) {
        const t = targets[0].target;
        const dist = targets[0].dist;
        const ang = Math.atan2(t.x - m.x, t.z - m.z);
        m.mesh.rotation.y = ang;
        if (dist <= m.range) {
          if (m.atkCd <= 0) {
            m.atkCd = 1.1;
            this.applyDamage(m, t, m.atk, false);
          }
        } else {
          m.x += Math.sin(ang) * m.spd * dt;
          m.z += Math.cos(ang) * m.spd * dt;
        }
      } else {
        const goalX = m.team === 'blue' ? 30 : -30;
        const goalZ = m.team === 'blue' ? -30 : 30;
        const ang = Math.atan2(goalX - m.x, goalZ - m.z);
        m.mesh.rotation.y = ang;
        m.x += Math.sin(ang) * m.spd * dt;
        m.z += Math.cos(ang) * m.spd * dt;
      }
      m.mesh.position.set(m.x, 0, m.z);
    }

    for (const c of this.creeps) {
      if (c.dead) {
        c.respawnTimer -= dt;
        if (c.respawnTimer <= 0) {
          c.dead = false;
          c.hp = c.maxHp;
          c.x = c.homeX;
          c.z = c.homeZ;
          c.mesh.visible = true;
        }
        continue;
      }
      if (c.atkCd > 0) c.atkCd -= dt;
      let nearest = null;
      let minDist = 6.5;
      for (const h of this.entities) {
        if (!h.dead) {
          const d = Math.hypot(h.x - c.x, h.z - c.z);
          if (d < minDist) {
            minDist = d;
            nearest = h;
          }
        }
      }
      if (nearest && (c.hp < c.maxHp || minDist < 3.8)) {
        const ang = Math.atan2(nearest.x - c.x, nearest.z - c.z);
        c.mesh.rotation.y = ang;
        if (minDist <= c.range) {
          if (c.atkCd <= 0) {
            c.atkCd = 1.25;
            this.applyDamage(c, nearest, c.atk, false);
          }
        } else if (Math.hypot(c.x - c.homeX, c.z - c.homeZ) < 8) {
          c.x += Math.sin(ang) * c.spd * dt;
          c.z += Math.cos(ang) * c.spd * dt;
        }
      } else {
        c.hp = Math.min(c.maxHp, c.hp + dt * 40);
      }
      c.mesh.position.set(c.x, 0, c.z);
    }

    for (const t of this.turrets) {
      if (t.dead) continue;
      t.crystal.rotation.y += dt * 1.8;
      if (t.atkCd > 0) t.atkCd -= dt;
      const targets = this.getValidTargets(t, t.range);
      if (targets.length > 0 && t.atkCd <= 0) {
        t.atkCd = 1.35;
        const victim = targets[0].target;
        const ang = Math.atan2(victim.x - t.x, victim.z - t.z);
        this.spawnProjectile({
          owner: t,
          x: t.x,
          z: t.z,
          vx: Math.sin(ang) * 20,
          vz: Math.cos(ang) * 20,
          color: t.team === 'blue' ? '#3b82f6' : '#ef4444',
          radius: 0.42,
          maxDist: t.range + 2,
          dmg: t.atk,
          target: victim
        });
      }
    }

    for (let i = this.projectiles.length - 1; i >= 0; i--) {
      const p = this.projectiles[i];
      const stepX = p.vx * dt;
      const stepZ = p.vz * dt;
      p.x += stepX;
      p.z += stepZ;
      p.traveled += Math.hypot(stepX, stepZ);
      p.mesh.position.set(p.x, 1.35, p.z);

      let hitTarget = null;
      const checkHit = (cand) => {
        if (hitTarget || !cand || cand.dead || cand.team === p.owner.team) return;
        const d = Math.hypot(cand.x - p.x, cand.z - p.z);
        if (d <= (cand.r || 0.9) + (p.radius || 0.35)) {
          hitTarget = cand;
        }
      };

      this.entities.forEach(checkHit);
      this.minions.forEach(checkHit);
      this.creeps.forEach(checkHit);
      this.turrets.forEach(checkHit);

      if (hitTarget || p.traveled >= p.maxDist) {
        if (hitTarget) {
          this.applyDamage(p.owner, hitTarget, p.dmg, Boolean(p.stun || p.aoeRadius));
          if (p.stun && hitTarget.isHero) {
            hitTarget.stunTimer = Math.max(hitTarget.stunTimer || 0, p.stun);
            if (this.cb.onFloatingText) {
              this.cb.onFloatingText(hitTarget, 'STUNNED!', '#fde047');
            }
          }
          if (p.aoeRadius) {
            this.spawnRingExplosion(p.x, p.z, p.aoeRadius, p.color);
          }
        }
        this.scene.remove(p.mesh);
        this.projectiles.splice(i, 1);
      }
    }

    for (let i = this.vfx.length - 1; i >= 0; i--) {
      const v = this.vfx[i];
      v.timer -= dt;
      const prog = 1 - Math.max(0, v.timer / v.maxTimer);
      if (v.type === 'ring') {
        const s = 0.25 + prog * 0.85;
        v.mesh.scale.set(s, s, s);
        v.mesh.material.opacity = (1 - prog) * 0.8;
      } else if (v.type === 'slash') {
        v.mesh.material.opacity = (1 - prog) * 0.9;
      }
      if (v.timer <= 0) {
        this.scene.remove(v.mesh);
        this.vfx.splice(i, 1);
      }
    }

    // Smooth Top-Down Isometric MOBA Camera with Screen Shake impact
    if (this.player) {
      let shakeX = 0;
      let shakeZ = 0;
      if (this.shakeTimer > 0) {
        this.shakeTimer = Math.max(0, this.shakeTimer - dt);
        shakeX = (Math.random() - 0.5) * this.shakeIntensity;
        shakeZ = (Math.random() - 0.5) * this.shakeIntensity;
      }

      const targetCamX = this.player.x + shakeX;
      const targetCamZ = this.player.z + 17.5 + shakeZ;
      const targetCamY = 21.5;
      this.camera.position.x += (targetCamX - this.camera.position.x) * 0.16;
      this.camera.position.z += (targetCamZ - this.camera.position.z) * 0.16;
      this.camera.position.y += (targetCamY - this.camera.position.y) * 0.16;
      this.camera.lookAt(this.player.x + shakeX * 0.5, 0.8, this.player.z - 1.2 + shakeZ * 0.5);
    }
  }

  updateHeroAI(bot, dt, moveSpeed) {
    if (bot.hp < bot.maxHp * 0.28) {
      if (bot.cds.regen <= 0) this.triggerBattleAction(bot, 'regen');
      const homeX = bot.team === 'blue' ? -28 : 28;
      const homeZ = bot.team === 'blue' ? 28 : -28;
      const ang = Math.atan2(homeX - bot.x, homeZ - bot.z);
      bot.rotY = ang;
      bot.mesh.rotation.y = ang;
      bot.x += Math.sin(ang) * moveSpeed * dt;
      bot.z += Math.cos(ang) * moveSpeed * dt;
      return true;
    }

    const targets = this.getValidTargets(bot, 15.5);
    if (targets.length > 0) {
      const best = targets[0].target;
      const dist = targets[0].dist;
      const ang = Math.atan2(best.x - bot.x, best.z - bot.z);
      bot.rotY = ang;
      bot.mesh.rotation.y = ang;

      if (best.isHero && dist <= 8.5) {
        if (bot.cds[3] <= 0 && best.hp < best.maxHp * 0.65) {
          this.triggerSkill(bot, 3);
        } else if (bot.cds[2] <= 0) {
          this.triggerSkill(bot, 2);
        } else if (bot.cds[1] <= 0) {
          this.triggerSkill(bot, 1);
        }
      }

      if (dist <= bot.range * 0.92) {
        this.triggerBasicAttack(bot);
        // Ranged heroes kite/strafe instead of standing stiffly!
        if (bot.range > 5.0 && dist < bot.range * 0.55) {
          bot.x -= Math.sin(ang) * moveSpeed * 0.75 * dt;
          bot.z -= Math.cos(ang) * moveSpeed * 0.75 * dt;
          return true;
        }
        return false;
      } else {
        bot.x += Math.sin(ang) * moveSpeed * dt;
        bot.z += Math.cos(ang) * moveSpeed * dt;
        return true;
      }
    }

    // Spread AI bots across Top, Mid, and Bottom lanes so they don't clump together!
    const laneWaypoints = {
      'Mid Lane': { x: 0, z: 0 },
      'Gold Lane': { x: -16, z: -16 },
      'Exp Lane': { x: 16, z: 16 },
      'Jungling': { x: bot.team === 'blue' ? -9 : 9, z: bot.team === 'blue' ? 6 : -6 },
      'Roaming': { x: bot.team === 'blue' ? 3 : -3, z: bot.team === 'blue' ? -3 : 3 }
    };
    const wp = laneWaypoints[bot.hero.lane] || { x: 0, z: 0 };
    const distToWp = Math.hypot(wp.x - bot.x, wp.z - bot.z);
    if (distToWp > 3.2) {
      const ang = Math.atan2(wp.x - bot.x, wp.z - bot.z);
      bot.rotY = ang;
      bot.mesh.rotation.y = ang;
      bot.x += Math.sin(ang) * moveSpeed * dt;
      bot.z += Math.cos(ang) * moveSpeed * dt;
      return true;
    }
    return false;
  }

  projectToScreen(worldX, worldY, worldZ) {
    const vec = new THREE.Vector3(worldX, worldY, worldZ);
    vec.project(this.camera);
    if (vec.z > 1) return null;
    return {
      x: (vec.x * 0.5 + 0.5) * window.innerWidth,
      y: (-vec.y * 0.5 + 0.5) * window.innerHeight
    };
  }

  animateLoop() {
    requestAnimationFrame(() => this.animateLoop());
    const now = performance.now();
    const dt = Math.min(0.05, (now - this.lastTime) / 1000);
    this.lastTime = now;

    if (this.mode === 'LOBBY') {
      if (this.lobbyHeroMesh) {
        window.ROBLOX_BUILDER.animateRobloxCharacter(this.lobbyHeroMesh, dt, false, false);
      }
      this.renderer.render(this.lobbyScene, this.lobbyCamera);
    } else if (this.mode === 'BATTLE' && this.running) {
      this.updateBattle(dt);
      this.renderer.render(this.scene, this.camera);
      if (this.cb.onFrameUpdate) this.cb.onFrameUpdate(dt);
    }
  }
}

window.ArenaBattleEngine = ArenaBattleEngine;
