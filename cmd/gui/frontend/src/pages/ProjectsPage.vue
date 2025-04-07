<script setup lang="ts">
import ProjectsToolbar from '../components/ProjectsToolbar.vue'
</script>

<template>
  <div class="page-content">
    <ProjectsToolbar />
    <el-row>
        <el-col :span="2">Information Panel</el-col>
        <el-col :span="10">Environment</el-col>
    </el-row>
  </div>
</template>