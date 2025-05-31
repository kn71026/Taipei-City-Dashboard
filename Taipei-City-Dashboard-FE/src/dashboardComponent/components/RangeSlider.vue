<script setup lang="ts">
import { computed } from "vue";

const props = withDefaults(
	defineProps<{
		min: number;
		max: number;
		modelValue: [number, number];
		step?: number;
	}>(),
	{ step: 1 }
);

const emit = defineEmits<{
	(e: "update:modelValue", value: [number, number]): void;
}>();

const low = computed({
	get: () => props.modelValue[0],
	set: (val) => {
		const clamped = Math.min(val, props.modelValue[1] - props.step);
		emit("update:modelValue", [clamped, props.modelValue[1]]);
	},
});

const high = computed({
	get: () => props.modelValue[1],
	set: (val) => {
		const clamped = Math.max(val, props.modelValue[0] + props.step);
		emit("update:modelValue", [props.modelValue[0], clamped]);
	},
});

const percent = (val: number) =>
	((val - props.min) / (props.max - props.min)) * 100;

const selectedStyle = computed(() => {
	return {
		left: Math.round(percent(low.value)) + "%",
		right: Math.round(100 - percent(high.value)) + "%",
	};
});
</script>

<template>
	<div class="range-slider-wrapper">
		<div class="track"></div>
		<div class="selected" :style="selectedStyle" />
		<input
			type="range"
			:min="props.min"
			:max="props.max"
			:step="props.step"
			v-model="low"
		/>
		<input
			type="range"
			:min="props.min"
			:max="props.max"
			:step="props.step"
			v-model="high"
		/>
	</div>
</template>

<style scoped>
.range-slider-wrapper {
	position: relative;
	width: 80%;
	height: 32px;
}

.track {
	position: absolute;
	top: 50%;
	left: 10px;
	right: 10px;
	height: 6px;
	background-color: #ccc;
	border-radius: 3px;
	transform: translateY(-50%);
	z-index: 1;
}

.selected {
	position: absolute;
	top: 50%;
	height: 6px;
	background-color: #2563eb;
	border-radius: 3px;
	transform: translateY(-50%);
	z-index: 2;
}

input[type="range"] {
	border: none !important;

	position: absolute;
	top: 50%;
	left: 0;
	width: 100%;
	height: 20px; /* 明確設定高度 */
	background: none;
	pointer-events: none;
	appearance: none;
	transform: translateY(-50%); /* 垂直置中 */
	z-index: 3;
	margin: 0;
	padding: 0;
}

/* WebKit 瀏覽器 (Chrome, Safari, Edge) */
input[type="range"]::-webkit-slider-thumb {
	border: none;
	pointer-events: auto;
	width: 20px;
	height: 20px;
	background: #fff;
	border: 3px solid #2563eb;
	border-radius: 50%;
	appearance: none;
	cursor: pointer;
	position: relative;
	z-index: 4;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	transition: all 0.2s ease;
}

input[type="range"]::-webkit-slider-thumb:hover {
	border-color: #1d4ed8;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

input[type="range"]::-webkit-slider-track {
	background: transparent;
	height: 6px;
	border: none;
	outline: none;
}

/* Firefox */
input[type="range"]::-moz-range-thumb {
	border: none;
	pointer-events: auto;
	width: 14px; /* Firefox 需要調整尺寸 */
	height: 14px;
	background: #fff;
	border: 3px solid #2563eb;
	border-radius: 50%;
	appearance: none;
	cursor: pointer;
	position: relative;
	z-index: 4;
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
	transition: all 0.2s ease;
}

input[type="range"]::-moz-range-thumb:hover {
	border-color: #1d4ed8;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

input[type="range"]::-moz-range-track {
	background: transparent;
	height: 6px;
	border: none;
	outline: none;
}

input[type="range"]::-moz-focus-outer {
	border: 0;
}
</style>
