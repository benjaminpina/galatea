<script setup lang="ts">
import MainToolbar from '../components/MainToolbar.vue'
</script>

<template>
  <div class="common-layout">
    <el-container>
      <el-header><MainToolbar /></el-header>
      <el-container>
        <el-aside width="200px">Aside</el-aside>
        <el-container>
          <el-main>Environments</el-main>
          <el-footer>Footer</el-footer>
        </el-container>
      </el-container>
    </el-container>
  </div>
</template>