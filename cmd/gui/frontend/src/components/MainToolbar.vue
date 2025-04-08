<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const activePage = ref<string>('projects')

const handleSelect = (index: string) => {
    activePage.value = index
    router.push({ name: index })
}
</script>

<template>
    <el-menu class="fixed-menu" mode="horizontal" :default-active="activePage" @select="handleSelect">
        <el-menu-item>Galatea</el-menu-item>
        <el-menu-item index="projects">
            <Icon icon="mdi:category" height="1.5em" /> Projects
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
