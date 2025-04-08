<template>
    <div class="common-layout">
        <el-container>
            <el-header>
                <MainToolbar />
            </el-header>
            <router-view />
        </el-container>
    </div>
</template>

<script setup lang="ts">
import MainToolbar from '../components/MainToolbar.vue'
</script>