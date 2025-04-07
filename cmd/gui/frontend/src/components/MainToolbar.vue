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
        <el-menu-item>Galatea</el-menu-item>
        <el-menu-item index="home">
            <Icon icon="mdi:home" height="1.5em" /> Home
        </el-menu-item>
        <el-menu-item index="environments">
            <Icon icon="mdi:nature-people" height="1.5em" /> Environments
        </el-menu-item>
        <el-menu-item index="agents">
            <Icon icon="mdi:bug" height="1.5em" /> Agents
        </el-menu-item>
        <el-menu-item index="stages">
            <Icon icon="mdi:view-list" height="1.5em" /> Stages
        </el-menu-item>
        <el-menu-item index="substrates">
            <Icon icon="mdi:grass" height="1.5em" /> Substrates
        </el-menu-item>
    </el-menu>
</template>
