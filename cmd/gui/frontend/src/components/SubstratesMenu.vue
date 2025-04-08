<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const activeIndex = ref<string>('substrates')

const handleSelect = (index: string) => {
    activeIndex.value = index
    router.push({ name: index })
}   
</script>

<template>
    <el-menu :default-active="activeIndex" @select="handleSelect">
        <el-menu-item>Substrates</el-menu-item>
        <el-menu-item index="substrates">
            <Icon icon="mdi:category" height="1.5em" /> Substrates
        </el-menu-item>

    </el-menu>
</template>