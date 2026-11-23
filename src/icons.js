const UI_ICONS = {
  // General UI & HUD SVG Icons (No emoji dependency!)
  chat: `<svg viewBox="0 0 24 24" class="svg-ico"><path d="M4 4h16v12H7l-3 3V4z" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linejoin="round"/><circle cx="9" cy="10" r="1.3" fill="currentColor"/><circle cx="12" cy="10" r="1.3" fill="currentColor"/><circle cx="15" cy="10" r="1.3" fill="currentColor"/></svg>`,
  mic: `<svg viewBox="0 0 24 24" class="svg-ico"><rect x="9" y="3" width="6" height="11" rx="3" fill="none" stroke="currentColor" stroke-width="2.2"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3M9 21h6" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/></svg>`,
  soundOn: `<svg viewBox="0 0 24 24" class="svg-ico"><path d="M11 5L6 9H2v6h4l5 4V5z" fill="currentColor"/><path d="M15.5 8.5a5 5 0 0 1 0 7M18.5 5.5a9 9 0 0 1 0 13" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/></svg>`,
  soundOff: `<svg viewBox="0 0 24 24" class="svg-ico"><path d="M11 5L6 9H2v6h4l5 4V5z" fill="currentColor"/><path d="M22 9l-6 6M16 9l6 6" stroke="#ef4444" stroke-width="2.4" stroke-linecap="round"/></svg>`,
  coin: `<svg viewBox="0 0 24 24" class="svg-ico"><circle cx="12" cy="12" r="9" fill="#f59e0b" stroke="#fde047" stroke-width="2"/><path d="M12 7v10M9.5 9.5h5M9.5 14.5h5" stroke="#fffbeb" stroke-width="2" stroke-linecap="round"/></svg>`,
  gem: `<svg viewBox="0 0 24 24" class="svg-ico"><polygon points="12,3 20,9 12,21 4,9" fill="#38bdf8" stroke="#bae6fd" stroke-width="1.8"/></svg>`,
  gift: `<svg viewBox="0 0 24 24" class="svg-ico"><rect x="3" y="8" width="18" height="4" rx="1" fill="#fde047"/><rect x="5" y="12" width="14" height="9" rx="1" fill="#f59e0b"/><path d="M12 8v13M7 8a2.5 2.5 0 1 1 5 0a2.5 2.5 0 1 1 5 0" fill="none" stroke="#fff" stroke-width="2"/></svg>`,
  vote: `<svg viewBox="0 0 24 24" class="svg-ico"><rect x="4" y="11" width="16" height="10" rx="2" fill="#22c55e"/><path d="M9 11V6h6v5M8 15h8" stroke="#fff" stroke-width="2.2" stroke-linecap="round"/></svg>`,
  trophy: `<svg viewBox="0 0 24 24" class="svg-ico"><path d="M7 4h10v6a5 5 0 0 1-10 0V4z" fill="#facc15"/><path d="M7 6H4v2a3 3 0 0 0 3 3M17 6h3v2a3 3 0 0 1-3 3M12 15v4M8 19h8" fill="none" stroke="#fde047" stroke-width="2" stroke-linecap="round"/></svg>`,
  swords: `<svg viewBox="0 0 24 24" class="svg-ico"><path d="M4 20L19 5M14 5h5v5" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" fill="none"/><path d="M20 20L5 5M10 5H5v5" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" fill="none"/></svg>`,
  hero: `<svg viewBox="0 0 24 24" class="svg-ico"><circle cx="12" cy="8" r="4" fill="currentColor"/><path d="M4 20c0-4.4 3.6-7 8-7s8 2.6 8 7" fill="currentColor"/></svg>`,
  emblem: `<svg viewBox="0 0 24 24" class="svg-ico"><polygon points="12,2 22,12 12,22 2,12" fill="none" stroke="#38bdf8" stroke-width="2.4"/><circle cx="12" cy="12" r="3.5" fill="#facc15"/></svg>`,
  gear: `<svg viewBox="0 0 24 24" class="svg-ico"><circle cx="12" cy="12" r="3.5" fill="none" stroke="currentColor" stroke-width="2.4"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M19.1 4.9L17 7M7 17l-2.1 2.1" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"/></svg>`,
  zoom: `<svg viewBox="0 0 24 24" class="svg-ico"><circle cx="10.5" cy="10.5" r="6.5" fill="none" stroke="currentColor" stroke-width="2.4"/><path d="M15.5 15.5L21 21M10.5 7.5v6M7.5 10.5h6" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/></svg>`,
  turret: `<svg viewBox="0 0 24 24" class="svg-ico"><polygon points="12,3 16,7 12,11 8,7" fill="#f87171"/><rect x="8" y="12" width="8" height="8" rx="1" fill="#e2e8f0"/><rect x="5" y="19" width="14" height="3" rx="1" fill="#94a3b8"/></svg>`,
  skull: `<svg viewBox="0 0 24 24" class="svg-ico"><path d="M12 3a8 8 0 0 0-8 8c0 2.8 1.5 5.2 3.5 6.5V21h9v-3.5c2-1.3 3.5-3.7 3.5-6.5a8 8 0 0 0-8-8z" fill="#e2e8f0"/><circle cx="9" cy="11" r="1.8" fill="#0f172a"/><circle cx="15" cy="11" r="1.8" fill="#0f172a"/></svg>`,
  assist: `<svg viewBox="0 0 24 24" class="svg-ico"><path d="M12 3l2.6 5.4L20 9.2l-4 3.9.9 5.5-4.9-2.6-4.9 2.6.9-5.5-4-3.9 5.4-.8L12 3z" fill="#38bdf8"/></svg>`,
  manaDrop: `<svg viewBox="0 0 16 16" class="svg-ico-xs"><path d="M8 1C8 1 3 6.8 3 10.2A5 5 0 0 0 13 10.2C13 6.8 8 1 8 1z" fill="#38bdf8"/></svg>`,

  // Battle Spells (Recall, Regen, Flicker, Vengeance, Execute)
  spell_recall: `<svg viewBox="0 0 64 64" class="svg-fill"><ellipse cx="32" cy="50" rx="18" ry="6" fill="none" stroke="#bae6fd" stroke-width="4"/><circle cx="32" cy="17" r="6.5" fill="#ffffff"/><path d="M24 26h16l2 12h-5l-1 11h-8l-1-11h-5z" fill="#ffffff"/></svg>`,
  spell_regen: `<svg viewBox="0 0 64 64" class="svg-fill"><circle cx="32" cy="17" r="6.5" fill="#0f172a"/><path d="M24 26h16l2 12h-5l-1 11h-8l-1-11h-5z" fill="#0f172a"/><path d="M48 16v10M43 21h10M15 24v8M11 28h8" stroke="#bbf7d0" stroke-width="4" stroke-linecap="round"/></svg>`,
  spell_flicker: `<svg viewBox="0 0 64 64" class="svg-fill"><circle cx="40" cy="15" r="6" fill="#ffffff"/><path d="M28 24l14-2-4 14 8 8-4 4-10-8-6 10-5-3 6-13-7-3z" fill="#ffffff"/><path d="M8 22h12M6 32h12M10 42h10" stroke="#bae6fd" stroke-width="4" stroke-linecap="round"/></svg>`,
  spell_vengeance: `<svg viewBox="0 0 64 64" class="svg-fill"><polygon points="32,8 52,20 46,48 32,56 18,48 12,20" fill="none" stroke="#e9d5ff" stroke-width="4.5"/><path d="M22 24l10 16 10-16" fill="none" stroke="#c084fc" stroke-width="4" stroke-linecap="round"/></svg>`,
  spell_execute: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M32 8L44 28H35L42 54L20 30H30L24 8Z" fill="#fecdd3" stroke="#f43f5e" stroke-width="2.5"/></svg>`,

  // Equipment Item Artwork SVGs (For Battle Setup & Top-Left Quick Shop!)
  item_boots: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M24 14h14v22l12 8v8H16V38l8-6V14z" fill="#60a5fa" stroke="#e0f2fe" stroke-width="3"/><path d="M12 24h10M8 32h12" stroke="#fde047" stroke-width="3.5" stroke-linecap="round"/></svg>`,
  item_dual_swords: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M14 50L48 16M40 14h10v10" stroke="#c084fc" stroke-width="5" stroke-linecap="round" fill="none"/><path d="M50 50L16 16M24 14H14v10" stroke="#f472b6" stroke-width="5" stroke-linecap="round" fill="none"/></svg>`,
  item_axe: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M16 50L46 16" stroke="#fde047" stroke-width="5" stroke-linecap="round"/><path d="M30 12c12-2 22 6 20 18-8 4-16-2-20-18z" fill="#ef4444" stroke="#fca5a5" stroke-width="2.5"/></svg>`,
  item_claw: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M16 46C22 26 34 16 48 14M22 52C28 34 38 24 52 22M12 38C18 22 28 14 40 10" stroke="#fb7185" stroke-width="4.5" stroke-linecap="round" fill="none"/></svg>`,
  item_cannon: `<svg viewBox="0 0 64 64" class="svg-fill"><rect x="14" y="24" width="32" height="16" rx="4" transform="rotate(-25 30 32)" fill="#fbbf24" stroke="#fef08a" stroke-width="2.5"/><circle cx="48" cy="22" r="6" fill="#ef4444"/></svg>`,
  item_emerald_blade: `<svg viewBox="0 0 64 64" class="svg-fill"><polygon points="48,12 52,16 24,46 16,48 18,40" fill="#34d399" stroke="#a7f3d0" stroke-width="2.5"/><path d="M12 52l8-8" stroke="#fde047" stroke-width="5" stroke-linecap="round"/></svg>`,
  item_scythe: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M18 52L42 16" stroke="#a3e635" stroke-width="4.5" stroke-linecap="round"/><path d="M42 16c-16-4-26 4-28 16 8-6 18-8 28-16z" fill="#4ade80" stroke="#dcfce7" stroke-width="2"/></svg>`,
  item_staff: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M14 50L44 20" stroke="#facc15" stroke-width="5" stroke-linecap="round"/><circle cx="46" cy="18" r="8" fill="#fef08a" stroke="#f59e0b" stroke-width="3"/></svg>`,
  item_armor: `<svg viewBox="0 0 64 64" class="svg-fill"><polygon points="20,14 44,14 50,26 42,50 22,50 14,26" fill="#fb923c" stroke="#fed7aa" stroke-width="3"/><path d="M32 18v28" stroke="#7c2d12" stroke-width="3"/></svg>`,
  item_wings: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M30 44C14 42 10 26 16 14c6 8 14 12 16 18 2-6 10-10 16-18 6 12 2 28-14 30z" fill="#f43f5e" stroke="#fecdd3" stroke-width="2.5"/></svg>`,
  item_shield: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M32 10L50 18v16c0 12-8 20-18 24-10-4-18-12-18-24V18L32 10z" fill="#38bdf8" stroke="#e0f2fe" stroke-width="3"/></svg>`,

  // Skill Artwork SVGs (For Draft Pick Skill Cards, Heroes Drawer, and In-Game Skill Buttons!)
  sk_basic_ranged: `<svg viewBox="0 0 64 64" class="svg-fill"><circle cx="42" cy="22" r="9" fill="#38bdf8"/><path d="M12 52L36 28M10 38l16-16M26 54l16-16" stroke="#bae6fd" stroke-width="4.5" stroke-linecap="round"/></svg>`,
  sk_basic_melee: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M14 50L48 16M40 14h10v10" stroke="#f59e0b" stroke-width="5.5" stroke-linecap="round" fill="none"/><path d="M50 50L16 16M24 14H14v10" stroke="#fde047" stroke-width="5.5" stroke-linecap="round" fill="none"/></svg>`,
  sk_line_bolt: `<svg viewBox="0 0 64 64" class="svg-fill"><circle cx="42" cy="32" r="12" fill="#fde047" stroke="#f59e0b" stroke-width="3"/><path d="M8 22h22M4 32h24M8 42h22" stroke="#facc15" stroke-width="4.5" stroke-linecap="round"/></svg>`,
  sk_stun_orb: `<svg viewBox="0 0 64 64" class="svg-fill"><circle cx="32" cy="32" r="19" fill="none" stroke="#c084fc" stroke-width="4" stroke-dasharray="7 4"/><circle cx="32" cy="32" r="10" fill="#e9d5ff"/><path d="M32 6v8M32 50v8M6 32h8M50 32h8" stroke="#38bdf8" stroke-width="3.5" stroke-linecap="round"/></svg>`,
  sk_mega_laser: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M10 54L54 10" stroke="#06b6d4" stroke-width="16" stroke-linecap="round"/><path d="M10 54L54 10" stroke="#ffffff" stroke-width="6" stroke-linecap="round"/><circle cx="48" cy="16" r="10" fill="#a5f3fc" opacity="0.7"/></svg>`,
  sk_orbit_blades: `<svg viewBox="0 0 64 64" class="svg-fill"><circle cx="32" cy="32" r="16" fill="none" stroke="#38bdf8" stroke-width="3.5" stroke-dasharray="8 5"/><polygon points="32,4 37,16 27,16" fill="#bae6fd"/><polygon points="60,32 48,37 48,27" fill="#bae6fd"/><polygon points="32,60 27,48 37,48" fill="#bae6fd"/><polygon points="4,32 16,27 16,37" fill="#bae6fd"/></svg>`,
  sk_dash_slash: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M10 48L48 14" stroke="#60a5fa" stroke-width="7" stroke-linecap="round"/><path d="M36 12h16v16" fill="none" stroke="#ffffff" stroke-width="5" stroke-linecap="round"/><path d="M8 32l18-16M22 54l18-16" stroke="#38bdf8" stroke-width="3.5" stroke-linecap="round"/></svg>`,
  sk_triple_sweep: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M12 20Q32 4 52 24M10 34Q32 18 54 38M14 48Q32 32 50 52" fill="none" stroke="#f43f5e" stroke-width="5" stroke-linecap="round"/><path d="M24 54L44 10" stroke="#ffffff" stroke-width="4" stroke-linecap="round"/></svg>`,
  sk_aoe_spin: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M48 20A20 20 0 1 0 50 40" fill="none" stroke="#fb7185" stroke-width="6" stroke-linecap="round"/><polygon points="54,18 42,12 44,26" fill="#ffe4e6"/><circle cx="32" cy="32" r="7" fill="#e11d48"/></svg>`,
  sk_leap_slam: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M14 38Q28 8 46 36" fill="none" stroke="#fb923c" stroke-width="5" stroke-linecap="round"/><ellipse cx="44" cy="46" rx="14" ry="6" fill="none" stroke="#fde047" stroke-width="4"/><circle cx="44" cy="42" r="6" fill="#ef4444"/></svg>`,
  sk_dragon_form: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M16 48L24 20l10 8 10-16 6 24-14 14z" fill="#e11d48" stroke="#fda4af" stroke-width="2.5"/><circle cx="36" cy="24" r="3" fill="#fde047"/></svg>`,
  sk_ring_pulse: `<svg viewBox="0 0 64 64" class="svg-fill"><circle cx="32" cy="32" r="22" fill="none" stroke="#facc15" stroke-width="4"/><circle cx="32" cy="32" r="12" fill="none" stroke="#fde047" stroke-width="3" stroke-dasharray="5 3"/><circle cx="32" cy="32" r="5" fill="#ffffff"/></svg>`,
  sk_divine_chain: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M14 50L50 14M14 14L50 50" stroke="#facc15" stroke-width="5" stroke-linecap="round" stroke-dasharray="6 4"/><circle cx="32" cy="32" r="10" fill="#eab308" stroke="#fef08a" stroke-width="3"/></svg>`,
  sk_domain_barrage: `<svg viewBox="0 0 64 64" class="svg-fill"><circle cx="32" cy="32" r="22" fill="none" stroke="#dc2626" stroke-width="4.5"/><circle cx="24" cy="26" r="5" fill="#fde047"/><circle cx="40" cy="24" r="5" fill="#fde047"/><circle cx="32" cy="40" r="6" fill="#fb923c"/></svg>`,
  sk_team_heal: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M26 14h12v12h12v12H38v12H26V38H14V26h12V14z" fill="#4ade80" stroke="#bbf7d0" stroke-width="2.5"/></svg>`,
  sk_minoan_quake: `<svg viewBox="0 0 64 64" class="svg-fill"><path d="M14 48h36M8 38l12-10 12 8 12-12 12 14" fill="none" stroke="#f97316" stroke-width="5" stroke-linecap="round"/><circle cx="32" cy="20" r="7" fill="#fde047"/></svg>`
};

function getSkillSvg(skill) {
  if (!skill) return UI_ICONS.sk_basic_melee;
  if (skill.icon && UI_ICONS[skill.icon]) return UI_ICONS[skill.icon];
  if (skill.type && UI_ICONS['sk_' + skill.type]) return UI_ICONS['sk_' + skill.type];
  if (skill.key === 'ATK') {
    return (skill.tags && skill.tags.includes('Ranged')) ? UI_ICONS.sk_basic_ranged : UI_ICONS.sk_basic_melee;
  }
  return UI_ICONS.sk_line_bolt;
}

window.UI_ICONS = UI_ICONS;
window.getSkillSvg = getSkillSvg;

