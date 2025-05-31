<script setup lang="ts">
import { ref, computed, onUnmounted, watch } from "vue";
import dayjs from "dayjs";
import { useMapStore } from "../../store/mapStore"; // ← 引入 Pinia store

/*
 * Hour‑based Time Slider (store‑driven)
 * ------------------------------------
 * ‑ 不再 emit，直接寫入 mapStore.timeFilter = { start, end }
 */

const mapStore = useMapStore();

// ─────────────── 時間域設定
const startDate = dayjs("2025-04-01 00:00");
const endDate = dayjs("2025-04-30 23:00");
const totalHours = endDate.diff(startDate, "hour") + 1; // 720

// 24h window 預設
const range = ref<[number, number]>([0, 23]);
const current = ref(range.value[0]);

// flags
const isPlaying = ref(false);
const isIncreasing = ref(false);
const isDecreasing = ref(false);

let timer: number | null = null;
const PLAY_INTERVAL = 15; // ms / hour

// ─────────────── helpers
const currentDate = computed(() =>
	startDate.add(current.value, "hour").format("YYYY-MM-DD HH:mm")
);

const selectedStyle = computed(() => {
	const percent = (v: number) => (v / (totalHours - 1)) * 100;
	return {
		left: percent(range.value[0]) + "%",
		right: 100 - percent(range.value[1]) + "%",
	};
});

// 立即把預設範圍寫入 store (mount 後)
mapStore.timeFilter = {
	start: startDate.add(range.value[0], "hour").valueOf(),
	end: startDate.add(range.value[1], "hour").valueOf(),
};

// ─────────────── lifecycle
function clearTimer() {
	if (timer !== null) {
		clearInterval(timer);
		timer = null;
	}
}
function stopAll() {
	isPlaying.value = false;
	isIncreasing.value = false;
	isDecreasing.value = false;
	clearTimer();
}
onUnmounted(stopAll);

// ─────────────── core
function shiftWindow(step = 1) {
	const w = range.value[1] - range.value[0];
	let s = range.value[0] + step;
	let e = range.value[1] + step;
	if (e >= totalHours) {
		e = totalHours - 1;
		s = e - w;
	}
	if (s < 0) {
		s = 0;
		e = s + w;
	}
	range.value = [s, e];
	current.value = s;
}

function loopIfEnd() {
	if (range.value[1] >= totalHours - 1) {
		const w = range.value[1] - range.value[0];
		range.value = [0, w];
		current.value = 0;
	}
}

function togglePlay() {
	if (isPlaying.value) return stopAll();
	stopAll();
	isPlaying.value = true;
	timer = setInterval(() => {
		shiftWindow(1);
		loopIfEnd();
	}, PLAY_INTERVAL) as unknown as number;
}

function toggleCumulatedMode() {
	if (isIncreasing.value) return stopAll();
	stopAll();
	isIncreasing.value = true;
	timer = setInterval(() => {
		if (range.value[1] < totalHours - 1) {
			range.value[1]++;
		} else stopAll();
	}, PLAY_INTERVAL) as unknown as number;
}

function toggleDecreaseMode() {
	if (isDecreasing.value) return stopAll();
	stopAll();
	isDecreasing.value = true;
	timer = setInterval(() => {
		if (range.value[0] > 0) {
			range.value[0]--;
			current.value = range.value[0];
		} else stopAll();
	}, PLAY_INTERVAL) as unknown as number;
}

// ─────────────── Sync to store
watch(
	range,
	([s, e]) => {
		mapStore.setTimeFilterRange({
			start: startDate.add(s, "hour").valueOf(),
			end: startDate.add(e, "hour").valueOf(),
		});
	},
	{ deep: true }
);
</script>

<template>
	<div class="time-slider-container">
		<div class="time-slider-header">
			<div class="time-label">
				{{ startDate.add(range[0], "hour").format("MM/DD HH:mm") }} –
				{{ startDate.add(range[1], "hour").format("MM/DD HH:mm") }}
			</div>
			<div class="time-controls">
				<button
					@click="shiftWindow(-1)"
					class="shift-button"
					title="← 1h"
				>
					<span class="material-icons">skip_previous</span>
				</button>
				<button
					@click="togglePlay"
					:class="['play-button', isPlaying && 'active']"
					title="Play/Pause"
				>
					<span class="material-icons">{{
						isPlaying ? "pause" : "play_arrow"
					}}</span>
				</button>
				<button
					@click="shiftWindow(1)"
					class="shift-button"
					title="→ 1h"
				>
					<span class="material-icons">skip_next</span>
				</button>
				<button
					@click="toggleCumulatedMode"
					:class="['play-button', isIncreasing && 'active']"
					title="Accumulate"
				>
					<span class="material-icons">{{
						isIncreasing ? "pause" : "trending_up"
					}}</span>
				</button>
				<button
					@click="toggleDecreaseMode"
					:class="['play-button', isDecreasing && 'active']"
					title="Shrink"
				>
					<span class="material-icons">{{
						isDecreasing ? "pause" : "trending_down"
					}}</span>
				</button>
			</div>
		</div>

		<div class="slider-wrapper">
			<div class="slider-track" />
			<div class="slider-selected" :style="selectedStyle" />

			<input
				type="range"
				:min="0"
				:max="totalHours - 1"
				:step="1"
				v-model.number="range[0]"
				class="range-input"
			/>
			<input
				type="range"
				:min="0"
				:max="totalHours - 1"
				:step="1"
				v-model.number="range[1]"
				class="range-input"
			/>
		</div>

		<div class="current-info">當前: {{ currentDate }}</div>
	</div>
</template>

<style scoped>
@import url("https://fonts.googleapis.com/icon?family=Material+Icons");
/*（原樣式保留，不動）*/
.time-slider-container {
	width: 70%;
	padding: 16px;
	font-family: sans-serif;
}
.time-slider-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 16px;
}
.time-label {
	font-size: 14px;
	font-weight: 600;
}
.time-controls {
	display: flex;
	gap: 6px;
}
.play-button,
.shift-button {
	padding: 8px 12px;
	background: #3b82f6;
	color: #fff;
	border: none;
	border-radius: 6px;
	cursor: pointer;
	font-size: 16px;
	display: flex;
	align-items: center;
	justify-content: center;
	transition: background 0.2s;
}
.play-button.active,
.shift-button.active {
	background: #16a34a;
}
.play-button:hover,
.shift-button:hover {
	background: #2563eb;
}
.slider-wrapper {
	position: relative;
	height: 40px;
	padding: 0 10px;
}
.slider-track {
	position: absolute;
	top: 50%;
	left: 10px;
	right: 10px;
	height: 6px;
	background: #e5e7eb;
	border-radius: 3px;
	transform: translateY(-50%);
	z-index: 1;
}
.slider-selected {
	position: absolute;
	top: 50%;
	height: 6px;
	background: #3b82f6;
	border-radius: 3px;
	transform: translateY(-50%);
	z-index: 2;
}
.range-input {
	border: none !important;
	position: absolute;
	top: 50%;
	left: 0;
	width: 100%;
	height: 20px;
	background: none;
	appearance: none;
	pointer-events: none;
	transform: translateY(-50%);
	z-index: 3;
	margin: 0;
	padding: 0;
}
.range-input::-webkit-slider-thumb {
	pointer-events: auto;
	width: 18px;
	height: 18px;
	background: #fff;
	border: 2px solid #3b82f6;
	border-radius: 50%;
	appearance: none;
	cursor: pointer;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
.range-input::-webkit-slider-track {
	background: transparent;
}
.range-input::-moz-range-thumb {
	pointer-events: auto;
	width: 14px;
	height: 14px;
	background: #fff;
	border: 2px solid #3b82f6;
	border-radius: 50%;
	appearance: none;
	cursor: pointer;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
.range-input::-moz-range-track {
	background: transparent;
	height: 6px;
	border: none;
}
.current-info {
	text-align: center;
	margin-top: 12px;
	font-size: 14px;
	color: #6b7280;
}
</style>
