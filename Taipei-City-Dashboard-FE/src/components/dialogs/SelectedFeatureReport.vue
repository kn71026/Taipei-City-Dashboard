<script setup>
import { ref, computed } from "vue";
import ApexChart from "vue3-apexcharts";
import { useDialogStore } from "../../store/dialogStore";
import { useMapStore } from "../../store/mapStore";
import { useContentStore } from "../../store/contentStore";
import DialogContainer from "./DialogContainer.vue";

const dialogStore = useDialogStore();
const mapStore = useMapStore();
const contentStore = useContentStore();

function handleClose() {
	dialogStore.hideAllDialogs();
}

// 🌟 每個圖層的展開狀態
const expandedMap = ref(new Map());

function toggleExpanded(layerId) {
	const current = expandedMap.value.get(layerId);
	expandedMap.value.set(layerId, !current);
}

const chartDataByLayer = computed(() => {
	const result = [];
	const map = mapStore.map;

	mapStore.selectedFeatures.forEach((features, layerId) => {
		if (!Array.isArray(features) || features.length === 0) return;

		const sampleProps = features[0].properties || {};
		const possibleKeys = ["direction", "status", "type", "name"];
		const statKey =
			possibleKeys.find((k) => k in sampleProps) ||
			Object.keys(sampleProps)[0] ||
			"未標示";

		const counts = features.reduce((acc, feat) => {
			const val = feat.properties?.[statKey] ?? "未標示";
			acc[val] = (acc[val] || 0) + 1;
			return acc;
		}, {});

		// 預設展開狀態為 true（初次建立）
		if (!expandedMap.value.has(layerId)) {
			expandedMap.value.set(layerId, true);
		}

		result.push({
			layerId,
			key: statKey,
			series: Object.values(counts),
			labels: Object.keys(counts),
		});
	});

	return result;
});
</script>

<template>
	<DialogContainer dialog="selectedFeatureReport" @on-close="handleClose">
		<div class="selected-feature-report">
			<h2>選取報表 📋</h2>
			<p>
				共選取
				{{ [...mapStore.selectedFeatures.values()].flat().length }}
				筆圖層資料：
			</p>

			<div
				v-for="(layer, i) in chartDataByLayer"
				:key="i"
				class="mb-4 border border-gray-300 rounded-md p-3"
			>
				<div
					class="flex justify-between items-center cursor-pointer"
					@click="toggleExpanded(layer.layerId)"
				>
					<h3 class="text-base font-bold">
						圖層：{{ layer.layerId }}（依
						<code>{{ layer.key }}</code> 統計）
					</h3>
					<span>{{
						expandedMap.get(layer.layerId) ? "▼" : "▲"
					}}</span>
				</div>

				<div v-if="expandedMap.get(layer.layerId)">
					<ApexChart
						type="donut"
						width="100%"
						:options="{ labels: layer.labels }"
						:series="layer.series"
					/>
				</div>
			</div>

			<div class="selected-feature-report-control">
				<button @click="handleClose">關閉</button>
			</div>
		</div>
	</DialogContainer>
</template>

<style scoped lang="scss">
.selected-feature-report {
	width: 600px;
	display: flex;
	flex-direction: column;
	max-height: 80vh;
	overflow-y: auto;
	gap: 1rem;

	h2 {
		font-size: 1.4rem;
		margin-bottom: 0.3rem;
	}

	p {
		font-size: 1rem;
		color: #666;
	}

	&-control {
		display: flex;
		justify-content: flex-end;
		margin-top: 1rem;
		button {
			padding: 6px 12px;
			border-radius: 4px;
			background-color: var(--color-highlight, #007bff);
			color: white;
			font-size: 0.9rem;
			cursor: pointer;
			&:hover {
				opacity: 0.85;
			}
		}
	}
}
</style>
