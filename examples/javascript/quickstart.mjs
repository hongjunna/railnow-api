// RailNow API quick start for Node.js 18+ (uses the built-in fetch).
// Usage: RAILNOW_API_KEY=jl_... node quickstart.mjs

const API_KEY = process.env.RAILNOW_API_KEY;
const BASE = 'https://railnow.runvia.app/api/v1';

if (!API_KEY) {
  console.error('Set RAILNOW_API_KEY to the key from https://railnow.runvia.app/developer');
  process.exit(1);
}

async function railnow(path, params = {}) {
  const url = new URL(BASE + path);
  for (const [key, value] of Object.entries({ lang: 'en', ...params })) url.searchParams.set(key, value);
  const res = await fetch(url, { headers: { 'X-API-Key': API_KEY } });
  if (res.status === 429) {
    throw new Error(`Rate limit exceeded. Retry after ${res.headers.get('retry-after')} seconds.`);
  }
  if (!res.ok) throw new Error(`${res.status} ${(await res.json()).error}`);
  return res.json();
}

// Find a station, then show the trains approaching it.
const { stations } = await railnow('/station/search', { q: '강남', lineId: '1002' });
const station = stations[0];
console.log(`${station.name} (${station.subwayName}), station ID ${station.stationId}`);

const board = await railnow(`/station/${station.stationId}/board`);
for (const train of board.trains) {
  console.log(`  ${train.direction}  train ${train.trainNo}  ${train.stopsAway} stops away`);
}
