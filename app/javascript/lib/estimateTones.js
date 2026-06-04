// Maps estimate enum values to design-system pill tones, so the colour
// language for difficulty and state stays consistent wherever they render.
// Tones are defined in components/ui/pill.vue.

const DIFFICULTY_TONE = {
  easy: 'success',
  medium: 'warning',
  hard: 'danger'
};

const STATE_TONE = {
  in_progress: 'info',
  on_hold: 'warning',
  done: 'success',
  unknown: 'neutral',
  cancelled: 'danger'
};

export function difficultyTone(difficulty) {
  return DIFFICULTY_TONE[difficulty] || 'neutral';
}

export function stateTone(state) {
  return STATE_TONE[state] || 'neutral';
}
