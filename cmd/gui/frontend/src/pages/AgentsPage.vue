<script setup lang="ts">
import AgentsToolbar from '../components/AgentsToolbar.vue'
</script>

<template>
  <div class="page-content">  
    <AgentsToolbar />
    <el-row>
      <el-col :span="2">Information Panel</el-col>
      <el-col :span="10">Agents</el-col>
    </el-row>
  </div>
</template>