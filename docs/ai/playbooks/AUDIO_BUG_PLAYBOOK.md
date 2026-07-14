# Audio Bug Playbook

## First questions to answer from code/runtime

- Which package/player instance is active?
- Who owns the selected track?
- Who owns queue state?
- Which stream drives position?
- Which stream drives duration?
- Is source loading complete before seek/play?
- Is position restored?
- Are there competing listeners/providers?
- What happens on completion/error?

## Reproduction matrix

- fresh launch first play
- pause/resume
- select new track
- next/previous
- seek
- app background/foreground
- network slow/failure
- null DB duration
- stream duration longer than DB duration
- timer expiration

## Protected behavior

Do not break background playback, notification controls, favorites, queue, progress, or timer while fixing one symptom.

## Evidence

Capture player state transitions and errors without logging private data.
