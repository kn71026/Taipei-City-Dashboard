<script setup lang="ts">
import { ref, watch, onBeforeUnmount, computed } from "vue";
import DialogContainer from "./DialogContainer.vue";
import { useDialogStore } from "../../store/dialogStore";
import { useMapStore } from "../../store/mapStore";

const dialogStore = useDialogStore();
const mapStore = useMapStore();

/* -------- 狀態 -------- */
const titleText = ref("");
const bearing = ref(0);
const mapImgUrl = ref<string | null>(null);

/* 固定留白 */
const P = 20; // 四周 padding
const TH = computed(() => (titleText.value ? 32 : 0)); // 標題高度

/* ---------- 開關 Dialog ---------- */
function handleClose() {
	dialogStore.hideAllDialogs();
	if (mapImgUrl.value) URL.revokeObjectURL(mapImgUrl.value);
	mapImgUrl.value = null;
	titleText.value = "";
}
watch(
	() => dialogStore.dialogs["exportMap"],
	(v) => v && captureMap()
);

/* ---------- 擷取預覽 ---------- */
async function captureMap() {
	const map = mapStore.map;
	if (!map) return;
	if (!map.isStyleLoaded()) await new Promise((r) => map.once("idle", r));
	await new Promise((r) => requestAnimationFrame(r));

	bearing.value = map.getBearing();
	await new Promise<void>((res) => {
		map.getCanvas().toBlob((b) => {
			if (!b) return;
			if (mapImgUrl.value) URL.revokeObjectURL(mapImgUrl.value);
			mapImgUrl.value = URL.createObjectURL(b);
			res();
		});
	});
}

/* ---------- 下載 PNG ---------- */
function loadImage(src: string) {
	return new Promise<HTMLImageElement>((ok, err) => {
		const i = new Image();
		i.onload = () => ok(i);
		i.onerror = err;
		i.src = src;
	});
}

async function downloadPng() {
	const map = mapStore.map;
	if (!map) return;

	const srcCanvas = map.getCanvas();
	const mapW = srcCanvas.width;
	const mapH = srcCanvas.height;

	const outW = mapW + P * 2;
	const outH = mapH + P * 2 + TH.value;

	const cvs = document.createElement("canvas");
	cvs.width = outW;
	cvs.height = outH;
	const ctx = cvs.getContext("2d")!;

	/* 背景 */
	ctx.fillStyle = "#fff";
	ctx.fillRect(0, 0, outW, outH);

	/* 標題 */
	if (titleText.value) {
		ctx.fillStyle = "#000";
		ctx.font = "20px sans-serif";
		ctx.fillText(titleText.value, P, P + 10);
	} else {
		ctx.fillStyle = "#000";
		ctx.font = "20px sans-serif";
		ctx.fillText("Map", P, P + 10);
	}

	/* 地圖 */
	const mapOffsetY = P + TH.value;
	ctx.drawImage(srcCanvas, P, mapOffsetY);

	/* 北箭 */
	const arrow = await loadImage("/images/map/north-arrow.png");
	const aSize = 32;
	const margin = 8;
	const cx = mapW - aSize / 2 - margin;
	const cy = aSize / 2 + margin;
	ctx.save();
	ctx.translate(cx, cy);
	ctx.rotate((-bearing.value * Math.PI) / 180);
	ctx.drawImage(arrow, -aSize / 2, -aSize / 2, aSize, aSize);
	ctx.restore();

	/* 下載 */
	const a = document.createElement("a");
	a.href = cvs.toDataURL("image/png");
	a.download = (titleText.value || "exported-map") + ".png";
	a.click();
}

onBeforeUnmount(() => {
	if (mapImgUrl.value) URL.revokeObjectURL(mapImgUrl.value);
});
</script>

<template>
	<DialogContainer dialog="exportMap" @on-close="handleClose">
		<div class="export-dialog">
			<h2>地圖匯出預覽 🗺️</h2>

			<!-- 標題輸入 -->
			<div class="ctrl">
				<label>地圖名稱：</label>
				<input v-model="titleText" placeholder="輸入地圖標題" />
			</div>

			<!-- 預覽區 -->
			<div class="export-preview">
				<img v-if="mapImgUrl" :src="mapImgUrl" class="map-img" />
				<p v-else>正在擷取地圖…</p>

				<!-- 疊標題 -->
				<div
					v-if="titleText"
					class="title-overlay"
					:style="{ top: 0 + 'px', left: 0 + 'px' }"
				>
					{{ titleText }}
				</div>

				<!-- 疊北箭 -->
				<img
					v-if="mapImgUrl"
					src="/images/map/north-arrow.png"
					class="arrow-overlay"
					:style="{
						top: 0 + 'px',
						right: 0 + 'px',
						transform: `rotate(${-bearing}deg)`,
					}"
				/>
			</div>

			<!-- 操作 -->
			<div class="actions">
				<button @click="handleClose">取消</button>
				<button :disabled="!mapImgUrl" @click="downloadPng">
					下載 PNG
				</button>
			</div>
		</div>
	</DialogContainer>
</template>

<style scoped>
.export-dialog {
	width: 720px;
	display: flex;
	flex-direction: column;
	gap: 1rem;
}
.ctrl {
	display: flex;
	align-items: center;
	gap: 0.5rem;
}
.ctrl input {
	flex: 1;
	padding: 4px 8px;
	border: 1px solid #aaa;
	border-radius: 4px;
}

.export-preview {
	position: relative;
	width: 640px;
	max-height: 480px;
	background: #eee;
	border: 1px solid #ccc;
	display: flex;
	justify-content: center;
	align-items: center;
	padding: 20px;
	box-sizing: border-box;
}
.map-img {
	max-width: 100%;
	max-height: 100%;
	object-fit: contain;
	border: 1px solid #aaa;
}

.title-overlay {
	position: absolute;
	font-weight: 600;
	color: black;
	padding: 2px 6px;
	border-radius: 4px;
}
.arrow-overlay {
	position: absolute;
	width: 32px;
	transform-origin: center;
}

.actions {
	display: flex;
	justify-content: flex-end;
	gap: 1rem;
}
</style>
