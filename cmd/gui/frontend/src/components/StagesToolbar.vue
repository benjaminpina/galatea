<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const activeIndex = ref<string>('home')

const handleSelect = (index: string) => {
    activeIndex.value = index
    router.push({ name: index })
}
</script>

<template>
    <el-menu mode="horizontal" :default-active="activeIndex" @select="handleSelect">
        <el-menu-item>Stages</el-menu-item>
        <el-menu-item index="home">
            <Icon icon="mdi:home" height="1.5em" /> Home
        </el-menu-item>

    </el-menu>
</template>