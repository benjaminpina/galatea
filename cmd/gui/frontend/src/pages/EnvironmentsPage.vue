<script setup lang="ts">
import EnvironmentsToolbar from '../components/EnvironmentsToolbar.vue'
</script>

<template>
  <div class="page-content">
    <EnvironmentsToolbar />
    <el-row>
      <el-col :span="2">Information Panel</el-col>
      <el-col :span="10">Environment</el-col>
    </el-row>
  </div>
</template>