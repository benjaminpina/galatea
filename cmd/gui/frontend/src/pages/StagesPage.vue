<script setup lang="ts">
import MainToolbar from '../components/MainToolbar.vue'
import StagesMenu from '../components/StagesMenu.vue'
</script>

<template>
  <div class="common-layout">
    <el-container>
      <el-header><MainToolbar /></el-header>
      <el-container>
        <el-aside width="200px"><StagesMenu /></el-aside>
        <el-container>
          <el-main>Stages</el-main>
          <el-footer>Footer</el-footer>
        </el-container>
      </el-container>
    </el-container>
  </div>
</template>