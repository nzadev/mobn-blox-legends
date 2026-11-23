class MOBNGameController {
  constructor() {
    this.heroes = window.GAME_DATA.HEROES;
    this.builds = window.GAME_DATA.BATTLE_BUILDS;
    this.botNames = window.GAME_DATA.BOT_NAMES;

    this.selectedHero = this.heroes[0]; // Laylul default
    this.selectedSkin = this.selectedHero.skins[0];
    this.selectedBuild = this.builds[1]; // Attack Speed Build like 0:13 in the video!
    this.selectedLane = 'Gold Lane';
    this.gameMode = 'CLASSIC'; // 'CLASSIC' | 'RANKED' | 'BRAWL'

    this.coins = 1600;
    this.gems = 0;

    this.queueTimerInterval = null;
    this.queueSeconds = 0;
    this.draftTimerInterval = null;
    this.draftSeconds = 20;
    this.draftLocked = false;
    this.draftLaneFilter = 'All Lanes';

    this.blueRoster = [];
    this.redRoster = [];

    this.portraits = {};
    this.heroes.forEach((h) => {
      this.portraits[h.id] = window.ROBLOX_BUILDER.renderPortraitDataURL(h);
    });

    this.canvas = document.getElementById('game-canvas');
    this.engine = new window.ArenaBattleEngine(this.canvas, {
      onFrameUpdate: (dt) => this.updateBattleHUD(dt),
      onFloatingText: (ent, text, color) => this.spawnFloatingText(ent, text, color),
      onGoldPopup: (ent, amount) => this.spawnGoldPopup(ent, amount),
      onLevelUp: (lvl) => this.showLevelUpBanner(lvl),
      onHeroKill: (killer, victim, voiceCallout) => this.showKillBanner(killer, victim, voiceCallout),
      onMatchEnd: (result) => this.showMatchEndModal(result)
    });

    this.engine.setLobbyHero(this.selectedHero, this.selectedSkin);
    this.bindUIEvents();
    this.renderLobbyUI();

    // Auto-start BGM on first interaction
    const unlockAudio = () => {
      window.SFX.init();
      if (!window.SFX.bgmMode) {
        window.SFX.startBGM(this.engine.mode === 'BATTLE' ? 'BATTLE' : 'LOBBY');
      }
      window.removeEventListener('pointerdown', unlockAudio);
      window.removeEventListener('keydown', unlockAudio);
    };
    window.addEventListener('pointerdown', unlockAudio);
    window.addEventListener('keydown', unlockAudio);
  }

  bindUIEvents() {
    // Rotate 3D Hero on Lobby Drag
    let draggingLobby = false;
    let prevX = 0;
    const lobbyStage = document.getElementById('lobby-3d-drag');
    if (lobbyStage) {
      lobbyStage.addEventListener('pointerdown', (e) => {
        draggingLobby = true;
        prevX = e.clientX;
      });
      window.addEventListener('pointermove', (e) => {
        if (draggingLobby && this.engine.lobbyHeroMesh) {
          const dx = e.clientX - prevX;
          prevX = e.clientX;
          this.engine.lobbyHeroMesh.rotation.y += dx * 0.012;
        }
      });
      window.addEventListener('pointerup', () => {
        draggingLobby = false;
      });
    }

    // Audio Mute / Unmute Toggle
    const bgmBtn = document.getElementById('bgm-toggle-btn');
    if (bgmBtn) {
      bgmBtn.innerHTML = window.UI_ICONS.soundOn;
      bgmBtn.addEventListener('click', () => {
        window.SFX.muted = !window.SFX.muted;
        bgmBtn.innerHTML = window.SFX.muted ? window.UI_ICONS.soundOff : window.UI_ICONS.soundOn;
        if (!window.SFX.muted) {
          window.SFX.startBGM('LOBBY');
        }
      });
    }

    // Bottom Navigation Tabs in Lobby
    document.getElementById('nav-heroes-btn').addEventListener('click', () => {
      window.SFX.click();
      this.openHeroesDrawer();
    });
    document.getElementById('nav-prep-btn').addEventListener('click', () => {
      window.SFX.click();
      this.openBattleSetupModal();
    });
    document.getElementById('nav-emblems-btn').addEventListener('click', () => {
      window.SFX.click();
      this.showToast('Emblem Lv.60 Marksman / Assassin Custom Set Equipped!');
    });
    document.getElementById('nav-collection-btn').addEventListener('click', () => {
      window.SFX.click();
      this.openHeroesDrawer();
    });

    // Mode Button (Bottom Right in Lobby -> Opens Classic Matchmaking Room)
    document.getElementById('lobby-mode-btn').addEventListener('click', () => {
      window.SFX.confirm();
      this.showScreen('screen-queue');
      this.renderQueueRoom();
    });

    // Queue Room controls
    document.getElementById('queue-back-btn').addEventListener('click', () => {
      window.SFX.click();
      this.stopQueueTimer();
      this.showScreen('screen-lobby');
    });

    document.getElementById('queue-switch-mode').addEventListener('click', () => {
      window.SFX.click();
      const modes = ['CLASSIC', 'RANKED', 'PRACTICE'];
      const next = (modes.indexOf(this.gameMode) + 1) % modes.length;
      this.gameMode = modes[next];
      document.getElementById('queue-mode-title').textContent = this.gameMode;
      this.showToast(`Switched mode to ${this.gameMode}`);
    });

    document.getElementById('queue-start-cancel-btn').addEventListener('click', () => {
      if (this.queueTimerInterval) {
        window.SFX.click();
        this.stopQueueTimer();
      } else {
        window.SFX.confirm();
        this.startMatchmakingQueue();
      }
    });

    // Draft Pick controls
    document.getElementById('draft-confirm-btn').addEventListener('click', () => {
      window.SFX.confirm();
      this.lockInDraftHero();
    });

    document.getElementById('draft-battle-setup-btn').addEventListener('click', () => {
      window.SFX.click();
      this.openBattleSetupModal();
    });

    document.getElementById('draft-skills-toggle-btn').addEventListener('click', () => {
      window.SFX.click();
      const panel = document.getElementById('draft-skills-preview');
      panel.classList.toggle('hidden');
    });

    // Battle Setup Modal Close
    document.getElementById('setup-close-btn').addEventListener('click', () => {
      window.SFX.click();
      document.getElementById('modal-battle-setup').classList.add('hidden');
    });

    // Heroes Drawer Close
    document.getElementById('heroes-drawer-close').addEventListener('click', () => {
      window.SFX.click();
      document.getElementById('modal-heroes-drawer').classList.add('hidden');
    });

    // In-Game HUD Controls (Mobile + Mouse + Touch + Hold-to-Attack)
    this.setupVirtualJoystick();

    const atkBtn = document.getElementById('btn-atk');
    atkBtn.addEventListener('pointerdown', (e) => {
      e.preventDefault();
      this.engine.holdingAttack = true;
      if (this.engine.player) this.engine.triggerBasicAttack(this.engine.player);
    });
    window.addEventListener('pointerup', () => {
      this.engine.holdingAttack = false;
    });
    document.getElementById('btn-skill-1').addEventListener('pointerdown', (e) => {
      e.preventDefault();
      if (this.engine.player) this.engine.triggerSkill(this.engine.player, 1);
    });
    document.getElementById('btn-skill-2').addEventListener('pointerdown', (e) => {
      e.preventDefault();
      if (this.engine.player) this.engine.triggerSkill(this.engine.player, 2);
    });
    document.getElementById('btn-skill-3').addEventListener('pointerdown', (e) => {
      e.preventDefault();
      if (this.engine.player) this.engine.triggerSkill(this.engine.player, 3);
    });

    // Bottom 3 Action Buttons: Recall, Regen, Flicker (0:17 - 0:34)
    document.getElementById('btn-recall').addEventListener('pointerdown', (e) => {
      e.preventDefault();
      if (this.engine.player) this.engine.triggerBattleAction(this.engine.player, 'recall');
    });
    document.getElementById('btn-regen').addEventListener('pointerdown', (e) => {
      e.preventDefault();
      if (this.engine.player) this.engine.triggerBattleAction(this.engine.player, 'regen');
    });
    document.getElementById('btn-spell').addEventListener('pointerdown', (e) => {
      e.preventDefault();
      if (this.engine.player) this.engine.triggerBattleAction(this.engine.player, 'spell');
    });

    // Quick Shop Buy item button in HUD
    document.getElementById('hud-shop-item').addEventListener('click', () => {
      if (!this.engine.player) return;
      if (this.engine.player.gold >= 500) {
        this.engine.player.gold -= 500;
        this.engine.player.atk += 28;
        this.engine.player.atkSpd += 0.15;
        window.SFX.confirm();
        this.spawnFloatingText(this.engine.player, '+28 ATK / +15% SPD!', '#38bdf8');
      } else {
        window.SFX.click();
        this.showToast('Need 500 Gold to buy next equipment piece!');
      }
    });

    // Settings / Leave Match back to Lobby
    document.getElementById('hud-settings-btn').addEventListener('click', () => {
      window.SFX.click();
      this.returnToLobby();
    });

    document.getElementById('match-end-lobby-btn').addEventListener('click', () => {
      window.SFX.confirm();
      document.getElementById('modal-match-end').classList.add('hidden');
      this.returnToLobby();
    });
  }

  setupVirtualJoystick() {
    const zone = document.getElementById('joystick-zone');
    const knob = document.getElementById('joystick-knob');
    let active = false;
    let center = { x: 0, y: 0 };
    const maxR = 46;

    const updateKnob = (clientX, clientY) => {
      const dx = clientX - center.x;
      const dy = clientY - center.y;
      const dist = Math.hypot(dx, dy);
      const clamped = Math.min(dist, maxR);
      const ang = Math.atan2(dy, dx);
      const kx = Math.cos(ang) * clamped;
      const ky = Math.sin(ang) * clamped;
      knob.style.transform = `translate(${kx}px, ${ky}px)`;
      this.engine.joyVec.x = kx / maxR;
      this.engine.joyVec.y = ky / maxR;
    };

    zone.addEventListener('pointerdown', (e) => {
      active = true;
      const rect = zone.getBoundingClientRect();
      center = { x: rect.left + rect.width / 2, y: rect.top + rect.height / 2 };
      updateKnob(e.clientX, e.clientY);
    });

    window.addEventListener('pointermove', (e) => {
      if (active) updateKnob(e.clientX, e.clientY);
    });

    window.addEventListener('pointerup', () => {
      if (active) {
        active = false;
        knob.style.transform = 'translate(0px, 0px)';
        this.engine.joyVec.x = 0;
        this.engine.joyVec.y = 0;
      }
    });
  }

  showScreen(screenId) {
    document.querySelectorAll('.game-screen').forEach((el) => {
      el.classList.add('hidden');
    });
    const target = document.getElementById(screenId);
    if (target) target.classList.remove('hidden');
  }

  renderLobbyUI() {
    document.getElementById('lobby-coins').textContent = this.coins;
    document.getElementById('lobby-gems').textContent = this.gems;
    document.getElementById('lobby-hero-badge').textContent = `${this.selectedHero.name} · ${this.selectedHero.role}`;
    this.engine.setLobbyHero(this.selectedHero, this.selectedSkin);
  }

  openHeroesDrawer() {
    const grid = document.getElementById('heroes-drawer-grid');
    grid.innerHTML = '';

    this.heroes.forEach((h) => {
      const card = document.createElement('div');
      card.className = `hero-roster-card ${this.selectedHero.id === h.id ? 'selected' : ''}`;
      card.innerHTML = `
        <div class="hero-card-portrait">
          <img src="${this.portraits[h.id]}" alt="${h.name}" />
          <span class="hero-lane-tag">${h.lane}</span>
        </div>
        <div class="hero-card-info">
          <div class="hero-card-name">${h.name}</div>
          <div class="hero-card-role">${h.title} · ${h.role}</div>
        </div>
      `;
      card.addEventListener('click', () => {
        window.SFX.confirm();
        this.selectedHero = h;
        this.selectedSkin = h.skins[0];
        this.renderLobbyUI();
        this.openHeroesDrawer();
      });
      grid.appendChild(card);
    });

    // Render Detail Preview of selected hero in Drawer
    const detail = document.getElementById('heroes-drawer-detail');
    detail.innerHTML = `
      <div class="drawer-hero-header">
        <img src="${this.portraits[this.selectedHero.id]}" class="drawer-hero-avatar" />
        <div>
          <h3>${this.selectedHero.name} <span class="role-badge">${this.selectedHero.role}</span></h3>
          <p class="hero-sub">${this.selectedHero.title} · Recommended: ${this.selectedHero.lane}</p>
          <p class="passive-line"><strong>Passive - ${this.selectedHero.passive.name}:</strong> ${this.selectedHero.passive.desc}</p>
        </div>
      </div>
      <div class="drawer-skills-row">
        ${this.selectedHero.skills.map((s) => `
          <div class="drawer-skill-box">
            <div class="skill-key-badge has-svg">
              ${window.getSkillSvg(s)}
              <span class="sk-mini-key">${s.key}</span>
            </div>
            <div>
              <div class="skill-box-title">${s.name}</div>
              <div class="skill-box-sub">${s.sub}</div>
              <div class="skill-box-desc">${s.desc}</div>
            </div>
          </div>
        `).join('')}
      </div>
    `;

    document.getElementById('modal-heroes-drawer').classList.remove('hidden');
  }

  renderQueueRoom() {
    document.getElementById('queue-mode-title').textContent = this.gameMode;
    document.getElementById('queue-player-portrait').src = this.portraits[this.selectedHero.id];
    document.getElementById('queue-toast-banner').classList.add('hidden');

    // Automatically start the queue timer just like 0:02 in the video!
    this.startMatchmakingQueue();
  }

  startMatchmakingQueue() {
    this.stopQueueTimer();
    this.queueSeconds = 1;
    const btn = document.getElementById('queue-start-cancel-btn');
    btn.textContent = `Cancel 00:01`;
    btn.classList.add('canceling');

    this.queueTimerInterval = setInterval(() => {
      this.queueSeconds++;
      const secStr = String(this.queueSeconds).padStart(2, '0');
      btn.textContent = `Cancel 00:${secStr}`;

      if (this.queueSeconds === 2) {
        // Exact notification at 0:03 in the video: "Found players on another server - moving you there..."
        window.SFX.matchFound();
        const toast = document.getElementById('queue-toast-banner');
        toast.textContent = 'Found players on another server - moving you there...';
        toast.classList.remove('hidden');
      }

      if (this.queueSeconds >= 3) {
        this.stopQueueTimer();
        this.runFirstLoadingScreen();
      }
    }, 950);
  }

  stopQueueTimer() {
    if (this.queueTimerInterval) {
      clearInterval(this.queueTimerInterval);
      this.queueTimerInterval = null;
    }
    const btn = document.getElementById('queue-start-cancel-btn');
    if (btn) {
      btn.textContent = 'Start Matchmaking';
      btn.classList.remove('canceling');
    }
  }

  // Exact match to 0:04 - 0:06 in the video: Black LOADING... transition -> Blue/Gold Crest "Loading heroes... 28% ... 57%"
  runFirstLoadingScreen() {
    this.showScreen('screen-loading-heroes');
    const blackIntro = document.getElementById('loading-black-splash');
    const mainLoad = document.getElementById('loading-crest-main');
    const barFill = document.getElementById('loading-heroes-bar');
    const leftText = document.getElementById('loading-heroes-left');
    const rightPct = document.getElementById('loading-heroes-pct');

    blackIntro.classList.remove('hidden');
    mainLoad.classList.add('hidden');

    setTimeout(() => {
      blackIntro.classList.add('hidden');
      mainLoad.classList.remove('hidden');

      let pct = 12;
      const steps = [
        { p: 28, label: 'Loading heroes... 28%' },
        { p: 57, label: 'Loading heroes... 57%' },
        { p: 84, label: 'Syncing server arena... 84%' },
        { p: 100, label: 'Entering Draft Pick... 100%' }
      ];
      let stepIdx = 0;

      const timer = setInterval(() => {
        if (stepIdx < steps.length) {
          pct = steps[stepIdx].p;
          leftText.textContent = steps[stepIdx].label;
          rightPct.textContent = `${pct}%`;
          barFill.style.width = `${pct}%`;
          stepIdx++;
        } else {
          clearInterval(timer);
          this.enterDraftPickScreen();
        }
      }, 450);
    }, 650);
  }

  enterDraftPickScreen() {
    this.showScreen('screen-draft');
    window.SFX.startBGM('DRAFT');
    window.SFX.announce('Pick your hero!', 0.86, 1.05);
    this.draftLocked = false;
    this.draftSeconds = 20;
    this.draftLaneFilter = 'Gold Lane';

    // Assemble 5v5 teams matching the video names (Kajee, Yeen, Yu Zong, Sabro, Kimee, Minotor, Esteez)
    const findHero = (id) => this.heroes.find((h) => h.id === id) || this.heroes[0];
    this.blueRoster = [
      { playerName: 'PRATIK', hero: this.selectedHero, lane: 'Gold Lane', laneKey: 'G', locked: false, isPlayer: true },
      { playerName: 'KENZO', hero: findHero('kajee'), lane: 'Mid Lane', laneKey: 'M', locked: true, isPlayer: false },
      { playerName: 'Kezzy', hero: findHero('yeen'), lane: 'Jungling', laneKey: 'J', locked: true, isPlayer: false },
      { playerName: 'Frenchzko', hero: findHero('yuzong'), lane: 'Exp Lane', laneKey: 'E', locked: false, isPlayer: false },
      { playerName: 'merely_cat', hero: findHero('sabro'), lane: 'Roaming', laneKey: 'R', locked: false, isPlayer: false }
    ];

    this.redRoster = [
      { playerName: 'Bot_Alpha', hero: findHero('sabro'), lane: 'Jungling', laneKey: 'J' },
      { playerName: 'sel', hero: findHero('kimee'), lane: 'Gold Lane', laneKey: 'G' },
      { playerName: 'The_Bacon', hero: findHero('minotor'), lane: 'Roaming', laneKey: 'R' },
      { playerName: 'chicken_masala', hero: findHero('yuzong'), lane: 'Exp Lane', laneKey: 'E' },
      { playerName: 'Marss', hero: findHero('esteez'), lane: 'Mid Lane', laneKey: 'M' }
    ];

    this.renderDraftUI();

    if (this.draftTimerInterval) clearInterval(this.draftTimerInterval);
    const timerEl = document.getElementById('draft-timer-num');
    timerEl.textContent = this.draftSeconds;

    this.draftTimerInterval = setInterval(() => {
      this.draftSeconds--;
      timerEl.textContent = Math.max(0, this.draftSeconds);

      if (this.draftSeconds === 16) {
        this.blueRoster[3].locked = true;
        this.renderDraftTeamSidebar();
      }
      if (this.draftSeconds === 11) {
        this.blueRoster[4].locked = true;
        this.renderDraftTeamSidebar();
      }
      if (this.draftSeconds <= 0) {
        clearInterval(this.draftTimerInterval);
        this.lockInDraftHero(true);
      }
    }, 1000);
  }

  renderDraftUI() {
    this.renderDraftTeamSidebar();
    this.renderDraftLaneBars();
    this.renderDraftHeroGrid();
    this.renderDraftSkillsCard();
    this.renderDraftSkinCarousel();

    const confirmBtn = document.getElementById('draft-confirm-btn');
    const skinSection = document.getElementById('draft-skin-showcase');
    const pickSection = document.getElementById('draft-pick-main');

    if (this.draftLocked) {
      pickSection.classList.add('hidden');
      skinSection.classList.remove('hidden');
    } else {
      pickSection.classList.remove('hidden');
      skinSection.classList.add('hidden');
      confirmBtn.textContent = 'Confirm';
    }
  }

  renderDraftTeamSidebar() {
    const container = document.getElementById('draft-team-sidebar');
    container.innerHTML = '';
    this.blueRoster[0].hero = this.selectedHero;

    this.blueRoster.forEach((slot) => {
      const div = document.createElement('div');
      div.className = `draft-ally-slot ${slot.isPlayer ? 'is-me' : ''} ${slot.locked ? 'locked' : ''}`;
      div.innerHTML = `
        <div class="ally-lane-badge">${slot.laneKey}</div>
        <img src="${this.portraits[slot.hero.id]}" class="ally-portrait" />
        <div class="ally-info">
          <div class="ally-hero-name">${slot.locked || slot.isPlayer ? slot.hero.name : 'Picking...'}</div>
          <div class="ally-player-name">${slot.playerName}</div>
        </div>
      `;
      container.appendChild(div);
    });
  }

  renderDraftLaneBars() {
    const topLanes = [
      { key: 'E', name: 'Exp Lane', owner: 'Open' },
      { key: 'M', name: 'Mid Lane', owner: 'KENZO' },
      { key: 'J', name: 'Jungling', owner: 'Kezzy' },
      { key: 'G', name: 'Gold Lane', owner: this.selectedLane === 'Gold Lane' ? 'PRATIK' : 'Open' },
      { key: 'R', name: 'Roaming', owner: 'Open' }
    ];

    const topBar = document.getElementById('draft-top-lanes');
    topBar.innerHTML = '';
    topLanes.forEach((l) => {
      const btn = document.createElement('button');
      btn.className = `lane-claim-pill ${this.selectedLane === l.name ? 'active' : ''}`;
      btn.innerHTML = `
        <span class="lane-letter">${l.key}</span>
        <div class="lane-meta">
          <span class="lane-title">${l.name}</span>
          <span class="lane-owner">${l.owner}</span>
        </div>
      `;
      btn.addEventListener('click', () => {
        window.SFX.click();
        if (l.owner !== 'Open' && l.owner !== 'PRATIK') {
          this.showDraftNotice(`${l.owner} already took that lane.`);
          return;
        }
        this.selectedLane = l.name;
        this.draftLaneFilter = l.name;
        this.renderDraftUI();
      });
      topBar.appendChild(btn);
    });

    // Sub-filter tabs: All Lanes | Exp Lane | Gold Lane | Mid Lane | Roaming | Jungling
    const filters = ['All Lanes', 'Exp Lane', 'Gold Lane', 'Mid Lane', 'Roaming', 'Jungling'];
    const filterBar = document.getElementById('draft-filter-tabs');
    filterBar.innerHTML = '';
    filters.forEach((f) => {
      const tab = document.createElement('button');
      tab.className = `draft-filter-tab ${this.draftLaneFilter === f ? 'active' : ''}`;
      tab.textContent = f;
      tab.addEventListener('click', () => {
        window.SFX.click();
        this.draftLaneFilter = f;
        this.renderDraftLaneBars();
        this.renderDraftHeroGrid();
      });
      filterBar.appendChild(tab);
    });
  }

  renderDraftHeroGrid() {
    const grid = document.getElementById('draft-heroes-grid');
    grid.innerHTML = '';

    const list = this.draftLaneFilter === 'All Lanes'
      ? this.heroes
      : this.heroes.filter((h) => h.lane === this.draftLaneFilter);

    list.forEach((h) => {
      const item = document.createElement('div');
      item.className = `draft-hero-tile ${this.selectedHero.id === h.id ? 'selected' : ''}`;
      item.innerHTML = `
        <img src="${this.portraits[h.id]}" alt="${h.name}" />
        <span>${h.name}</span>
      `;
      item.addEventListener('click', () => {
        window.SFX.click();
        this.selectedHero = h;
        this.selectedSkin = h.skins[0];
        this.renderDraftUI();
      });
      grid.appendChild(item);
    });
  }

  renderDraftSkillsCard() {
    const container = document.getElementById('draft-skills-preview');
    container.innerHTML = this.selectedHero.skills.map((sk) => `
      <div class="draft-skill-card">
        <div class="draft-skill-icon ${sk.key === 'ATK' ? 'atk-badge' : 'num-badge'}">
          <div class="draft-sk-svg-wrap">${window.getSkillSvg(sk)}</div>
          <span class="draft-sk-key-tag">${sk.key}</span>
        </div>
        <div class="draft-skill-body">
          <div class="draft-skill-title">${sk.name}</div>
          <div class="draft-skill-sub">${sk.sub}</div>
          <div class="draft-skill-tags">${sk.tags}</div>
          <div class="draft-skill-desc">${sk.desc}</div>
        </div>
      </div>
    `).join('');
  }

  renderDraftSkinCarousel() {
    // Seen at 0:14 after locking in Laylul: Skins cards (DEFAULT, ELITE, EPIC) + big Yu Zong standee on right
    const container = document.getElementById('draft-skin-cards');
    container.innerHTML = '';

    this.selectedHero.skins.forEach((sk) => {
      const skinPortrait = window.ROBLOX_BUILDER.renderPortraitDataURL(this.selectedHero, sk);
      const card = document.createElement('div');
      card.className = `skin-select-card ${this.selectedSkin.id === sk.id ? 'active' : ''}`;
      card.innerHTML = `
        <span class="skin-tier-badge tier-${sk.tag.toLowerCase()}">${sk.tag}</span>
        <img src="${skinPortrait}" alt="${sk.name}" />
        <div class="skin-card-name">${sk.name}</div>
      `;
      card.addEventListener('click', () => {
        window.SFX.click();
        this.selectedSkin = sk;
        this.renderDraftSkinCarousel();
      });
      container.appendChild(card);
    });

    document.getElementById('draft-locked-hero-name').textContent = this.selectedHero.name;
    document.getElementById('draft-locked-hero-title').textContent = this.selectedHero.title;

    const yuzongHero = this.heroes.find((h) => h.id === 'yuzong') || this.selectedHero;
    const standeeImg = document.getElementById('draft-standee-img');
    const standeeName = document.getElementById('draft-standee-name');
    if (standeeImg) standeeImg.src = this.portraits[yuzongHero.id];
    if (standeeName) standeeName.textContent = yuzongHero.name;
  }

  showDraftNotice(msg) {
    const pill = document.getElementById('draft-notice-pill');
    pill.textContent = msg;
    pill.classList.remove('hidden');
    clearTimeout(this.noticeTimeout);
    this.noticeTimeout = setTimeout(() => pill.classList.add('hidden'), 2600);
  }

  openBattleSetupModal() {
    // Exact replica of 0:10 - 0:13: "BATTLE SETUP · Laylul" with Crit Build, Attack Speed Build, Tank Build, Recommended
    document.getElementById('setup-hero-title').textContent = `BATTLE SETUP · ${this.selectedHero.name}`;
    const list = document.getElementById('setup-builds-list');
    list.innerHTML = '';

    this.builds.forEach((b) => {
      const isUsed = this.selectedBuild.id === b.id;
      const row = document.createElement('div');
      row.className = `setup-build-row ${isUsed ? 'in-use' : ''}`;
      row.innerHTML = `
        <div class="build-row-header">
          <span class="build-row-title">${b.name}</span>
          <span class="build-tag-pill">Attack</span>
        </div>
        <div class="build-row-content">
          <div class="build-items-group">
            ${b.items.map((it) => `
              <div class="build-item-circle" style="background:${it.color}33; border-color:${it.color}" title="${it.name}">
                ${window.UI_ICONS[it.iconKey] || window.UI_ICONS.item_boots}
              </div>
            `).join('')}
            <button class="build-edit-btn">EDIT</button>
          </div>
          <div class="build-spell-group">
            <div class="spell-circle" style="background:${b.spell.color}">
              ${window.UI_ICONS[b.spell.iconKey] || window.UI_ICONS.spell_flicker}
            </div>
            <div>
              <div class="spell-name">${b.spell.name}</div>
              <div class="spell-sub">${b.spell.sub}</div>
            </div>
          </div>
          <div class="build-cost-group">
            <div class="cost-label">Full Build</div>
            <div class="cost-val">${window.UI_ICONS.coin} ${b.cost}</div>
          </div>
          <div class="build-action-group">
            <button class="build-use-btn ${isUsed ? 'active' : ''}">${isUsed ? 'In Use' : 'Use'}</button>
          </div>
        </div>
      `;

      row.querySelector('.build-use-btn').addEventListener('click', () => {
        window.SFX.confirm();
        this.selectedBuild = b;
        this.openBattleSetupModal();
        this.showDraftNotice(`${b.name} is now in use for ${this.selectedHero.name}.`);
      });
      list.appendChild(row);
    });

    document.getElementById('modal-battle-setup').classList.remove('hidden');
  }

  lockInDraftHero(forceStart = false) {
    if (!this.draftLocked && !forceStart) {
      this.draftLocked = true;
      this.blueRoster[0].locked = true;
      this.renderDraftUI();
      this.showDraftNotice(`${this.selectedBuild.name} is now in use for ${this.selectedHero.name}.`);
      // Proceed to 5v5 VS Loading screen after 1.6s of skin showcase (just like 0:14 -> 0:15!)
      setTimeout(() => {
        if (this.draftTimerInterval) clearInterval(this.draftTimerInterval);
        this.run5v5MatchLoadingScreen();
      }, 1700);
      return;
    }

    if (this.draftTimerInterval) clearInterval(this.draftTimerInterval);
    this.run5v5MatchLoadingScreen();
  }

  // Exact match to 0:15 - 0:16 in the video: Split 5v5 Red vs Blue vertical cards with individual % loading bars!
  run5v5MatchLoadingScreen() {
    this.showScreen('screen-vs-loading');
    const redRow = document.getElementById('vs-red-team-row');
    const blueRow = document.getElementById('vs-blue-team-row');
    redRow.innerHTML = '';
    blueRow.innerHTML = '';

    const cardLoadBars = [];

    const createVSCard = (slot, team) => {
      const portrait = slot.isPlayer
        ? window.ROBLOX_BUILDER.renderPortraitDataURL(slot.hero, this.selectedSkin)
        : this.portraits[slot.hero.id];
      const card = document.createElement('div');
      card.className = `vs-hero-card team-${team}`;
      const initPct = 22 + Math.floor(Math.random() * 14);
      card.innerHTML = `
        <div class="vs-card-art">
          <img src="${portrait}" alt="${slot.hero.name}" />
        </div>
        <div class="vs-card-footer">
          <div class="vs-hero-name">${slot.hero.name}</div>
          <div class="vs-player-name">${slot.playerName}</div>
          <div class="vs-load-track">
            <div class="vs-load-fill" style="width:${initPct}%"></div>
            <span class="vs-load-text">${initPct}%</span>
          </div>
        </div>
      `;
      cardLoadBars.push({
        pct: initPct,
        fillEl: card.querySelector('.vs-load-fill'),
        textEl: card.querySelector('.vs-load-text')
      });
      return card;
    };

    this.redRoster.forEach((s) => redRow.appendChild(createVSCard(s, 'red')));
    this.blueRoster.forEach((s) => blueRow.appendChild(createVSCard(s, 'blue')));

    const vsInterval = setInterval(() => {
      let allDone = true;
      cardLoadBars.forEach((b) => {
        b.pct = Math.min(100, b.pct + 14 + Math.floor(Math.random() * 18));
        b.fillEl.style.width = `${b.pct}%`;
        b.textEl.textContent = `${b.pct}%`;
        if (b.pct < 100) allDone = false;
      });

      if (allDone) {
        clearInterval(vsInterval);
        setTimeout(() => this.launchArenaMatch(), 380);
      }
    }, 360);
  }

  launchArenaMatch() {
    this.showScreen('screen-battle-hud');

    // Populate HUD Skill Labels & Dynamic Hero Skill Artwork Icons
    const h = this.selectedHero;
    document.getElementById('hud-hero-portrait').src = window.ROBLOX_BUILDER.renderPortraitDataURL(h, this.selectedSkin);
    document.getElementById('s1-name').textContent = h.skills[1].name;
    document.getElementById('s1-mana').innerHTML = `${window.UI_ICONS.manaDrop}${h.skills[1].mana}`;
    document.getElementById('s2-name').textContent = h.skills[2].name;
    document.getElementById('s2-mana').innerHTML = `${window.UI_ICONS.manaDrop}${h.skills[2].mana}`;
    document.getElementById('s3-name').textContent = h.skills[3].name;
    document.getElementById('s3-mana').innerHTML = `${window.UI_ICONS.manaDrop}${h.skills[3].mana}`;
    document.getElementById('spell-label').textContent = this.selectedBuild.spell.name;

    // Inject Hero-Specific SVG Skill Artworks into S1, S2, S3 & Basic Attack buttons!
    const setBtnArt = (btnId, svgMarkup) => {
      const btn = document.getElementById(btnId);
      if (!btn) return;
      const artSlot = btn.querySelector('.sk-art-slot');
      if (artSlot) artSlot.innerHTML = svgMarkup;
    };

    setBtnArt('btn-skill-1', window.getSkillSvg(h.skills[1]));
    setBtnArt('btn-skill-2', window.getSkillSvg(h.skills[2]));
    setBtnArt('btn-skill-3', window.getSkillSvg(h.skills[3]));
    setBtnArt('btn-atk', window.getSkillSvg(h.skills[0]));
    setBtnArt('btn-spell', window.UI_ICONS[this.selectedBuild.spell.iconKey] || window.UI_ICONS.spell_flicker);

    this.engine.startMatch(
      this.selectedHero,
      this.selectedSkin,
      this.selectedBuild,
      this.blueRoster,
      this.redRoster
    );
  }

  updateBattleHUD() {
    const p = this.engine.player;
    if (!p) return;

    // Top Scoreboard & Clock (00:38, Blue vs Red kills, K/D/A)
    const mins = String(Math.floor(this.engine.matchTime / 60)).padStart(2, '0');
    const secs = String(Math.floor(this.engine.matchTime % 60)).padStart(2, '0');
    document.getElementById('hud-clock').textContent = `${mins}:${secs}`;
    document.getElementById('hud-blue-score').textContent = this.engine.blueKills;
    document.getElementById('hud-red-score').textContent = this.engine.redKills;

    document.getElementById('hud-kills').textContent = p.kills;
    document.getElementById('hud-deaths').textContent = p.deaths;
    document.getElementById('hud-assists').textContent = p.assists;
    document.getElementById('hud-gold-val').textContent = p.gold;
    document.getElementById('hud-hero-lvl').textContent = p.level;

    // Update Cooldown Overlays on Skills & Battle Spells
    const updateCdBadge = (btnId, cdVal) => {
      const btn = document.getElementById(btnId);
      if (!btn) return;
      const cdOverlay = btn.querySelector('.cd-overlay');
      if (cdVal > 0.05) {
        btn.classList.add('on-cd');
        if (cdOverlay) {
          cdOverlay.classList.remove('hidden');
          cdOverlay.textContent = Math.ceil(cdVal);
        }
      } else {
        btn.classList.remove('on-cd');
        if (cdOverlay) cdOverlay.classList.add('hidden');
      }
    };

    updateCdBadge('btn-skill-1', p.cds[1]);
    updateCdBadge('btn-skill-2', p.cds[2]);
    updateCdBadge('btn-skill-3', p.cds[3]);
    updateCdBadge('btn-recall', p.cds.recall);
    updateCdBadge('btn-regen', p.cds.regen);
    updateCdBadge('btn-spell', p.cds.spell);

    // Render 3D-Projected Overhead Health Bars (Matches 0:18 - 0:34 in the Reel!)
    this.renderOverheadHealthBars();
  }

  renderOverheadHealthBars() {
    const layer = document.getElementById('overhead-bars-layer');
    layer.innerHTML = '';

    const drawBar = (ent, label, isHero) => {
      if (!ent || ent.dead) return;
      // Hide enemy in bush unless close to player
      if (ent.inBush && ent.team !== 'blue') {
        const dist = this.engine.player ? Math.hypot(ent.x - this.engine.player.x, ent.z - this.engine.player.z) : 99;
        if (dist > 4.2) return;
      }

      const yOffset = ent.isTurret ? 4.8 : (isHero ? 3.55 : 2.35);
      const pos = this.engine.projectToScreen(ent.x, yOffset, ent.z);
      if (!pos || pos.x < -80 || pos.x > window.innerWidth + 80 || pos.y < -80 || pos.y > window.innerHeight + 80) {
        return;
      }

      const hpPct = Math.max(0, Math.min(100, (ent.hp / ent.maxHp) * 100));
      const manaPct = ent.maxMana ? Math.max(0, Math.min(100, (ent.mana / ent.maxMana) * 100)) : 100;

      let barColor = '#ef4444'; // Red enemy default
      if (ent.isPlayer) barColor = '#22c55e'; // Bright Green for player
      else if (ent.team === 'blue') barColor = '#3b82f6'; // Blue for allies
      else if (ent.team === 'neutral') barColor = '#f59e0b';

      const barEl = document.createElement('div');
      barEl.className = `overhead-unit-bar ${isHero ? 'hero-bar' : 'minion-bar'}`;
      barEl.style.left = `${pos.x}px`;
      barEl.style.top = `${pos.y}px`;

      if (isHero || ent.isCreep || ent.isTurret) {
        barEl.innerHTML = `
          <div class="oh-name-line">${label}</div>
          <div class="oh-bar-row">
            <span class="oh-lvl-box">${ent.level || (ent.isTurret ? 'T' : 1)}</span>
            <div class="oh-bars-stack">
              <div class="oh-hp-track">
                <div class="oh-hp-fill" style="width:${hpPct}%; background:${barColor}"></div>
                <span class="oh-hp-text">${Math.ceil(ent.hp)}/${ent.maxHp}</span>
              </div>
              ${isHero ? `
                <div class="oh-mana-track">
                  <div class="oh-mana-fill" style="width:${manaPct}%"></div>
                </div>
              ` : ''}
            </div>
          </div>
        `;
      } else {
        barEl.innerHTML = `
          <div class="oh-minion-track">
            <div class="oh-hp-fill" style="width:${hpPct}%; background:${barColor}"></div>
          </div>
        `;
      }

      layer.appendChild(barEl);
    };

    this.engine.entities.forEach((h) => drawBar(h, h.hero.name, true));
    this.engine.creeps.forEach((c) => {
      if (c.hp < c.maxHp || Math.hypot(c.x - this.engine.player.x, c.z - this.engine.player.z) < 13) {
        drawBar(c, c.name, false);
      }
    });
    this.engine.turrets.forEach((t) => {
      if (Math.hypot(t.x - this.engine.player.x, t.z - this.engine.player.z) < 18) {
        drawBar(t, t.name, false);
      }
    });
    this.engine.minions.forEach((m) => drawBar(m, m.name, false));
  }

  spawnFloatingText(ent, text, color = '#ffffff') {
    const pos = this.engine.projectToScreen(ent.x, 3.1, ent.z);
    if (!pos) return;
    const fxLayer = document.getElementById('combat-fx-layer');
    const el = document.createElement('div');
    el.className = 'floating-combat-text';
    el.style.left = `${pos.x + (Math.random() - 0.5) * 34}px`;
    el.style.top = `${pos.y - 10}px`;
    el.style.color = color;
    el.textContent = text;
    fxLayer.appendChild(el);
    setTimeout(() => el.remove(), 850);
  }

  // Exact match to 0:20 - 0:21 in the Reel: Golden Coins & "+203" pop out when killing an enemy!
  spawnGoldPopup(ent, amount) {
    const pos = this.engine.projectToScreen(ent.x, 2.5, ent.z);
    if (!pos) return;
    const fxLayer = document.getElementById('combat-fx-layer');
    const el = document.createElement('div');
    el.className = 'floating-gold-popup';
    el.style.left = `${pos.x}px`;
    el.style.top = `${pos.y}px`;
    el.innerHTML = `<span class="coin-burst">${window.UI_ICONS.coin}${window.UI_ICONS.coin}</span> +${amount}`;
    fxLayer.appendChild(el);
    setTimeout(() => el.remove(), 1250);
  }

  // Exact match to 0:22 in the Reel: Golden "LEVEL UP!" text above character!
  showLevelUpBanner(lvl) {
    if (!this.engine.player) return;
    const pos = this.engine.projectToScreen(this.engine.player.x, 4.1, this.engine.player.z);
    const fxLayer = document.getElementById('combat-fx-layer');
    const el = document.createElement('div');
    el.className = 'floating-levelup-banner';
    el.style.left = `${pos ? pos.x : window.innerWidth / 2}px`;
    el.style.top = `${pos ? pos.y : window.innerHeight / 2}px`;
    el.textContent = `LEVEL UP! (Lv.${lvl})`;
    fxLayer.appendChild(el);
    setTimeout(() => el.remove(), 1500);
  }

  // Exact match to 0:20 - 0:24 in the Reel: "[Portrait] HAS SLAIN [Portrait]" banner at top center!
  showKillBanner(killer, victim, voiceCallout = '') {
    const banner = document.getElementById('hud-kill-banner');
    const killerImg = document.getElementById('kill-banner-killer');
    const victimImg = document.getElementById('kill-banner-victim');
    const calloutEl = document.getElementById('kill-banner-callout');

    const kHero = (killer && killer.hero) ? killer.hero : this.selectedHero;
    const vHero = (victim && victim.hero) ? victim.hero : this.heroes[1];

    killerImg.src = this.portraits[kHero.id];
    victimImg.src = this.portraits[vHero.id];
    if (calloutEl) {
      calloutEl.textContent = (voiceCallout || 'ENEMY SLAIN!').toUpperCase();
    }

    banner.classList.remove('hidden');
    clearTimeout(this.killBannerTimeout);
    this.killBannerTimeout = setTimeout(() => {
      banner.classList.add('hidden');
    }, 3400);
  }

  showMatchEndModal(result) {
    this.engine.running = false;
    window.SFX.startBGM('LOBBY');
    const modal = document.getElementById('modal-match-end');
    const title = document.getElementById('match-end-title');
    title.textContent = result;
    title.style.color = result === 'VICTORY' ? '#facc15' : '#ef4444';
    this.coins += result === 'VICTORY' ? 450 : 150;
    modal.classList.remove('hidden');
  }

  returnToLobby() {
    this.engine.running = false;
    this.engine.mode = 'LOBBY';
    window.SFX.startBGM('LOBBY');
    this.renderLobbyUI();
    this.showScreen('screen-lobby');
  }

  showToast(msg) {
    const toast = document.getElementById('global-toast');
    toast.textContent = msg;
    toast.classList.remove('hidden');
    clearTimeout(this.toastTimeout);
    this.toastTimeout = setTimeout(() => toast.classList.add('hidden'), 2500);
  }
}

window.addEventListener('DOMContentLoaded', () => {
  window.GAME_APP = new MOBNGameController();
});
