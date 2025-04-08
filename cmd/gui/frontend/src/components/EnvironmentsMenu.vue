<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const activeIndex = ref<string>('environments')

const handleSelect = (index: string) => {
    activeIndex.value = index
    router.push({ name: index })
}
</script>

<template>
    <el-menu default-active="activeIndex" @select="handleSelect">
        <el-menu-item>Environments</el-menu-item>
        <el-menu-item index="projects">
            <Icon icon="mdi:nature-people" height="1.5em" /> Environments
        </el-menu-item>

    </el-menu>
</template>