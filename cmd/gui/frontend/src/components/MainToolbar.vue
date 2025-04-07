<script setup lang="ts">
import { ref } from 'vue'

const activeIndex = ref<string>('1')

const handleSelect = (index: string) => {
    activeIndex.value = index
}
</script>

<template>
    <el-menu mode="horizontal" :default-active="activeIndex" @select="handleSelect">
        <el-menu-item index="1">
            <Icon icon="mdi:home" height="1.5em" /> Home
        </el-menu-item>
        <el-menu-item index="2">
            <Icon icon="mdi:nature-people" height="1.5em" /> Environments
        </el-menu-item>
        <el-menu-item index="3">
            <Icon icon="mdi:bug" height="1.5em" /> Agents
        </el-menu-item>
        <el-menu-item index="4">
            <Icon icon="mdi:view-list" height="1.5em" /> Stages
        </el-menu-item>
        <el-menu-item index="5">
            <Icon icon="mdi:grass" height="1.5em" /> Substrates
        </el-menu-item>
    </el-menu>
</template>