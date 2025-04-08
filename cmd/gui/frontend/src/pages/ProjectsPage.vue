<script setup lang="ts">
import MainToolbar from '../components/MainToolbar.vue'
import ProjectsMenu from '../components/ProjectsMenu.vue'
</script>

<template>
  <div class="common-layout">
    <el-container>
      <el-header><MainToolbar /></el-header>
      <el-container>
        <el-aside width="200px"><ProjectsMenu /></el-aside>
        <el-container>
          <el-main>Projects</el-main>
          <el-footer>Footer</el-footer>
        </el-container>
        <el-aside width="200px">Aside</el-aside>
      </el-container>
    </el-container>
  </div>
</template>
