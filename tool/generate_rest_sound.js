// Gera o sinal sonoro de fim do descanso: "bip-bip-biiip" (WAV 16 bits,
// mono, 44,1 kHz), sintetizado aqui para não depender de áudio de terceiros.
//
// Saídas (mesmo arquivo):
//   assets/sounds/rest_end.wav                    som tocado pelo app aberto
//   android/app/src/main/res/raw/rest_end.wav     som da notificação (Android)
//
// Uso: node tool/generate_rest_sound.js
const fs = require('fs');
const path = require('path');

const ROOT = path.join(__dirname, '..');
const RATE = 44100;
const AMPLITUDE = 0.7;
const FADE = 0.008; // rampa de 8 ms em cada borda (evita estalos)

// [frequência Hz, duração s, silêncio depois s]
const PULSES = [
  [1046.5, 0.14, 0.11], // dó 6
  [1046.5, 0.14, 0.11],
  [1318.5, 0.42, 0.05], // mi 6, mais longo
];

const samples = [];
for (const [freq, duration, gap] of PULSES) {
  const n = Math.round(duration * RATE);
  const fade = Math.round(FADE * RATE);
  for (let i = 0; i < n; i++) {
    const envelope = Math.min(1, i / fade, (n - 1 - i) / fade);
    // Fundamental + um pouco da 2ª harmônica: mais audível em alto-falantes
    // pequenos de celular.
    const t = i / RATE;
    const wave =
      0.8 * Math.sin(2 * Math.PI * freq * t) +
      0.2 * Math.sin(2 * Math.PI * 2 * freq * t);
    samples.push(wave * envelope * AMPLITUDE);
  }
  for (let i = 0; i < Math.round(gap * RATE); i++) samples.push(0);
}

const data = Buffer.alloc(samples.length * 2);
samples.forEach((s, i) =>
  data.writeInt16LE(Math.round(Math.max(-1, Math.min(1, s)) * 32767), i * 2),
);
const header = Buffer.alloc(44);
header.write('RIFF', 0);
header.writeUInt32LE(36 + data.length, 4);
header.write('WAVE', 8);
header.write('fmt ', 12);
header.writeUInt32LE(16, 16); // tamanho do bloco fmt
header.writeUInt16LE(1, 20); // PCM
header.writeUInt16LE(1, 22); // mono
header.writeUInt32LE(RATE, 24);
header.writeUInt32LE(RATE * 2, 28); // bytes por segundo
header.writeUInt16LE(2, 32); // bytes por amostra
header.writeUInt16LE(16, 34); // bits
header.write('data', 36);
header.writeUInt32LE(data.length, 40);
const wav = Buffer.concat([header, data]);

for (const out of [
  'assets/sounds/rest_end.wav',
  'android/app/src/main/res/raw/rest_end.wav',
]) {
  const file = path.join(ROOT, out);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, wav);
  console.log(`${out}: ${wav.length} bytes, ${(samples.length / RATE).toFixed(2)} s`);
}
