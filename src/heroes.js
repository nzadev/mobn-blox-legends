const HEROES = [
  {
    id: 'laylul',
    name: 'Laylul',
    title: 'Void Marksman',
    role: 'Marksman',
    lane: 'Gold Lane',
    laneKey: 'G',
    price: 0,
    unlocked: true,
    stats: { hp: 2272, mana: 480, atk: 128, def: 18, spd: 5.8, range: 9.5, atkSpd: 1.25 },
    colors: {
      skin: '#f8d2b4',
      hair: '#ffcf24',
      hairStyle: 'twintails',
      torso: '#e8e4f0',
      coat: '#d8cfe8',
      trim: '#d49b27',
      pants: '#1e1b2e',
      weapon: 'cannon',
      weaponColor: '#6b4fa0',
      aura: '#38bdf8'
    },
    passive: {
      name: 'Malefic Gun',
      desc: 'Basic attacks and skills deal up to 130% extra damage the farther the target is.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Rifle Shot',
        sub: 'Hex Shot · Cooldown 0.8s',
        tags: '[Ranged] [Physical]',
        desc: 'Fire a void-charged round from her cannon, dealing physical damage scaled with distance.',
        cd: 0.8,
        mana: 0
      },
      {
        key: '1',
        name: 'Speed Shot',
        sub: 'Malefic Bomb · Cooldown 5s · Mana 50',
        tags: '[Skillshot] [Damage] [Speed Boost]',
        desc: 'Fires a malefic energy blast forward, dealing 280 (+95% ATK) damage and boosting movement speed & range.',
        cd: 5,
        mana: 50,
        dmg: 280,
        ratio: 0.95,
        type: 'line_bolt',
        color: '#facc15',
        range: 11.5
      },
      {
        key: '2',
        name: 'Stun Blast',
        sub: 'Malefic Orb · Cooldown 8s · Mana 45',
        tags: '[Targeted] [Area Damage] [Stun]',
        desc: 'Fires an energy orb that explodes on impact, dealing 240 (+75% ATK) damage and stunning enemies for 1.2s.',
        cd: 8,
        mana: 45,
        dmg: 240,
        ratio: 0.75,
        type: 'stun_orb',
        color: '#a855f7',
        range: 9.5
      },
      {
        key: '3',
        name: 'Destruction Rush',
        sub: 'Void Laser · Cooldown 22s · Mana 100',
        tags: '[Mega Laser] [Burst] [Long Range]',
        desc: 'Fires a massive cyan void laser beam across the battlefield, dealing 620 (+150% ATK) devastating damage to all enemies in the line.',
        cd: 22,
        mana: 100,
        dmg: 620,
        ratio: 1.5,
        type: 'mega_laser',
        color: '#22d3ee',
        range: 18.0
      }
    ],
    skins: [
      { id: 'default', name: 'Archer Gunner', tag: 'DEFAULT', coat: '#d8cfe8', hair: '#ffcf24', trim: '#d49b27' },
      { id: 'elite', name: 'Bunny Babe', tag: 'ELITE', coat: '#2b2d42', hair: '#ffcf24', trim: '#ef233c' },
      { id: 'epic', name: 'Blazing Gun', tag: 'EPIC', coat: '#3b1c32', hair: '#ff7eb3', trim: '#00f5d4' },
      { id: 'legend', name: 'Twilight Waltz', tag: 'COLLECTOR', coat: '#1e293b', hair: '#c084fc', trim: '#38bdf8' }
    ]
  },
  {
    id: 'sabro',
    name: 'Sabro',
    title: 'Wandering Sword',
    role: 'Assassin',
    lane: 'Jungling',
    laneKey: 'J',
    price: 0,
    unlocked: true,
    stats: { hp: 2450, mana: 440, atk: 148, def: 24, spd: 6.4, range: 3.4, atkSpd: 1.3 },
    colors: {
      skin: '#94a3b8',
      hair: '#e2e8f0',
      hairStyle: 'cyber_helm',
      torso: '#1e3a8a',
      coat: '#172554',
      trim: '#ef4444',
      pants: '#0f172a',
      weapon: 'dual_blades',
      weaponColor: '#38bdf8',
      aura: '#3b82f6'
    },
    passive: {
      name: 'Enemy\'s Bane',
      desc: 'Attacks reduce target physical defense and deal bonus slash damage.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Sword Slash',
        sub: 'Slash · Cooldown 0.7s',
        tags: '[Melee]',
        desc: 'Slash the enemy in front of you. While Ember Orbit is up, each slash launches a flying sword.',
        cd: 0.7,
        mana: 0
      },
      {
        key: '1',
        name: 'Orbiting Swords',
        sub: 'Ember Orbit · Cooldown 7s · Mana 55',
        tags: '[AoE] [Orbit] [Poke]',
        desc: 'Releases 5 spinning cyber blades that orbit around Sabro for 4s, slicing all nearby enemies for 210 (+80% ATK) per hit.',
        cd: 7,
        mana: 55,
        dmg: 210,
        ratio: 0.8,
        type: 'orbit_blades',
        color: '#38bdf8',
        range: 5.5
      },
      {
        key: '2',
        name: 'Dash Strike',
        sub: 'Ash Dash · Cooldown 7s · Mana 45',
        tags: '[Dash] [Damage] [Slow]',
        desc: 'Dash toward where you aim, cutting enemies in your path for 250 (+90% ATK). Your next basic attack is enhanced.',
        cd: 7,
        mana: 45,
        dmg: 250,
        ratio: 0.9,
        type: 'dash_slash',
        color: '#60a5fa',
        range: 7.0
      },
      {
        key: '3',
        name: 'Triple Sweep',
        sub: 'Sky Execution · Cooldown 24s · Mana 100',
        tags: '[Airborne] [Burst] [Lock-On]',
        desc: 'Leaps to an enemy hero, knocking them airborne and delivering 3 consecutive lethal slashes totaling 740 (+170% ATK) damage.',
        cd: 24,
        mana: 100,
        dmg: 740,
        ratio: 1.7,
        type: 'triple_sweep',
        color: '#ef4444',
        range: 8.0
      }
    ],
    skins: [
      { id: 'default', name: 'Ronin Cyborg', tag: 'DEFAULT', coat: '#172554', hair: '#e2e8f0', trim: '#ef4444' },
      { id: 'elite', name: 'Golden Warrior', tag: 'ELITE', coat: '#78350f', hair: '#fde047', trim: '#f59e0b' },
      { id: 'epic', name: 'Onimaru', tag: 'EPIC', coat: '#450a0a', hair: '#f8fafc', trim: '#dc2626' }
    ]
  },
  {
    id: 'yuzong',
    name: 'Yu Zong',
    title: 'Black Dragon',
    role: 'Fighter',
    lane: 'Exp Lane',
    laneKey: 'E',
    price: 0,
    unlocked: true,
    stats: { hp: 3150, mana: 400, atk: 136, def: 38, spd: 5.9, range: 3.6, atkSpd: 1.1 },
    colors: {
      skin: '#64748b',
      hair: '#1e1b4b',
      hairStyle: 'horns',
      torso: '#18181b',
      coat: '#27272a',
      trim: '#e11d48',
      pants: '#09090b',
      weapon: 'dragon_claws',
      weaponColor: '#f43f5e',
      aura: '#e11d48'
    },
    passive: {
      name: 'Cursing Touch',
      desc: 'Applies Sha Residue to targets; at 5 stacks, erupts to drain enemy HP and heal Yu Zong.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Dragon Claw',
        sub: 'Sha Strike · Cooldown 0.85s',
        tags: '[Melee] [Lifesteal]',
        desc: 'Claws enemies in front, stacking Sha Residue and healing for 15% of damage dealt.',
        cd: 0.85,
        mana: 0
      },
      {
        key: '1',
        name: 'Dragon Tail',
        sub: 'Blood Cloak · Cooldown 6s · Mana 40',
        tags: '[AoE] [Spell Vamp]',
        desc: 'Infuses power into his cloak and sweeps a 360-degree razor edge, dealing 310 (+100% ATK) damage and healing.',
        cd: 6,
        mana: 40,
        dmg: 310,
        ratio: 1.0,
        type: 'aoe_spin',
        color: '#e11d48',
        range: 5.2
      },
      {
        key: '2',
        name: 'Furious Dive',
        sub: 'Soul Grip · Cooldown 9s · Mana 55',
        tags: '[Leap] [Knockup] [Slow]',
        desc: 'Leaps forward and slams the ground with crimson dragon force, dealing 290 (+85% ATK) and stunning hit enemies.',
        cd: 9,
        mana: 55,
        dmg: 290,
        ratio: 0.85,
        type: 'leap_slam',
        color: '#be123c',
        range: 7.2
      },
      {
        key: '3',
        name: 'Black Dragon Form',
        sub: 'Dragonoid · Cooldown 28s · Mana 90',
        tags: '[Transform] [Max HP] [Shockwave]',
        desc: 'Unleashes Black Dragon supremacy, gaining +700 shield, movement speed, and blasting a dark dragon shockwave for 580 (+140% ATK).',
        cd: 28,
        mana: 90,
        dmg: 580,
        ratio: 1.4,
        type: 'dragon_form',
        color: '#f43f5e',
        range: 7.5
      }
    ],
    skins: [
      { id: 'default', name: 'Black Fierce', tag: 'DEFAULT', coat: '#27272a', hair: '#1e1b4b', trim: '#e11d48' },
      { id: 'epic', name: 'Blood Serpent', tag: 'COLLECTOR', coat: '#4c0519', hair: '#f8fafc', trim: '#fb7185' }
    ]
  },
  {
    id: 'kajee',
    name: 'Kajee',
    title: 'Nazar King',
    role: 'Support / Fighter',
    lane: 'Mid Lane',
    laneKey: 'M',
    price: 0,
    unlocked: true,
    stats: { hp: 2780, mana: 550, atk: 122, def: 30, spd: 6.1, range: 4.5, atkSpd: 1.15 },
    colors: {
      skin: '#f59e0b',
      hair: '#fef08a',
      hairStyle: 'bird_crest',
      torso: '#4c1d95',
      coat: '#3b0764',
      trim: '#eab308',
      pants: '#1e1b4b',
      weapon: 'whip',
      weaponColor: '#facc15',
      aura: '#eab308'
    },
    passive: {
      name: 'Wrath Sanction',
      desc: 'Every 4s his next basic attack sends lightning whip chaining between enemies.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Lightning Whip',
        sub: 'Volt Lash · Cooldown 0.8s',
        tags: '[Mid-Range] [Magic]',
        desc: 'Cracks an electric whip dealing hybrid damage and paralyzing enemies.',
        cd: 0.8,
        mana: 0
      },
      {
        key: '1',
        name: 'Ring of Order',
        sub: 'Electric Ring · Cooldown 6s · Mana 50',
        tags: '[Expanding AoE] [Heal]',
        desc: 'Releases a ringed electric wave that expands and contracts, dealing 290 (+90% ATK) damage and healing Kajee.',
        cd: 6,
        mana: 50,
        dmg: 290,
        ratio: 0.9,
        type: 'ring_pulse',
        color: '#facc15',
        range: 6.8
      },
      {
        key: '2',
        name: 'Lightning Bomb',
        sub: 'Thunder Dash · Cooldown 8s · Mana 55',
        tags: '[Dash] [Electric Orbs]',
        desc: 'Dashes in the target direction while leaving 3 lightning bombs that detonate for 260 (+80% ATK) damage.',
        cd: 8,
        mana: 55,
        dmg: 260,
        ratio: 0.8,
        type: 'dash_slash',
        color: '#fde047',
        range: 6.5
      },
      {
        key: '3',
        name: 'Divine Judgment',
        sub: 'Suppression · Cooldown 25s · Mana 100',
        tags: '[Suppress] [Drag] [Burst]',
        desc: 'Binds and shocks the nearest enemy hero with golden chains, stunning for 1.6s and dealing 540 (+135% ATK) magic damage.',
        cd: 25,
        mana: 100,
        dmg: 540,
        ratio: 1.35,
        type: 'divine_chain',
        color: '#eab308',
        range: 6.5
      }
    ],
    skins: [
      { id: 'default', name: 'Nazar Sovereign', tag: 'DEFAULT', coat: '#3b0764', hair: '#fef08a', trim: '#eab308' },
      { id: 'epic', name: 'Skyblocker', tag: 'EPIC', coat: '#0f172a', hair: '#38bdf8', trim: '#f43f5e' }
    ]
  },
  {
    id: 'yeen',
    name: 'Yeen',
    title: 'Martial Genius',
    role: 'Fighter',
    lane: 'Jungling',
    laneKey: 'J',
    price: 0,
    unlocked: true,
    stats: { hp: 2820, mana: 430, atk: 144, def: 28, spd: 6.3, range: 3.3, atkSpd: 1.25 },
    colors: {
      skin: '#fbd38d',
      hair: '#eab308',
      hairStyle: 'spiky',
      torso: '#991b1b',
      coat: '#7f1d1d',
      trim: '#fbbf24',
      pants: '#1c1917',
      weapon: 'gauntlets',
      weaponColor: '#f59e0b',
      aura: '#f97316'
    },
    passive: {
      name: 'Leave It To Me',
      desc: 'Deals 120% increased damage when fighting isolated 1v1 duels.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Martial Combo',
        sub: 'Fist Flurry · Cooldown 0.7s',
        tags: '[Melee] [Physical]',
        desc: 'Rapid martial arts strikes infused with Lieh crimson energy.',
        cd: 0.7,
        mana: 0
      },
      {
        key: '1',
        name: 'Charged Punch',
        sub: 'Fist Smash · Cooldown 5.5s · Mana 40',
        tags: '[Dash Strike] [Burst]',
        desc: 'Charges up speed and launches a devastating two-hit smash dealing 320 (+105% ATK) damage.',
        cd: 5.5,
        mana: 40,
        dmg: 320,
        ratio: 1.05,
        type: 'dash_slash',
        color: '#f97316',
        range: 6.0
      },
      {
        key: '2',
        name: 'Instant Blast',
        sub: 'Golden Rings · Cooldown 8s · Mana 50',
        tags: '[Dash] [Stun Rings]',
        desc: 'Dashes forward, leaving golden rings that snap back to stun enemies for 1s and deal 250 (+80% ATK) damage.',
        cd: 8,
        mana: 50,
        dmg: 250,
        ratio: 0.8,
        type: 'leap_slam',
        color: '#fbbf24',
        range: 6.5
      },
      {
        key: '3',
        name: 'My Turn (Domain)',
        sub: 'Lieh Arena · Cooldown 26s · Mana 90',
        tags: '[Domain Arena] [Frenzy]',
        desc: 'Pulls the enemy into Lieh\'s Crimson Domain Ring and unleashes a relentless barrage of punches for 690 (+160% ATK) damage.',
        cd: 26,
        mana: 90,
        dmg: 690,
        ratio: 1.6,
        type: 'domain_barrage',
        color: '#dc2626',
        range: 6.5
      }
    ],
    skins: [
      { id: 'default', name: 'Fist of Lieh', tag: 'DEFAULT', coat: '#7f1d1d', hair: '#eab308', trim: '#fbbf24' },
      { id: 'epic', name: 'M-World Yin', tag: 'EPIC', coat: '#1e1b4b', hair: '#38bdf8', trim: '#a855f7' }
    ]
  },
  {
    id: 'kimee',
    name: 'Kimee',
    title: 'Jetpack Alchemist',
    role: 'Marksman / Mage',
    lane: 'Gold Lane',
    laneKey: 'G',
    price: 0,
    unlocked: true,
    stats: { hp: 2350, mana: 520, atk: 132, def: 20, spd: 6.2, range: 8.8, atkSpd: 1.55 },
    colors: {
      skin: '#fde68a',
      hair: '#facc15',
      hairStyle: 'short_bob',
      torso: '#ec4899',
      coat: '#f472b6',
      trim: '#fdf2f8',
      pants: '#831843',
      weapon: 'splat_gun',
      weaponColor: '#f43f5e',
      aura: '#ec4899'
    },
    passive: {
      name: 'Chemist\'s Instinct',
      desc: 'Can move while firing chemical spray bolts rapidly.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Chem Spray',
        sub: 'Rapid Spray · Cooldown 0.55s',
        tags: '[Ranged] [Hybrid]',
        desc: 'Fires fast chemical droplets while hovering on her jetpack.',
        cd: 0.55,
        mana: 0
      },
      {
        key: '1',
        name: 'Energy Transformation',
        sub: 'Acid Volley · Cooldown 5s · Mana 45',
        tags: '[Volley] [Hybrid Damage]',
        desc: 'Fires a high-pressure chemical volley that explodes in a small area for 300 (+95% ATK) damage.',
        cd: 5,
        mana: 45,
        dmg: 300,
        ratio: 0.95,
        type: 'line_bolt',
        color: '#ec4899',
        range: 10.5
      },
      {
        key: '2',
        name: 'Chemical Refinement',
        sub: 'Jet Dash · Cooldown 7.5s · Mana 50',
        tags: '[Blink] [Slow Trail]',
        desc: 'Boosts backward with her jetpack while leaving a corrosive puddle that slows and damages enemies for 230 (+75% ATK).',
        cd: 7.5,
        mana: 50,
        dmg: 230,
        ratio: 0.75,
        type: 'dash_slash',
        color: '#f472b6',
        range: 6.5
      },
      {
        key: '3',
        name: 'Maximum Charge',
        sub: 'Mega Rocket · Cooldown 22s · Mana 95',
        tags: '[Long-Range Artillery] [AoE]',
        desc: 'Launches a supercharged luminescent chemical warhead that detonates on impact for 640 (+150% ATK) AoE damage.',
        cd: 22,
        mana: 95,
        dmg: 640,
        ratio: 1.5,
        type: 'mega_laser',
        color: '#f43f5e',
        range: 16.0
      }
    ],
    skins: [
      { id: 'default', name: 'Steam Researcher', tag: 'DEFAULT', coat: '#f472b6', hair: '#facc15', trim: '#fdf2f8' },
      { id: 'epic', name: 'Astrocat', tag: 'EPIC', coat: '#6366f1', hair: '#f8fafc', trim: '#22d3ee' }
    ]
  },
  {
    id: 'minotor',
    name: 'Minotor',
    title: 'Son of Minos',
    role: 'Tank / Support',
    lane: 'Roaming',
    laneKey: 'R',
    price: 0,
    unlocked: true,
    stats: { hp: 3750, mana: 420, atk: 115, def: 48, spd: 5.7, range: 3.6, atkSpd: 0.95 },
    colors: {
      skin: '#c2410c',
      hair: '#fef3c7',
      hairStyle: 'bull_horns',
      torso: '#9a3412',
      coat: '#7c2d12',
      trim: '#fbbf24',
      pants: '#431407',
      weapon: 'giant_hammer',
      weaponColor: '#f59e0b',
      aura: '#ea580c'
    },
    passive: {
      name: 'Rage Mode',
      desc: 'Dealing and taking damage builds Minotaur Rage, empowering all skills with extra knockup and defense.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Hammer Crush',
        sub: 'Quake Smash · Cooldown 0.95s',
        tags: '[Melee] [Tank]',
        desc: 'Swings his colossal warhammer, shaking the ground.',
        cd: 0.95,
        mana: 0
      },
      {
        key: '1',
        name: 'Despair Stomp',
        sub: 'Hammer Leap · Cooldown 6.5s · Mana 45',
        tags: '[Leap] [AoE Knockup]',
        desc: 'Jumps to a location and slams the ground, knocking enemies airborne for 0.8s and dealing 280 (+85% ATK) damage.',
        cd: 6.5,
        mana: 45,
        dmg: 280,
        ratio: 0.85,
        type: 'leap_slam',
        color: '#f97316',
        range: 6.5
      },
      {
        key: '2',
        name: 'Motivation Roar',
        sub: 'War Cry · Cooldown 8s · Mana 55',
        tags: '[Team Heal] [Buff]',
        desc: 'Lets out a mighty bull roar that heals Minotor and nearby allies by 360 HP while boosting attack speed.',
        cd: 8,
        mana: 55,
        dmg: 360,
        ratio: 0.6,
        type: 'team_heal',
        color: '#4ade80',
        range: 7.0
      },
      {
        key: '3',
        name: 'Minoan Fury',
        sub: 'Triple Quake · Cooldown 28s · Mana 100',
        tags: '[Massive AoE] [Airborne]',
        desc: 'Smashes the ground 3 times in a row with volcanic shockwaves, dealing 590 (+130% ATK) and stunning all surrounding enemies for 1.5s.',
        cd: 28,
        mana: 100,
        dmg: 590,
        ratio: 1.3,
        type: 'minoan_quake',
        color: '#ea580c',
        range: 7.5
      }
    ],
    skins: [
      { id: 'default', name: 'Labyrinth Guardian', tag: 'DEFAULT', coat: '#7c2d12', hair: '#fef3c7', trim: '#fbbf24' },
      { id: 'epic', name: 'Taurus Zodiac', tag: 'ZODIAC', coat: '#1e3a8a', hair: '#fde047', trim: '#38bdf8' }
    ]
  },
  {
    id: 'esteez',
    name: 'Esteez',
    title: 'Moonlight King',
    role: 'Support',
    lane: 'Roaming',
    laneKey: 'R',
    price: 0,
    unlocked: true,
    stats: { hp: 2680, mana: 640, atk: 108, def: 28, spd: 5.9, range: 8.2, atkSpd: 1.1 },
    colors: {
      skin: '#fef3c7',
      hair: '#f8fafc',
      hairStyle: 'elf_crown',
      torso: '#1e3a8a',
      coat: '#1d4ed8',
      trim: '#facc15',
      pants: '#172554',
      weapon: 'tome_scroll',
      weaponColor: '#fde047',
      aura: '#4ade80'
    },
    passive: {
      name: 'Scripture of the Moon Elf',
      desc: 'Periodically charges the Code of Moon Elves, empowering basic attacks to bounce and slow.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Moonlight Bolt',
        sub: 'Lunar Ray · Cooldown 0.8s',
        tags: '[Ranged] [Magic]',
        desc: 'Fires sacred moonlight energy from his royal scroll.',
        cd: 0.8,
        mana: 0
      },
      {
        key: '1',
        name: 'Moonlight Immersion',
        sub: 'Tether Heal · Cooldown 6s · Mana 55',
        tags: '[Heal Link] [Support]',
        desc: 'Links with the lowest-HP ally and himself, restoring 440 (+110% ATK) HP immediately and granting regen.',
        cd: 6,
        mana: 55,
        dmg: 440,
        ratio: 1.1,
        type: 'team_heal',
        color: '#4ade80',
        range: 8.5
      },
      {
        key: '2',
        name: 'Domain of Moon Goddess',
        sub: 'Lunar Ring · Cooldown 8.5s · Mana 65',
        tags: '[AoE Slow] [Magic Damage]',
        desc: 'Drops a flood of moonlight upon the target area, dealing 280 (+85% ATK) damage and slowing enemies by 60%.',
        cd: 8.5,
        mana: 65,
        dmg: 280,
        ratio: 0.85,
        type: 'stun_orb',
        color: '#38bdf8',
        range: 9.0
      },
      {
        key: '3',
        name: 'Blessing of Moon Goddess',
        sub: 'Sanctuary · Cooldown 26s · Mana 110',
        tags: '[Mass Team Heal] [Shield]',
        desc: 'Channels the Moon Goddess for 5s, healing all nearby allies for 720 HP and granting a 450 damage shield while damaging nearby foes.',
        cd: 26,
        mana: 110,
        dmg: 720,
        ratio: 1.4,
        type: 'team_heal',
        color: '#22c55e',
        range: 9.5
      }
    ],
    skins: [
      { id: 'default', name: 'Moon Elf King', tag: 'DEFAULT', coat: '#1d4ed8', hair: '#f8fafc', trim: '#facc15' },
      { id: 'epic', name: 'Galaxy Dominator', tag: 'M3 CHAMP', coat: '#0f172a', hair: '#38bdf8', trim: '#f59e0b' }
    ]
  },
  {
    id: 'masteryee',
    name: 'Master Yee',
    title: 'Wuju Blademaster',
    role: 'Assassin / Fighter',
    lane: 'Jungling',
    laneKey: 'J',
    price: 1200,
    unlocked: true,
    stats: { hp: 2520, mana: 420, atk: 152, def: 22, spd: 6.5, range: 3.3, atkSpd: 1.45 },
    colors: {
      skin: '#fcd34d',
      hair: '#1e293b',
      hairStyle: 'goggles_helm',
      torso: '#334155',
      coat: '#1e293b',
      trim: '#84cc16',
      pants: '#0f172a',
      weapon: 'katana',
      weaponColor: '#a3e635',
      aura: '#84cc16'
    },
    passive: {
      name: 'Double Strike',
      desc: 'Every 3rd basic attack strikes twice in rapid succession.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Wuju Slash',
        sub: 'Swift Cut · Cooldown 0.65s',
        tags: '[Melee] [Crit]',
        desc: 'High-speed katana slashes that shred targets.',
        cd: 0.65,
        mana: 0
      },
      {
        key: '1',
        name: 'Alpha Strike',
        sub: 'Untargetable Slash · Cooldown 7s · Mana 50',
        tags: '[Blink] [Multi-Hit]',
        desc: 'Vanishes in a blur of emerald light, striking up to 4 nearby enemies for 310 (+100% ATK) physical damage.',
        cd: 7,
        mana: 50,
        dmg: 310,
        ratio: 1.0,
        type: 'dash_slash',
        color: '#84cc16',
        range: 7.0
      },
      {
        key: '2',
        name: 'Meditate Blade',
        sub: 'True Style · Cooldown 8s · Mana 45',
        tags: '[Heal] [True Damage]',
        desc: 'Channels Wuju focus to restore 320 HP and empower his blade with bonus true damage.',
        cd: 8,
        mana: 45,
        dmg: 320,
        ratio: 0.8,
        type: 'team_heal',
        color: '#a3e635',
        range: 5.0
      },
      {
        key: '3',
        name: 'Highlander',
        sub: 'Supreme Speed · Cooldown 24s · Mana 90',
        tags: '[Hyper Speed] [Execution]',
        desc: 'Enters Highlander overdrive, dashing through targets with a lethal barrage for 680 (+165% ATK) damage.',
        cd: 24,
        mana: 90,
        dmg: 680,
        ratio: 1.65,
        type: 'triple_sweep',
        color: '#65a30d',
        range: 8.0
      }
    ],
    skins: [
      { id: 'default', name: 'Wuju Master', tag: 'DEFAULT', coat: '#1e293b', hair: '#1e293b', trim: '#84cc16' },
      { id: 'epic', name: 'Project Yi', tag: 'EPIC', coat: '#f97316', hair: '#f8fafc', trim: '#38bdf8' }
    ]
  },
  {
    id: 'ketootoo',
    name: 'Ketootoo',
    title: 'Arcane Trickster',
    role: 'Marksman / Mage',
    lane: 'Gold Lane',
    laneKey: 'G',
    price: 1200,
    unlocked: true,
    stats: { hp: 2390, mana: 520, atk: 134, def: 19, spd: 6.1, range: 9.0, atkSpd: 1.3 },
    colors: {
      skin: '#fed7aa',
      hair: '#451a03',
      hairStyle: 'cap_hood',
      torso: '#374151',
      coat: '#1f2937',
      trim: '#38bdf8',
      pants: '#111827',
      weapon: 'dual_pistols',
      weaponColor: '#60a5fa',
      aura: '#60a5fa'
    },
    passive: {
      name: 'Twin Holster',
      desc: 'Fires twin arcane pistols that ricochet to nearby minions.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Twin Shot',
        sub: 'Dual Bolt · Cooldown 0.75s',
        tags: '[Ranged] [Physical]',
        desc: 'Fires twin hex bullets at the target.',
        cd: 0.75,
        mana: 0
      },
      {
        key: '1',
        name: 'Piercing Round',
        sub: 'Rail Shot · Cooldown 5.5s · Mana 45',
        tags: '[Line] [Armor Break]',
        desc: 'Fires a high-velocity round that pierces targets for 290 (+95% ATK) damage.',
        cd: 5.5,
        mana: 45,
        dmg: 290,
        ratio: 0.95,
        type: 'line_bolt',
        color: '#38bdf8',
        range: 11.0
      },
      {
        key: '2',
        name: 'Tactical Roll',
        sub: 'Evasion · Cooldown 7s · Mana 40',
        tags: '[Dash] [Stun Shot]',
        desc: 'Rolls in the target direction and fires a concussive round that stuns for 0.9s.',
        cd: 7,
        mana: 40,
        dmg: 230,
        ratio: 0.75,
        type: 'stun_orb',
        color: '#60a5fa',
        range: 8.5
      },
      {
        key: '3',
        name: 'Bullet Storm',
        sub: 'Full Barrage · Cooldown 23s · Mana 95',
        tags: '[Cone Barrage] [Burst]',
        desc: 'Unleashes an energy cannon barrage forward, dealing 630 (+150% ATK) damage.',
        cd: 23,
        mana: 95,
        dmg: 630,
        ratio: 1.5,
        type: 'mega_laser',
        color: '#3b82f6',
        range: 15.0
      }
    ],
    skins: [
      { id: 'default', name: 'Street Gunner', tag: 'DEFAULT', coat: '#1f2937', hair: '#451a03', trim: '#38bdf8' }
    ]
  },
  {
    id: 'alucardox',
    name: 'Alucardox',
    title: 'Demon Hunter',
    role: 'Fighter / Assassin',
    lane: 'Exp Lane',
    laneKey: 'E',
    price: 1500,
    unlocked: true,
    stats: { hp: 2890, mana: 0, atk: 146, def: 30, spd: 6.2, range: 3.5, atkSpd: 1.2 },
    colors: {
      skin: '#fde68a',
      hair: '#fef08a',
      hairStyle: 'spiky',
      torso: '#1e3a8a',
      coat: '#991b1b',
      trim: '#fbbf24',
      pants: '#172554',
      weapon: 'greatsword',
      weaponColor: '#60a5fa',
      aura: '#3b82f6'
    },
    passive: {
      name: 'Pursuit',
      desc: 'After casting a skill, his next basic attack dashes to the target and deals 1.4x damage with massive lifesteal.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Demon Cleave',
        sub: 'Heavy Blade · Cooldown 0.8s',
        tags: '[Melee] [Lifesteal]',
        desc: 'Cleaves enemies with his rune greatsword, draining HP.',
        cd: 0.8,
        mana: 0
      },
      {
        key: '1',
        name: 'Groundsplitter',
        sub: 'Leap Cleave · Cooldown 6s · No Mana',
        tags: '[Leap] [Slow]',
        desc: 'Leaps forward and slams his greatsword down for 300 (+100% ATK) physical damage.',
        cd: 6,
        mana: 0,
        dmg: 300,
        ratio: 1.0,
        type: 'leap_slam',
        color: '#3b82f6',
        range: 7.0
      },
      {
        key: '2',
        name: 'Whirling Smash',
        sub: 'Crimson Spin · Cooldown 5s · No Mana',
        tags: '[AoE] [Lifesteal]',
        desc: 'Hurricanes his greatsword around himself, dealing 320 (+105% ATK) damage and healing.',
        cd: 5,
        mana: 0,
        dmg: 320,
        ratio: 1.05,
        type: 'aoe_spin',
        color: '#60a5fa',
        range: 5.0
      },
      {
        key: '3',
        name: 'Fission Wave',
        sub: 'Demon Slash · Cooldown 22s · No Mana',
        tags: '[Wave Burst] [Drain]',
        desc: 'Absorbs enemy energy for huge lifesteal and fires a gigantic wave of sword energy for 660 (+155% ATK) damage.',
        cd: 22,
        mana: 0,
        dmg: 660,
        ratio: 1.55,
        type: 'mega_laser',
        color: '#2563eb',
        range: 13.0
      }
    ],
    skins: [
      { id: 'default', name: 'Lone Hero', tag: 'DEFAULT', coat: '#991b1b', hair: '#fef08a', trim: '#fbbf24' },
      { id: 'legend', name: 'Obsidian Blade', tag: 'LEGEND', coat: '#09090b', hair: '#e2e8f0', trim: '#ef4444' }
    ]
  },
  {
    id: 'gusionox',
    name: 'Gusionox',
    title: 'Holy Blade',
    role: 'Assassin / Mage',
    lane: 'Mid Lane',
    laneKey: 'M',
    price: 1600,
    unlocked: true,
    stats: { hp: 2480, mana: 500, atk: 145, def: 22, spd: 6.4, range: 4.0, atkSpd: 1.3 },
    colors: {
      skin: '#fed7aa',
      hair: '#78350f',
      hairStyle: 'spiky',
      torso: '#f8fafc',
      coat: '#1e3a8a',
      trim: '#38bdf8',
      pants: '#0f172a',
      weapon: 'dual_blades',
      weaponColor: '#22d3ee',
      aura: '#22d3ee'
    },
    passive: {
      name: 'Dagger Specialist',
      desc: 'Each spell cast adds a rune to his dagger; stacking 3 runes heals him and deals bonus target missing HP damage.'
    },
    skills: [
      {
        key: 'ATK',
        name: 'Dagger Strike',
        sub: 'Rune Slash · Cooldown 0.7s',
        tags: '[Melee] [Magic]',
        desc: 'Slashes rapidly with glowing magic daggers.',
        cd: 0.7,
        mana: 0
      },
      {
        key: '1',
        name: 'Sword Spike',
        sub: 'Mark & Blink · Cooldown 6s · Mana 45',
        tags: '[Dagger Throw] [Teleport]',
        desc: 'Throws a dagger and teleports behind the hit target, dealing 290 (+95% ATK) magic damage.',
        cd: 6,
        mana: 45,
        dmg: 290,
        ratio: 0.95,
        type: 'dash_slash',
        color: '#22d3ee',
        range: 7.5
      },
      {
        key: '2',
        name: 'Shadowblade Slaughter',
        sub: '5-Dagger Fan · Cooldown 7s · Mana 55',
        tags: '[Fan Volley] [Recall Blades]',
        desc: 'Throws 5 glowing daggers forward and recalls them, slicing enemies for 350 (+115% ATK) magic damage.',
        cd: 7,
        mana: 55,
        dmg: 350,
        ratio: 1.15,
        type: 'orbit_blades',
        color: '#38bdf8',
        range: 6.5
      },
      {
        key: '3',
        name: 'Incandescence',
        sub: 'Combo Reset · Cooldown 20s · Mana 90',
        tags: '[Blink] [10-Dagger Burst]',
        desc: 'Dashes to a location, resets his daggers, and unleashes a 10-blade storm for 710 (+165% ATK) magic damage.',
        cd: 20,
        mana: 90,
        dmg: 710,
        ratio: 1.65,
        type: 'triple_sweep',
        color: '#06b6d4',
        range: 8.5
      }
    ],
    skins: [
      { id: 'default', name: 'Moonlight Sonata', tag: 'DEFAULT', coat: '#1e3a8a', hair: '#78350f', trim: '#38bdf8' },
      { id: 'legend', name: 'Cosmic Gleam', tag: 'LEGEND', coat: '#312e81', hair: '#e0e7ff', trim: '#c084fc' }
    ]
  }
];

const BATTLE_BUILDS = [
  {
    id: 'crit',
    name: 'Crit Build',
    cost: 11270,
    spell: { id: 'flicker', name: 'Flicker', sub: 'Mobility', cd: 30, color: '#38bdf8', iconKey: 'spell_flicker' },
    bonus: { atk: 45, crit: 0.35, atkSpd: 0.25, hp: 200, spd: 0.4 },
    items: [
      { name: 'Swift Boots', color: '#3b82f6', iconKey: 'item_boots' },
      { name: 'Windtalker', color: '#a855f7', iconKey: 'item_dual_swords' },
      { name: 'Berserker Fury', color: '#dc2626', iconKey: 'item_axe' },
      { name: 'Haas Claws', color: '#e11d48', iconKey: 'item_claw' },
      { name: 'Malefic Roar', color: '#f59e0b', iconKey: 'item_cannon' },
      { name: 'Blade of Despair', color: '#10b981', iconKey: 'item_emerald_blade' }
    ]
  },
  {
    id: 'atkspd',
    name: 'Attack Speed Build',
    cost: 10740,
    spell: { id: 'flicker', name: 'Flicker', sub: 'Mobility', cd: 30, color: '#38bdf8', iconKey: 'spell_flicker' },
    bonus: { atk: 35, crit: 0.15, atkSpd: 0.55, hp: 300, spd: 0.6 },
    items: [
      { name: 'Swift Boots', color: '#3b82f6', iconKey: 'item_boots' },
      { name: 'Corrosion Scythe', color: '#22c55e', iconKey: 'item_scythe' },
      { name: 'Demon Hunter Sword', color: '#6366f1', iconKey: 'item_dual_swords' },
      { name: 'Golden Staff', color: '#eab308', iconKey: 'item_staff' },
      { name: 'Wind of Nature', color: '#14b8a6', iconKey: 'item_emerald_blade' },
      { name: 'Malefic Gun', color: '#a855f7', iconKey: 'item_cannon' }
    ]
  },
  {
    id: 'sustain',
    name: 'Tank / Sustain Build',
    cost: 11790,
    spell: { id: 'vengeance', name: 'Vengeance', sub: 'Defense', cd: 28, color: '#a855f7', iconKey: 'spell_vengeance' },
    bonus: { atk: 25, crit: 0.1, atkSpd: 0.15, hp: 950, spd: 0.3 },
    items: [
      { name: 'Tough Boots', color: '#0ea5e9', iconKey: 'item_boots' },
      { name: 'War Axe', color: '#ef4444', iconKey: 'item_axe' },
      { name: 'Brute Force Plate', color: '#f97316', iconKey: 'item_armor' },
      { name: 'Oracle', color: '#22d3ee', iconKey: 'item_shield' },
      { name: 'Queen Wings', color: '#e11d48', iconKey: 'item_wings' },
      { name: 'Immortality', color: '#facc15', iconKey: 'item_staff' }
    ]
  },
  {
    id: 'recommended',
    name: 'Recommended Pro',
    cost: 11270,
    spell: { id: 'execute', name: 'Execute', sub: 'Offense', cd: 25, color: '#f43f5e', iconKey: 'spell_execute' },
    bonus: { atk: 55, crit: 0.25, atkSpd: 0.3, hp: 350, spd: 0.5 },
    items: [
      { name: 'Rapid Boots', color: '#2563eb', iconKey: 'item_boots' },
      { name: 'Hunter Strike', color: '#9333ea', iconKey: 'item_dual_swords' },
      { name: 'Endless Battle', color: '#dc2626', iconKey: 'item_axe' },
      { name: 'Malefic Roar', color: '#f59e0b', iconKey: 'item_cannon' },
      { name: 'Sea Halberd', color: '#06b6d4', iconKey: 'item_scythe' },
      { name: 'Blade of Despair', color: '#10b981', iconKey: 'item_emerald_blade' }
    ]
  }
];

const BOT_NAMES = [
  'Frenchzko', 'KENZO', 'Kezzy', 'merely_cat', 'sel',
  'The_Bacon', 'chicken_masala', 'Marss', 'cla_taralaro', 'RizkyBlox',
  'ShadowKing99', 'NoobSlayer_ID', 'xX_Viper_Xx', 'AetherBlox'
];

window.GAME_DATA = { HEROES, BATTLE_BUILDS, BOT_NAMES };
