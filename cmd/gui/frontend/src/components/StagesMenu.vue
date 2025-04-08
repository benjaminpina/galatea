<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const activeIndex = ref<string>('stages')

const handleSelect = (index: string) => {
    activeIndex.value = index
    router.push({ name: index })
}
</script>

<template>
    <el-menu default-active="activeIndex" @select="handleSelect">
        <el-menu-item>Stages</el-menu-item>
        <el-menu-item index="stages">
            <Icon icon="mdi:category" height="1.5em" /> Stages
        </el-menu-item>

    </el-menu>
</template>